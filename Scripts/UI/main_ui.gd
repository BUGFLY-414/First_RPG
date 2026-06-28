extends CanvasLayer

@onready var main_panel: Panel = $Panel
@onready var bag_panel: Panel = $Panel/TabContainer/BagPanel
@onready var character_panel: Panel = $Panel/TabContainer/CharacterPanel

func _unhandled_input(event: InputEvent) -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		#print("场景为空（大概率是加载问题4.7新bug）")   #调试用
		return
	var current := current_scene.name
	if current != "GameWorld" and current != "Level0":
		return

	# ESC 键：仅在菜单可见时关闭
	if event.is_action_pressed("ui_cancel") and visible:
		close()
	# I 键 (toggle_menu)：切换菜单开/关
	elif event.is_action_pressed("toggle_menu"):
		if visible:
			close()
		else:
			open()


func _ready() -> void:
	hide()


func refresh_all() -> void:
	if Global.player == null:
		return

	bag_panel.player = Global.player
	bag_panel.refresh()
	character_panel.refresh()

func open() -> void:
	set_process_unhandled_input(false) # 锁定输入
	refresh_all()
	show()
	await TweenPlayer.fade_in(main_panel).finished
	set_process_unhandled_input(true) # 锁定输入

func close() -> void:
	set_process_unhandled_input(false) # 锁定输入
	await TweenPlayer.fade_out(main_panel).finished
	hide()
	set_process_unhandled_input(true) # 锁定输入

func _on_close_button_pressed() -> void:
	close()

func _on_bag_panel_item_used() -> void:
	refresh_all()
