extends CharacterBody3D

const SPEED = 8.0
const LERP_VAL = 0.2

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not is_multiplayer_authority():
		move_and_slide()
		return

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	var anim = get_node_or_null("AnimationPlayer")

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, LERP_VAL)
		if anim and anim.has_animation("Jalan 1"):
			anim.play("Jalan 1")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		if anim and anim.has_animation("Idle"):
			anim.play("Idle")

	move_and_slide()

	# Send your position/rotation to everyone else
	_sync_position.rpc(position, rotation)

@rpc("authority", "unreliable")
func _sync_position(pos: Vector3, rot: Vector3):
	position = pos
	rotation = rot
