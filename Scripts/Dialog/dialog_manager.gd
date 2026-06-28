## 对话管理器
## 负责控制对话流程：显示/隐藏、打字机效果、选项处理、分支跳转
## 使用方式：将此脚本挂载到一个Control节点上，或通过代码实例化

extends CanvasLayer
class_name DialogManager

#region 信号
signal dialog_started
signal dialog_finished
signal dialog_entry_shown(entry: DialogData.DialogEntry)
signal option_selected(option_index: int, option: DialogData.DialogOption)
#endregion

#region 导出参数
@export_group("打字机效果")
@export var typewriter_enabled: bool = true          ## 是否启用打字机效果
@export var typewriter_speed: float = 0.04           ## 每个字符的间隔时间（秒）
@export var skip_typewriter_on_click: bool = true     ## 点击是否跳过打字机效果

@export_group("自动播放")
@export var auto_play_enabled: bool = false           ## 是否自动播放下一句
@export var auto_play_delay: float = 2.0             ## 自动播放延迟时间（秒）

@export_group("播放音效")
@export var type_sound_enabled: bool = true       
#endregion

#region 节点引用 - 如果不用全局单例的场景，就需要在场景中创建对应节点喵
@onready var speaker_label: RichTextLabel = $DialogPanel/Speaker
@onready var text_label: RichTextLabel = $DialogPanel/MarginContainer/Eventlog
@onready var option_container: VBoxContainer = $OptionContainer
@onready var dialog_panel: Panel = $DialogPanel
@onready var indicator: Control = $NextIndicator      ## "继续"提示指示器
@onready var bg_texture: TextureRect = $Background
@onready var portrait_texture: TextureRect = $Portrait
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

#endregion

#region 内部状态
var _entries: Dictionary = {}          ## 当前对话的所有条目
var _current_id: String = ""           ## 当前对话条目ID
var _is_active: bool = false           ## 对话是否激活
var _is_typing: bool = false           ## 是否正在打字
#var _typewriter_tween: Tween = null    ## 打字机动画   以替换为timer控制
var _typewriter_timer: Timer = null    ##打字机计时器
var _current_char_index: int = 0       ## 当前已显示字符数
var _full_text: String = ""            ## 当前完整文本
var _auto_play_timer: float = 0.0      ## 自动播放计时器
var _waiting_for_option: bool = false  ## 是否在等待选项选择
var _waiting_for_click: bool = false   ## 是否在等待点击继续
#endregion

func _ready() -> void:
	visible = false
	if indicator:
		indicator.visible = false

func _input(event: InputEvent) -> void:
	#print("🖱️ _input 触发: ", event.get_class())
	if not _is_active:
		return

	if event is InputEventMouseButton and event.pressed:
		# 等待选项选择时，不拦截鼠标点击，让按钮能正常响应
		if _waiting_for_option:
			return
		_handle_click()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			_handle_click()
			get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	## 自动播放逻辑
	if auto_play_enabled and _waiting_for_click and not _waiting_for_option:
		_auto_play_timer += delta
		if indicator:
			indicator.visible = false
		if _auto_play_timer >= auto_play_delay:
			_auto_play_timer = 0.0
			_advance_dialog()

#region 公开API

## 开始一段对话（传入对话数据字典）
func start_dialog(entries: Dictionary, start_id: String = "start") -> void:
	_entries = entries
	_current_id = start_id
	_is_active = true
	visible = true
	dialog_started.emit()
	_show_entry(_current_id)

## 从JSON文件开始对话
func start_dialog_from_file(file_path: String, start_id: String = "start") -> void:
	var entries = DialogData.load_from_file(file_path)
	if entries.is_empty():
		push_warning("对话数据为空，无法开始对话")
		return
	start_dialog(entries, start_id)

## 强制结束对话
func end_dialog() -> void:
	_is_active = false
	_is_typing = false
	_waiting_for_click = false
	_waiting_for_option = false
	_current_id = ""
	if _typewriter_timer and not _typewriter_timer.is_stopped():
		_typewriter_timer.stop()
	visible = false
	dialog_finished.emit()

## 当前对话是否激活
func is_active() -> bool:
	return _is_active

#endregion

#region 内部逻辑

