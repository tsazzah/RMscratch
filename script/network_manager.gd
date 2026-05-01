extends Node

const PORT = 7000
const MAX_PLAYERS = 4

func host_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_PLAYERS)
	print("Server create error code: ", error)  # should print 0 if OK
	multiplayer.multiplayer_peer = peer
	print("Hosting on port ", PORT)

func join_game(ip: String):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, PORT)
	print("Client create error code: ", error)  # should print 0 if OK
	multiplayer.multiplayer_peer = peer
	print("Joining ", ip)

func _ready():
	multiplayer.peer_connected.connect(func(id): print("Peer connected: ", id))
	multiplayer.peer_disconnected.connect(func(id): print("Peer disconnected: ", id))
	multiplayer.connected_to_server.connect(func(): print("Connected to server!"))
	multiplayer.connection_failed.connect(func(): print("CONNECTION FAILED"))
	multiplayer.server_disconnected.connect(func(): print("Server disconnected"))
	
