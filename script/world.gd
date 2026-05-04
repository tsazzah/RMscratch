extends Node3D

var chef_scene = preload("res://scene/chef.tscn")
var wayang_scene = preload("res://scene/WayangNew.tscn")
var spawned_players = {}

func _ready():
	# Set UI location label
	var ui = get_node_or_null("UI")
	if ui:
		ui.set_location(name)
	
	if multiplayer.is_server():
		# ... rest of existing code	if multiplayer.is_server():
		_spawn_player(multiplayer.get_unique_id())
		multiplayer.peer_connected.connect(_spawn_player)
		multiplayer.peer_connected.connect(_sync_existing_players)
	else:
		_spawn_player(multiplayer.get_unique_id())

@rpc("authority", "reliable")
func _spawn_player_rpc(peer_id: int):
	_spawn_player(peer_id)

func _sync_existing_players(new_peer_id: int):
	for existing_id in spawned_players.keys():
		_spawn_player_rpc.rpc_id(new_peer_id, existing_id)

func _spawn_player(peer_id: int):
	if spawned_players.has(peer_id):
		return
	spawned_players[peer_id] = true

	var player
	if peer_id == 1:
		player = wayang_scene.instantiate()
	else:
		player = chef_scene.instantiate()

	player.name = str(peer_id)
	player.set_multiplayer_authority(peer_id)
	$Players.add_child(player, true)

	# Place at spawn point if set
	if peer_id == multiplayer.get_unique_id():
		var spawn_name = GameManager.next_spawn
		if spawn_name != "":
			var spawn = get_node_or_null(spawn_name)
			if spawn:
				player.global_transform = spawn.global_transform
		GameManager.next_spawn = ""

		# Camera follow
		var cam = get_node_or_null("Camera3D")
		if cam:
			cam.target_node = player
