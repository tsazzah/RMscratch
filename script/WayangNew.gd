extends CharacterBody3D

const WALK_SPEED = 12.0
const RUN_SPEED = 20.0
const DASH_SPEED = 22.0
const DASH_TIME = 0.3
const LERP_VAL = 0.2

var dash_timer = 0.0
var is_dashing = false
var idle_timer = 0.0
var idleSpecial_played = false
var held_object = null
var nearby_object = null
var nearby_interactable = null

@onready var right_hand = get_node_or_null("Armature/Skeleton3D/RightHand_Attach/HoldPoint")
@onready var left_hand = get_node_or_null("Armature/Skeleton3D/LeftHand_Attach/HoldPoint")
@onready var hold_center = get_node_or_null("Armature/Skeleton3D/HoldCenter")

var use_right_hand = true

func _ready():
	await get_tree().process_frame
	print("Spawn request:", GameManager.next_spawn)
	var spawn_name = GameManager.next_spawn
	if spawn_name != "":
		var spawn = get_tree().current_scene.get_node_or_null(spawn_name)
		print("Spawn found:", spawn)
		if spawn:
			global_transform = spawn.global_transform
		else:
			print("❌ Spawn NOT FOUND, using default position")
	GameManager.next_spawn = ""

func _input(event):
	if not is_multiplayer_authority():
		return
	if event.is_action_pressed("mov_interact"):
		print("E pressed")
		if nearby_interactable != null:
			print("INTERACTED:", nearby_interactable.name)
			if nearby_interactable.has_method("interact"):
				nearby_interactable.interact(self)
		else:
			print("Nothing to interact with")

func pick_up_object():
	if hold_center == null:
		print("❌ No valid hand to attach object")
		return
	held_object = nearby_object
	print("Picking up:", held_object.name)
	held_object.get_parent().remove_child(held_object)
	hold_center.add_child(held_object)
	held_object.transform = Transform3D.IDENTITY
	print("✅ Bowl is now held")

func drop_object():
	if held_object == null:
		return
	print("Dropping:", held_object.name)
	var obj = held_object
	var hand = right_hand if use_right_hand else left_hand
	hand.remove_child(obj)
	get_parent().add_child(obj)
	obj.global_transform.origin = global_transform.origin + Vector3(1, 0, 0)
	held_object = null
	print("🟡 Bowl dropped")

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	var anim = get_node_or_null("AnimationPlayer")
	var is_running = Input.is_action_pressed("mov_run_kitchen")

	if Input.is_action_just_pressed("mov_run_kitchen") and direction != Vector3.ZERO:
		is_dashing = true
		dash_timer = DASH_TIME
		velocity += direction * 6.0

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	if direction != Vector3.ZERO:
		idle_timer = 0.0
		idleSpecial_played = false

		var current_speed = WALK_SPEED
		if is_dashing:
			current_speed = DASH_SPEED
		elif is_running:
			current_speed = RUN_SPEED

		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, LERP_VAL)

		if anim:
			if is_dashing and anim.has_animation("Dash"):
				if anim.current_animation != "Dash":
					anim.play("Dash")
			elif is_running and anim.has_animation("Lari Kitchen"):
				if anim.current_animation == "Dash":
					if anim.current_animation_position >= DASH_TIME:
						anim.play("Lari Kitchen")
				else:
					if anim.current_animation != "Lari Kitchen":
						anim.play("Lari Kitchen")
			elif anim.has_animation("Jalan"):
				if anim.current_animation == "Dash":
					if anim.current_animation_position >= DASH_TIME:
						anim.play("Jalan")
				else:
					if anim.current_animation != "Jalan":
						anim.play("Jalan")
	else:
		idle_timer += delta
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)

		if anim:
			if idle_timer >= 17.373 and not idleSpecial_played:
				if anim.has_animation("Idle Wayang"):
					anim.play("Idle Wayang")
					idleSpecial_played = true
					idle_timer = 0.0
			elif not idleSpecial_played:
				if anim.has_animation("Idle Biasa"):
					anim.play("Idle Biasa")

	move_and_slide()
	_sync_position.rpc(position, rotation)

@rpc("authority", "unreliable")
func _sync_position(pos: Vector3, rot: Vector3):
	if not is_multiplayer_authority():
		position = pos
		rotation = rot
