extends Node3D

@export var target_scene: String
@export var spawn_point_name: String = "Spawn_from_Home"

var can_trigger = false

func _ready():
	await get_tree().create_timer(1.0).timeout
	can_trigger = true

func _on_area_3d_body_entered(body):
	if not can_trigger:
		return
	if not body.is_in_group("player"):
		return
	if not body.is_multiplayer_authority():
		return
	can_trigger = false
	GameManager.next_spawn = spawn_point_name
	MapTransition.fade_to_scene(target_scene)

func _on_area_3d_body_exited(body):
	pass
