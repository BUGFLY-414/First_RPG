# TweenPlayer.gd
# 全局单例（自动加载），提供简单的 UI 动效
# 适用于 Godot 4.6.3，使用 tab 缩进

extends Node

## 淡入效果（从透明到完全不透明）
## @param node: 需要执行动画的 CanvasItem（如 Control, Node2D）
## @param duration: 动画时长（秒）
## @return Tween 对象，可用于链式调用或监听完成信号
func fade_in(node: CanvasItem, duration: float = 0.2) -> Tween:
	# 确保起始透明度为 0
	node.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", 1.0, duration)
	return tween

## 淡出效果（从完全不透明到透明）
## @param node: 需要执行动画的 CanvasItem
## @param duration: 动画时长（秒）
## @return Tween 对象
func fade_out(node: CanvasItem, duration: float = 0.2) -> Tween:
	node.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	return tween

## 移动效果（改变 position 属性）
## @param node: 具有 position 属性的 Node2D 或 Control
## @param target_position: 目标位置（全局或局部坐标取决于 node）
## @param duration: 动画时长（秒）
## @return Tween 对象
func move(node: Node2D, target_position: Vector2, duration: float = 0.3) -> Tween:
	var tween := create_tween()
	tween.tween_property(node, "position", target_position, duration)
	return tween

## 缩放效果（改变 scale 属性）
## @param node: 具有 scale 属性的 Node2D 或 Control
## @param target_scale: 目标缩放值（例如 Vector2(1.5, 1.5)）
## @param duration: 动画时长（秒）
## @return Tween 对象
func scale(node: Node2D, target_scale: Vector2, duration: float = 0.2) -> Tween:
	var tween := create_tween()
	tween.tween_property(node, "scale", target_scale, duration)
	return tween

## 弹跳缩放效果（先放大超过目标值，再回弹到原始大小）
## @param node: 具有 scale 属性的 Node2D 或 Control
## @param duration: 整个动画时长（秒）
## @param overshoot: 放大倍数（例如 1.2 表示放大到原始大小的 1.2 倍）
## @return Tween 对象
func bounce_scale(node: Node2D, duration: float = 0.3, overshoot: float = 1.2) -> Tween:
	var original_scale := node.scale
	var tween := create_tween()
	# 第一阶段：放大到 overshoot 倍
	tween.tween_property(node, "scale", original_scale * overshoot, duration * 0.5)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	# 第二阶段：回弹到原始大小
	tween.tween_property(node, "scale", original_scale, duration * 0.5)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	return tween

## 快速抖动效果（适用于按钮点击反馈）
## @param node: 具有 position 属性的 Node2D 或 Control
## @param strength: 抖动幅度（像素）
## @param duration: 动画时长（秒）
## @return Tween 对象
func shake(node: Node2D, strength: float = 5.0, duration: float = 0.2) -> Tween:
	var original_pos := node.position
	var tween := create_tween()
	# 随机抖动多次
	for i in range(6):
		var offset := Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tween.tween_property(node, "position", original_pos + offset, duration / 6.0)\
				.set_ease(Tween.EASE_IN_OUT)
	# 最后回到原位
	tween.tween_property(node, "position", original_pos, duration / 6.0)
	return tween
