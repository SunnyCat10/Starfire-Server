extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
const PORT : int = 34684
const MAX_PLAYERS : int = 10

var player_state_collection = {}

@rpc func spawn_new_player(player_id : int, position : Vector2): pass
@rpc func despawn_player(player_id: int): pass
@rpc("unreliable_ordered") func recive_world_state(world_state): pass
@rpc("reliable") func return_server_time(server_time : float, client_time : float): pass
@rpc func return_latency(client_time : float): pass
@rpc("reliable") func receive_attack(position : Vector2, rotation : float, spawn_time : float, player_id : int): pass


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
	if has_node(str(player_id)):
		get_node(str(player_id)).queue_free()
		player_state_collection.erase(player_id)
		despawn_player.rpc(player_id)
	

@rpc("any_peer", "unreliable_ordered") func recive_player_state(player_state):
	var player_id : int = multiplayer.get_remote_sender_id()
#	if player_state_collection.has(player_id):
#		if player_state_collection[player_id]["T"] < player_state["T"]:
#			player_state_collection[player_id] = player_state
#	else:
#		player_state_collection[player_id] = player_state
	player_state_collection[player_id] = player_state
		
func send_world_state(world_state):
	recive_world_state.rpc(world_state)
	

@rpc("any_peer", "reliable") func player_joined_map(player_id : int):
	var new_player : Node2D = Node2D.new()
	new_player.name = str(player_id)
	add_child(new_player)
	spawn_new_player.rpc(player_id, Vector2(10,10))


@rpc("any_peer", "reliable") func fetch_server_time(client_time : float):
	var player_id : int = multiplayer.get_remote_sender_id()
	return_server_time.rpc_id(player_id, Time.get_unix_time_from_system(), client_time)


@rpc("any_peer") func determine_latency(client_time : float):
	var player_id : int = multiplayer.get_remote_sender_id()
	return_latency.rpc_id(player_id, client_time)


@rpc("any_peer", "reliable") func attack(position : Vector2, rotation : float, client_time : float): 
	var player_id : int = multiplayer.get_remote_sender_id()
	receive_attack.rpc(position, rotation, client_time, player_id)
