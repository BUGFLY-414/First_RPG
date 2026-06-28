## 对话系统使用示例
## 将此脚本挂载到任意节点上，并在场景中添加 DialogSystem 子场景即可使用
## 
## 使用方式：
##   1. 在场景中实例化 Scenes/dialog_system.tscn
##   2. 通过 $DialogSystem 调用对话API
##   3. 也可以通过代码动态创建对话数据

extends Control

## 对话管理器引用
@onready var dialog: DialogManager = $DialogSystem

func _ready() -> void:
	# 连接对话信号
	dialog.dialog_started.connect(_on_dialog_started)
	dialog.dialog_finished.connect(_on_dialog_finished)
	dialog.option_selected.connect(_on_option_selected)
	dialog.dialog_entry_shown.connect(_on_entry_shown)

	# ===== 方式1：从JSON文件加载对话 =====
	# dialog.start_dialog_from_file("res://Data/example_dialog.json")

	# ===== 方式2：通过代码构建对话数据 =====
	var entries = _build_test_dialog()
	dialog.start_dialog(entries, "greeting")

func _build_test_dialog() -> Dictionary:
## 用代码构建对话数据，适合简单或动态生成的对话
	var data = [
		{
			"id": "greeting",
			"speaker": "村长",
			"text": "欢迎来到新手村！你是新来的冒险者吧？",
			"next_id": "greeting_2"
		},
		{
			"id": "greeting_2",
			"speaker": "村长",
			"text": "村外最近出现了不少怪物，大家都很害怕。",
			"options": [
				{"text": "我来帮忙消灭怪物！", "next_id": "accept_quest"},
				{"text": "告诉我更多关于怪物的事", "next_id": "monster_info"},
				{"text": "我只是路过的", "next_id": "pass_by"}
			]
		},
		{
			"id": "accept_quest",
			"speaker": "村长",
			"text": "太好了！村外的史莱姆最近变得很凶暴，请务必小心。",
			"next_id": "accept_quest_2"
		},
		{
			"id": "accept_quest_2",
			"speaker": "村长",
			"text": "这是村里的一点心意，拿着这把铁剑出发吧！",
			"next_id": ""
		},
		{
			"id": "monster_info",
			"speaker": "村长",
			"text": "大约一周前，村子北方的森林里开始出现史莱姆。",
			"next_id": "monster_info_2"
		},
		{
			"id": "monster_info_2",
			"speaker": "村长",
			"text": "它们以前很温顺，但最近不知为何变得攻击性很强。",
			"options": [
				{"text": "我来帮忙消灭怪物！", "next_id": "accept_quest"},
				{"text": "听起来很奇怪，我先去调查一下", "next_id": "investigate"}
			]
		},
		{
			"id": "pass_by",
			"speaker": "村长",
			"text": "这样啊……如果你改变主意了，随时来找我。",
			"next_id": ""
		},
		{
			"id": "investigate",
			"speaker": "村长",
			"text": "调查？你是个细心的人。如果发现什么线索，请告诉我。",
			"next_id": ""
		}
	]
	return DialogData.load_from_dict(data)

#region 信号回调

func _on_dialog_started() -> void:
	print("对话开始")

func _on_dialog_finished() -> void:
	print("对话结束")

func _on_option_selected(index: int, option: DialogData.DialogOption) -> void:
	print("选择了选项 %d: %s" % [index, option.text])

func _on_entry_shown(entry: DialogData.DialogEntry) -> void:
	print("%s: %s" % [entry.speaker, entry.text])

#endregion


#region ===== 高级用法示例 =====

## 在运行时动态修改对话数据
func _add_dynamic_dialog() -> void:
## 演示如何动态添加对话条目
	var new_entry_data = {
		"id": "dynamic_1",
		"speaker": "神秘声音",
		"text": "这是一个在运行时动态添加的对话！",
		"next_id": ""
	}
	var new_entry = DialogData.DialogEntry.new(new_entry_data)
	# 如果你有对话管理器的entries引用，可以直接添加

## 在代码中直接构建单条对话（最简方式）
func _show_simple_dialog() -> void:
## 最简单的对话：只有一条，没有选项
	var simple_data = [
		{
			"id": "simple",
			"speaker": "路牌",
			"text": "前方为新手村，请小心行事。",
			"next_id": ""
		}
	]
	var entries = DialogData.load_from_dict(simple_data)
	dialog.start_dialog(entries, "simple")

## 链式对话（无选项，自动推进）
func _show_chain_dialog() -> void:
## 无选项的链式对话，点击自动推进
	var chain_data = [
		{"id": "c1", "speaker": "旁白", "text": "你走进了一片黑暗的森林……", "next_id": "c2"},
		{"id": "c2", "speaker": "旁白", "text": "四周静悄悄的，只有风吹过树叶的声音。", "next_id": "c3"},
		{"id": "c3", "speaker": "???", "text": "……有人吗？", "next_id": ""}
	]
	var entries = DialogData.load_from_dict(chain_data)
	dialog.start_dialog(entries, "c1")

#endregion
