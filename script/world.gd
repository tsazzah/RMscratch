extends Node3D

var player_scene = preload("res://scene/PlayerChef.tscn")
var spawned_players = {}  # track who's already spawned

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
	var player = player_scene.instantiate()
	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	$Players.add_child(player, true)
