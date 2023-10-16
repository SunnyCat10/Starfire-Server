extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
const PORT : int = 34684
const MAX_PLAYERS : int = 10

var player_state_collection = {}

@rpc func spawn_new_player(player_id : int, position : Vector2): pass
@rpc func despawn_player(player_id: int): pass
@rpc("unreliable_ordered") func recive_world_state(world_state): pass


func _ready():
	start_server() 


func start_server():
	network.create_server(PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = network
	print("Server started")
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)


func _peer_connected(player_id):
	spawn_new_player.rpc(player_id, Vector2(10,10))
	print("User", str(player_id), "Connected")


func _peer_disconnected(player_id):
	print("User", str(player_id), "Disconnected")
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
		player_state_collection.erase(player_id)
		despawn_player.rpc(player_id)

@rpc("any_peer")
func get_location(location : Vector2):
	print(multiplayer.get_remote_sender_id(), " > ", location)
	

@rpc("any_peer", "unreliable_ordered") func recive_player_state(player_state):
	var player_id : int = multiplayer.get_remote_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state
		
func send_world_state(world_state):
	recive_world_state.rpc(world_state)
