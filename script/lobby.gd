extends Control

@onready var ip_field = $VBoxContainer/LineEdit
@onready var status_label = $VBoxContainer/Label2

func _ready():
	print("Lobby ready!")
	await get_tree().process_frame
	$VBoxContainer/Button.grab_focus()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			var focused = get_viewport().gui_get_focus_owner()
			if focused == $VBoxContainer/Button:
				_on_host_button_pressed()
			elif focused == $VBoxContainer/Button2:
				_on_join_button_pressed()
		elif event.keycode == KEY_TAB:
			var focused = get_viewport().gui_get_focus_owner()
			if focused == $VBoxContainer/Button:
				$VBoxContainer/LineEdit.grab_focus()
			elif focused == $VBoxContainer/LineEdit:
				$VBoxContainer/Button2.grab_focus()
			elif focused == $VBoxContainer/Button2:
				$VBoxContainer/Button.grab_focus()

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
	get_tree().change_scene_to_file("res://scene/Home.tscn")
