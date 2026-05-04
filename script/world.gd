extends Node3D

var chef_scene = preload("res://scene/chef.tscn")
var wayang_scene = preload("res://scene/WayangNew.tscn")
var spawned_players = {}

func _ready():
	if multiplayer.is_server():
		_spawn_player(multiplayer.get_unique_id())
		multiplayer.peer_connected.connect(_spawn_player)
		multiplayer.peer_connected.connect(_sync_existing_players)
	else:
		_spawn_player(multiplayer.get_unique_id())

@rpc("authority", "reliable")
func _spawn_player_rpc(peer_id: int):
	_spawn_player(peer_id)

func _sync_existing_players(new_peer_id: int):
	# Tell new client to spawn all already existing players
	for existing_id in spawned_players.keys():
		_spawn_player_rpc.rpc_id(new_peer_id, existing_id)

func _spawn_player(peer_id: int):
	if spawned_players.has(peer_id):
		print("Already spawned, skipping: ", peer_id)
		return
	spawned_players[peer_id] = true
	print("Spawning: ", peer_id)

	var player
	if peer_id == 1:
		player = wayang_scene.instantiate()
	else:
		player = chef_scene.instantiate()

	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	$Players.add_child(player, true)

	if peer_id == multiplayer.get_unique_id():
		var cam = $Camera3D
		if cam:
			cam.target_node = player
