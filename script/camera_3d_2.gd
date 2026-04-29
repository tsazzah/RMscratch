extends Camera3D

@export var target_node : Node3D # Tempat menaruh karakter 'Jalan_'
@export var offset : Vector3 = Vector3(-5, 4, 6) # Jarak tetap kamera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target_node:
		# Kamera mengikuti posisi karakter + jarak offset
		global_position = target_node.global_position + offset
		# Kamera selalu melihat ke arah karakter
		look_at(target_node.global_position)
