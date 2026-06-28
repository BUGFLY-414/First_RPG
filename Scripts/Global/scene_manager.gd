##控制转场

extends CanvasLayer


@onready var color_rect: ColorRect = $ColorRect
#region 场景变换
func change_scene_with_fade(path:String) -> void:
	layer = 10
	
	color_rect.show()
	
	var tween := create_tween()
	tween.tween_property(color_rect,"color:a",1.0,0.3)
	await tween.finished
	
	await change_scene_astnc(path)
	
	var tween_out := create_tween()
	tween_out.tween_property(color_rect,"color:a",0.0,0.3)
	
	await tween_out.finished
	
	color_rect.hide()

func change_scene_astnc(path:String)->void:
	ResourceLoader.load_threaded_request(path)
	
	while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().create_timer(0.05).timeout
	
	if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(path))
	elif ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_FAILED or ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		#get_tree().change_scene_to_file("res://场景/加载报错.tscn")   #后期换成报错场景
		print("加载失败")

func change_scene_with_fade_in(path:String) -> void:
	layer = 10
	
	color_rect.show()
	
	var tween := create_tween()
	tween.tween_property(color_rect,"color:a",1.0,0.3)
	await tween.finished
	
	await change_scene_astnc(path)
	
	color_rect.hide()

func change_scene_with_fade_out(path:String) -> void:
	layer = 10
	
	color_rect.show()
	
	await change_scene_astnc(path)
	
	var tween := create_tween()
	tween.tween_property(color_rect,"color:a",1.0,0.01)
	await tween.finished
	var tween_out := create_tween()
	tween_out.tween_property(color_rect,"color:a",0.0,0.3)
	
	await tween_out.finished
	
	color_rect.hide()

#endregion

#region 变换
#效果：屏幕闪黑
##淡入黑屏，等待一段时间，然后淡出 [br]
##[code] trans_duration [/code] : 淡入淡出花费的时间 [br]
##[code] black_duration [/code]：黑屏等待的时间 [br]
func transform_with_fade(trans_duration:float = 0.3,black_duration:float = 1):
	layer = 10
	
	color_rect.show()
	
	var tween := create_tween()
	tween.tween_property(color_rect,"color:a",1.0,trans_duration)
	await tween.finished
	
	await get_tree().create_timer(black_duration).timeout
	
	var tween_out := create_tween()
	tween_out.tween_property(color_rect,"color:a",0.0,trans_duration)
	
	await tween_out.finished
	
	color_rect.hide()
#效果：变黑后淡出
func transform_with_fade_out():
	layer = 10
	
	color_rect.show()
	
	var tween := create_tween()
	tween.tween_property(color_rect,"color:a",1.0,0.01)
	await tween.finished
	
	var tween_out := create_tween()
	tween_out.tween_property(color_rect,"color:a",0.0,0.3)
	
	await tween_out.finished
	

#endregion
