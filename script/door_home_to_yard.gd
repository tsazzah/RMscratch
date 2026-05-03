extends Node3D

@export var target_scene: String
@export var spawn_point_name: String = "SpawnPoint"

var player_inside = false

func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true
		print("🚪 Player near door")

func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		print("🚪 Player left door")

func _input(event):
	if player_inside and event.is_action_pressed("mov_interact"):
		print("🔄 Changing scene to:", target_scene)
		get_tree().change_scene_to_file(target_scene)
