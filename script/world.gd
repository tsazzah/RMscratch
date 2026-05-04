extends Node3D

var chef_scene = preload("res://scene/chef.tscn")
var wayang_scene = preload("res://scene/WayangNew.tscn")
var spawned_players = {}

func _ready():
	if multiplayer.is_server():
		_spawn_player(multiplayer.get_unique_id())
		multiplayer.peer_connected.connect(_spawn_player)
	else:
		_spawn_player(multiplayer.get_unique_id())

func _spawn_player(peer_id: int):
	if spawned_players.has(peer_id):
		print("Already spawned, skipping: ", peer_id)
		return
	spawned_players[peer_id] = true
	print("Spawning: ", peer_id)

	# Host gets Chef skin, client gets Wayang skin
	var player
	if peer_id == multiplayer.get_unique_id() and multiplayer.is_server():
		player = chef_scene.instantiate()
	else:
		player = wayang_scene.instantiate()

	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	$Players.add_child(player, true)

	# Camera follows YOUR player only
	if peer_id == multiplayer.get_unique_id():
		var cam = $Camera3D
		if cam:
			cam.target_node = player
