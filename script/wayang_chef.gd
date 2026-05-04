extends CharacterBody3D

const WALK_SPEED = 8.0
const RUN_SPEED = 14.0
const LERP_VAL = 0.2

var idle_timer = 0.0
var idleSpecial_played = false

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		move_and_slide()
		return
	# ... rest of existing code unchanged
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	# Ambil AnimationPlayer
	var anim = get_node_or_null("AnimationPlayer")

	# Cek apakah sedang lari
	var is_running = Input.is_action_pressed("mov_run_kitchen")
	var current_speed = RUN_SPEED if is_running else WALK_SPEED

	# 3. Logika Gerak & Rotasi
	if direction != Vector3.ZERO:
		# Reset idle timer
		idle_timer = 0.0
		
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		# Rotasi halus
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, LERP_VAL)

		# Animasi jalan / lari
		if anim:
			if is_running and anim.has_animation("Lari Lobby_001"):
				anim.play("Lari Lobby_001")
			elif anim.has_animation("Jalan"):
				anim.play("Jalan")

	else:
		# Tambah idle timer
		idle_timer += delta
		
		# Berhenti perlahan
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)

		# Animasi idle
		if anim:
			if idle_timer >= 17.373 and not idleSpecial_played:
				if anim.has_animation("Idle Wayang"):
					anim.play("Idle Wayang")
					idleSpecial_played = true
					idle_timer = 0.0
			elif not idleSpecial_played:
				if anim.has_animation("Idle Biasa"):	
					anim.play("Idle Biasa")

	# 4. Eksekusi
	move_and_slide()
