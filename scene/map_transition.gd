extends CanvasLayer

@onready var anim = $AnimationPlayer
@onready var rect = $ColorRect

func _ready():
	rect.color = Color(0, 0, 0, 1)
	rect.modulate = Color(0, 0, 0, 0)

func fade_to_scene(path: String):
	print("FADE START")
	rect.modulate = Color(0, 0, 0, 0)
	anim.play("fade_out")
	await anim.animation_finished
	print("FADE OUT DONE, changing scene to:", path)
	
	if multiplayer.is_server():
		_change_scene_all.rpc(path)
	
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	anim.play("fade_in")

@rpc("authority", "reliable")
func _change_scene_all(path: String):
	get_tree().change_scene_to_file(path)
