extends CharacterBody3D

const SPEED = 8.0
const LERP_VAL = 0.2

func _physics_process(delta: float) -> void:
	# 1. Gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Kita pakai arah dunia (Global), bukan transform.basis agar arahnya tetap
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	# Ambil AnimationPlayer
	var anim = get_node_or_null("AnimationPlayer")

	# 3. Logika Gerak & Rotasi
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		# --- BAGIAN ROTASI HALUS ---
		# atan2 menentukan ke mana Chef harus menghadap berdasarkan input
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, LERP_VAL)
		# ---------------------------

		if anim and anim.has_animation("Lari"):
			anim.play("Lari")
	else:
		# Berhenti perlahan
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if anim and anim.has_animation("Idle"):
			anim.play("Idle")

	# 4. Eksekusi
	move_and_slide()
