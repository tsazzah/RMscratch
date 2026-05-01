extends Node2D

@onready var ip_field = $VBoxContainer/LineEdit
@onready var status_label = $VBoxContainer/Label2

func _on_host_button_pressed():
	NetworkManager.host_game()
	var ips = []
	for addr in IP.get_local_addresses():
		if addr.begins_with("192.168.") or addr.begins_with("10."):
			ips.append(addr)
	_start_game()

func _on_join_button_pressed():
	NetworkManager.join_game(ip_field.text.strip_edges())
	status_label.text = "Connecting..."
	multiplayer.connected_to_server.connect(func(): _start_game())

func _start_game():
	get_tree().change_scene_to_file("res://scene/World.tscn")
