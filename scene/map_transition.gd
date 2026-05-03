extends CanvasLayer

@onready var anim = $AnimationPlayer

func fade_to_scene(path: String):
	print("FADE START")

	anim.play("fade_out")
	await anim.animation_finished

	get_tree().change_scene_to_file(path)

	await get_tree().process_frame

	anim.play("fade_in")
