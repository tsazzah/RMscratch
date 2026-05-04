extends Node2D

@onready var ip_field = $VBoxContainer/LineEdit
@onready var status_label = $VBoxContainer/Label2

func _ready():
	print("Lobby ready!")

func _on_host_button_pressed():
	print("Host pressed!")
	NetworkManager.host_game()
	_start_game()

func _on_join_button_pressed():
	print("Join pressed!")
	var ip = ip_field.text.strip_edges()
	if ip == "":
		if status_label:
			status_label.text = "Enter an IP!"
		return
	NetworkManager.join_game(ip)
	if status_label:
		status_label.text = "Connecting..."
	multiplayer.connected_to_server.connect(func(): _start_game())

func _start_game():
	get_tree().change_scene_to_file("res://scene/World.tscn")
