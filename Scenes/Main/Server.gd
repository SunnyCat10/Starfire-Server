extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
const PORT : int = 34684
const MAX_PLAYERS : int = 10


func _ready():
	start_server() 

func start_server():
	network.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = network
	print("Server started")
	
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	

func _peer_connected(player_id):
	print("User", str(player_id), "Connected")
	
func _peer_disconnected(player_id):
	print("User", str(player_id), "Disconnected")


@rpc("any_peer")
func get_location(location : Vector2):
	print(multiplayer.get_remote_sender_id(), " > ", location)