## 显示指定ID的对话条目
func _show_entry(id: String) -> void:
	if not _entries.has(id):
		push_warning("对话ID不存在: " + id)
		end_dialog()
		return

	var entry: DialogData.DialogEntry = _entries[id]
	_current_id = id
	_waiting_for_click = false
	_waiting_for_option = false
	_auto_play_timer = 0.0
	if entry.bg != "":
		# 判断是否需要切换背景（当前无背景，或背景路径不同）
		var need_change = not bg_texture.visible or bg_texture.texture.resource_path != entry.bg
		
		if need_change:
			# 如果当前有背景，先淡出
			if bg_texture.visible and bg_texture.modulate.a > 0.0:
				await TweenPlayer.fade_out(bg_texture).finished
			
			# 加载并淡入新背景
			bg_texture.texture = load(entry.bg)
			bg_texture.position = entry.bg_position
			bg_texture.visible = true
			bg_texture.modulate.a = 0.0
			await TweenPlayer.fade_in(bg_texture).finished
	else:
		# 无背景，淡出当前背景
		if bg_texture.visible:
			await TweenPlayer.fade_out(bg_texture).finished
			bg_texture.visible = false

	
	# 设置立绘
	if entry.portrait != "":
		portrait_texture.texture = load(entry.portrait)
		portrait_texture.visible = true
	else:
		portrait_texture.visible = false
	
	# 替换文本
	var display_text = entry.text
	if Global.player != null:
		display_text = display_text.replace("{player_name}", Global.player.name)

	# 更新说话人
	if speaker_label:
		speaker_label.text = entry.speaker
		speaker_label.visible = (entry.speaker != "")

	# 清空旧选项
	_clear_options()

	# 隐藏指示器
	if indicator:
		indicator.visible = false

	# 显示文本
	if typewriter_enabled:
		_start_typewriter(entry.text)
	else:
		if text_label:
			text_label.text = entry.text
		_on_text_displayed(entry)

	dialog_entry_shown.emit(entry)

## 打字机效果
func _start_typewriter(text: String) -> void:
	_full_text = text
	_is_typing = true
	if text_label:
		text_label.visible_characters = 0
		text_label.text = text

	# 停止旧的计时器
	if _typewriter_timer and not _typewriter_timer.is_stopped():
		_typewriter_timer.stop()

	# 创建计时器（如果还没有）
	if _typewriter_timer == null:
		_typewriter_timer = Timer.new()
		add_child(_typewriter_timer)
		_typewriter_timer.timeout.connect(_on_typewriter_timer_timeout)
		
	# 根据当前速度设置间隔
	_typewriter_timer.wait_time = typewriter_speed
	_current_char_index = 0
	_typewriter_timer.start()

##打字机计时结束
func _on_typewriter_timer_timeout() -> void:
	#print("⏱️ Timer触发, 当前字符: ", _current_char_index, "/", _full_text.length())
	_current_char_index += 1
	text_label.visible_characters = _current_char_index

	# 播放音效（每个字符）
	if type_sound_enabled:
		play_char_sound()

	# 检查是否完成
	if _current_char_index >= _full_text.length():
		_typewriter_timer.stop()
		_on_typewriter_finished()

func play_char_sound() -> void:
	# 如果有音效文件，播放它
	if audio_stream_player and audio_stream_player.stream:
		audio_stream_player.play()

## 打字机完成
func _on_typewriter_finished() -> void:
	#print("✅ 打字机完成，_is_typing 设为 false")
	if not _is_typing:
		return  ## 防止跳过打字机后重复调用
	_is_typing = false
	var entry = _entries.get(_current_id) as DialogData.DialogEntry
	if entry:
		_on_text_displayed(entry)

## 文本显示完毕后的处理
func _on_text_displayed(entry: DialogData.DialogEntry) -> void:
	# 如果有选项，显示选项
	if entry.options.size() > 0:
		_show_options(entry.options)
		_waiting_for_option = true
	else:
		# 无选项，等待点击继续
		_waiting_for_click = true
		if indicator:
			indicator.visible = true

## 显示选项按钮
func _show_options(options: Array[DialogData.DialogOption]) -> void:
	if not option_container:
		return

	_clear_options()

	for i in range(options.size()):
		var option: DialogData.DialogOption = options[i]
		var btn = Button.new()
		btn.text = option.text
		btn.custom_minimum_size = Vector2(200, 40)
		# 添加样式
		btn.add_theme_font_size_override("font_size", 24)
		btn.pressed.connect(_on_option_pressed.bind(i, option))
		option_container.add_child(btn)

## 选项被按下
func _on_option_pressed(index: int, option: DialogData.DialogOption) -> void:
	option_selected.emit(index, option)

	if option.next_id != "":
		_show_entry(option.next_id)
	else:
		end_dialog()

## 点击处理
func _handle_click() -> void:
	if _is_typing:
		# 跳过打字机效果
		if skip_typewriter_on_click:
			if _typewriter_timer and not _typewriter_timer.is_stopped():
				_typewriter_timer.stop()
			if text_label:
				text_label.visible_characters = -1
			_is_typing = false
			var entry = _entries.get(_current_id) as DialogData.DialogEntry
			if entry:
				_on_text_displayed(entry)
	elif _waiting_for_click:
		_advance_dialog()

## 推进对话
func _advance_dialog() -> void:
	var entry = _entries.get(_current_id) as DialogData.DialogEntry
	if entry and entry.next_id != "":
		_show_entry(entry.next_id)
	else:
		end_dialog()

## 清空选项
func _clear_options() -> void:
	if option_container:
		for child in option_container.get_children():
			child.queue_free()

#endregion
