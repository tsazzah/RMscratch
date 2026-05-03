extends Node3D

@export var target_scene: String = ""
@export var spawn_point_name: String = ""

var triggered := false


func _on_area_3d_body_entered(body):
	print("ENTER:", body.name)

	if triggered:
		print("Already triggered")
		return

	print("Is player?", body.is_in_group("player"))

	if not body.is_in_group("player"):
		return

	triggered = true

	print("🚪 Door triggered →", target_scene)

	GameManager.next_spawn = spawn_point_name

	var err = get_tree().change_scene_to_file(target_scene)
	print("Scene change result:", err)
	MapTransition.fade_to_scene(target_scene)

func _on_area_3d_body_exited(body: Node3D) -> void:
	pass # Replace with function body.
