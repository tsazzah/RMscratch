extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ui = get_node("UI")
	ui.set_location("Yard")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
