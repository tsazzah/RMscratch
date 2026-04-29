extends Node3D

@export var target_scene: String = ""
@export var spawn_point_name: String = ""

var triggered := false

func _on_area_3d_body_entered(body):
	print("ENTER:", body.name)

	if triggered:
		return

	if not body.is_in_group("player"):
		return

	triggered = true

	print("🚪 Door triggered")
	print("→ Target scene:", target_scene)
	print("→ Spawn name:", spawn_point_name)

	GameManager.next_spawn = spawn_point_name

	MapTransition.fade_to_scene(target_scene)
