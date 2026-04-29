extends Control

@onready var label = $CanvasLayer/LocLabel

func set_location(name):
	label.text = "Location: " + name
