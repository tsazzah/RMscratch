extends CharacterBody3D

const WALK_SPEED = 12.0
const RUN_SPEED = 20.0
const DASH_SPEED = 22.0
const DASH_TIME = 1.375
const LERP_VAL = 0.2

var dash_timer = 0.0
var is_dashing = false

var idle_timer = 0.0
var idleSpecial_played = false

var held_object = null
var nearby_object = null

var original_scale = Vector3.ONE
var hold_scale = Vector3(0.5, 0.5, 0.5) # adjust as needed

@onready var right_hand = get_node_or_null("Chef/Skeleton3D/RightHand_Attach/HoldPoint")
@onready var left_hand = get_node_or_null("Chef/Skeleton3D/LeftHand_Attach/HoldPoint")
@onready var hold_center = get_node_or_null("Chef/Skeleton3D/HoldCenter")

var use_right_hand = true  # toggle if you want later

func _ready():
	if right_hand == null:
		print("❌ Right hand HoldPoint NOT FOUND")
	else:
		print("✅ Right hand ready")

	if left_hand == null:
		print("❌ Left hand HoldPoint NOT FOUND")
	else:
		print("✅ Left hand ready")

func _input(event):
	if event.is_action_pressed("mov_interact"):
		print("E pressed")

		if held_object == null and nearby_object != null:
			pick_up_object()
		elif held_object != null:
			drop_object()
		else:
			print("Nothing to pick up")

func pick_up_object():
	if hold_center == null:
		print("❌ HoldCenter not found")
		return

	held_object = nearby_object

	# Save original scale
	original_scale = held_object.scale

	print("Picking up:", held_object.name)

	held_object.get_parent().remove_child(held_object)
	hold_center.add_child(held_object)

	held_object.transform = Transform3D.IDENTITY
	
	# Apply smaller scale when held
	held_object.scale = hold_scale

	print("✅ Bowl is now held (scaled down)")


func drop_object():
	if held_object == null:
		return

	print("Dropping:", held_object.name)

	var obj = held_object

	hold_center.remove_child(obj)
	get_parent().add_child(obj)

	obj.global_transform.origin = global_transform.origin + Vector3(1, 0, 0)

	# Restore original scale
	obj.scale = original_scale

	held_object = null

	print("🟡 Bowl dropped (scale restored)")

func _physics_process(delta: float) -> void:
	# 1. Gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

	# Ambil AnimationPlayer
	var anim = get_node_or_null("AnimationPlayer")

	# Cek apakah sedang lari
	var is_running = Input.is_action_pressed("mov_run_kitchen")
	
	# Trigger DASH (only once when key is pressed)
	if Input.is_action_just_pressed("mov_run_kitchen") and direction != Vector3.ZERO:
		is_dashing = true
		dash_timer = DASH_TIME
		velocity += direction * 6.0
	
	# Handle dash timer
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	# 3. Logika Gerak & Rotasi
	if direction != Vector3.ZERO:
		idle_timer = 0.0
		idleSpecial_played = false
		# Determine speed
		var current_speed = WALK_SPEED
		if is_dashing:
			current_speed = DASH_SPEED
		elif is_running:
			current_speed = RUN_SPEED

		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

		# Rotasi
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, LERP_VAL)

		# Animations
		if anim:
			# DASH (highest priority)
			if is_dashing and anim.has_animation("Dash"):
				if anim.current_animation != "Dash":
					anim.play("Dash")

			# RUN
			elif is_running and anim.has_animation("Lari Kitchen"):
				# Only switch if dash animation is near the end
				if anim.current_animation == "Dash":
					if anim.current_animation_position >= DASH_TIME:
						anim.play("Lari Kitchen")
				else:
					if anim.current_animation != "Lari Kitchen":
						anim.play("Lari Kitchen")

			# WALK
			elif anim.has_animation("Jalan"):
				if anim.current_animation == "Dash":
					if anim.current_animation_position >= DASH_TIME:
						anim.play("Jalan")
				else:
					if anim.current_animation != "Jalan":
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
				if anim.has_animation("Idle Chef"):
					anim.play("Idle Chef")
					idleSpecial_played = true
					idle_timer = 0.0
			elif not idleSpecial_played:
				if anim.has_animation("Idle Biasa"):	
					anim.play("Idle Biasa")

	# 4. Eksekusi
	move_and_slide()
