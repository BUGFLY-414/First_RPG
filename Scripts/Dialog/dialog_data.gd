## 对话数据定义类
## 每一条对话包含：说话人、文本内容、选项列表
## 选项可以跳转到指定的下一条对话ID，实现分支对话

class_name DialogData

## 单条对话条目
class DialogEntry:
	var id: String           ## 唯一标识符，如 "start", "branch_1"
	var speaker: String      ## 说话人名称
	var text: String         ## 对话文本（支持BBCode）
	var options: Array[DialogOption]  ## 选项列表，为空则表示对话结束
	var next_id: String      ## 无选项时自动跳转的下一句ID，空则结束
	var portrait: String	 ## 头像路径（可选）
	var bg: String      ## 背景图片路径（可选）
	var bg_position: Vector2 = Vector2(0, 0)  # 背景位置（实际上只是一张图片
	var condition: String    ## 条件表达式（可选，预留）

	func _init(data: Dictionary = {}):
		id = data.get("id", "")
		speaker = data.get("speaker", "")
		text = data.get("text", "")
		next_id = data.get("next_id", "")
		portrait = data.get("portrait", "")
		bg = data.get("bg", "")
		bg_position = data.get("bg_position", Vector2(0, 0))
		condition = data.get("condition", "")
		options.clear()
		for opt_data in data.get("options", []):
			options.append(DialogOption.new(opt_data))

## 对话选项
class DialogOption:
	var text: String         ## 选项文本
	var next_id: String      ## 选择后跳转的对话ID
	var condition: String    ## 显示条件（可选，预留）
	var effect: String       ## 选择后的效果（可选，预留）

	func _init(data: Dictionary = {}):
		text = data.get("text", "")
		next_id = data.get("next_id", "")
		condition = data.get("condition", "")
		effect = data.get("effect", "")

## 从JSON字典数组加载对话数据，返回以id为key的字典
static func load_from_dict(data_array: Array) -> Dictionary:
	var entries: Dictionary = {}
	for item in data_array:
		var entry = DialogEntry.new(item)
		if entry.id != "":
			entries[entry.id] = entry
	return entries

## 从JSON文件加载对话数据
static func load_from_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		push_error("对话文件不存在: " + file_path)
		return {}
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("无法打开对话文件: " + file_path)
		return {}
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("JSON解析错误: " + json.get_error_message())
		return {}

	var data = json.data
	if data is Array:
		return load_from_dict(data)
	elif data is Dictionary and data.has("dialogs"):
		return load_from_dict(data["dialogs"])
	else:
		push_error("对话数据格式不正确")
		return {}
