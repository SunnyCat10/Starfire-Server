extends Node

var network : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
const PORT : int = 34684
const MAX_PLAYERS : int = 10

var player_state_collection = {}
var connected_player_list = {}

var remote_player_instance = preload("res://Scenes/Entities/remote_player.tscn")

# Testing:
var lobby_for_testing = {"1" : {"n" : "main test lobby", "g" : "CTF", "c" : 0, "m" : 2},
"2" : {"n" : "another lobby", "g" : "TDM", "c" : 8, "m" : 8},
"3": {"n" : "3rd lobby", "g" : "FFA", "c" : 12, "m" : 12}}
@onready var ctf_lobby = $CTF

@rpc func spawn_new_player(player_id : int, position : Vector2): pass
@rpc func despawn_player(player_id: int): pass
@rpc("unreliable_ordered") func recive_world_state(world_state): pass
@rpc("reliable") func return_server_time(server_time : float, client_time : float): pass
@rpc func return_latency(client_time : float): pass
@rpc("reliable") func receive_attack(position : Vector2, rotation : float, spawn_time : float, player_id : int): pass
@rpc("reliable") func update_ui_player(player_list: Dictionary): pass
@rpc("reliable") func receive_damage(damage: int): pass
@rpc("reliable") func receive_lobby_list(lobby_list): pass
@rpc("reliable") func receive_ctf_start(sorted_player_list, start_time : float): pass
@rpc("reliable") func receive_gamemode_update(packet, event_time : float): pass


func _ready():
	start_server()
	Packets.gamemode_started.connect(send_ctf_start)
	Packets.gamemode_update.connect(send_gamemode_update)


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
		connected_player_list.erase(str(player_id))
		update_ui_player.rpc(connected_player_list)


func send_world_state(world_state):
	for player in ctf_lobby.player_list:
		if multiplayer.get_peers().has(player): # Anti Crash Messure!!!! TODO Add more of those!
			recive_world_state.rpc_id(player, world_state)
# TODO: To gracefully disconect crashed players, run periodic check if all the players in the game
# lobby still connected, if not -> disconect them manually 

func send_damage(player_id: int, damage: int):
	receive_damage.rpc_id(player_id, damage)


func send_ctf_start(sorted_list, start_time : float):
	for player in sorted_list[Packets.CtfTeam.TEAM_A]:
		receive_ctf_start.rpc_id(player, sorted_list, start_time)
	for player in sorted_list[Packets.CtfTeam.TEAM_B]:
		receive_ctf_start.rpc_id(player, sorted_list, start_time)


func send_gamemode_update(sorted_list, packet, event_time : float):
	# print(status_info)
	for player in sorted_list[Packets.CtfTeam.TEAM_A]:
		receive_gamemode_update.rpc_id(player, packet, event_time)
	for player in sorted_list[Packets.CtfTeam.TEAM_B]:
		receive_gamemode_update.rpc_id(player, packet, event_time)


@rpc("any_peer", "unreliable_ordered") func recive_player_state(player_state):
	var player_id : int = multiplayer.get_remote_sender_id()
	player_state_collection[player_id] = player_state


@rpc("any_peer", "reliable") func player_joined_map(player_id : int):
	ctf_lobby.join_lobby(player_id)
	var new_player : Node2D = remote_player_instance.instantiate()
	new_player.name = str(player_id)
	add_child(new_player)
	spawn_new_player.rpc(player_id, Vector2(10,10))	
	connected_player_list[str(player_id)] = new_player
	update_ui_player.rpc(connected_player_list)


@rpc("any_peer", "reliable") func fetch_server_time(client_time : float):
	var player_id : int = multiplayer.get_remote_sender_id()
	return_server_time.rpc_id(player_id, Time.get_unix_time_from_system(), client_time)


@rpc("any_peer") func determine_latency(client_time : float):
	var player_id : int = multiplayer.get_remote_sender_id()
	return_latency.rpc_id(player_id, client_time)


@rpc("any_peer", "reliable") func attack(position : Vector2, rotation : float, client_time : float): 
	var player_id : int = multiplayer.get_remote_sender_id()
	get_node("ServerMap").spawn_attack(position, rotation, client_time, player_id)
	receive_attack.rpc(position, rotation, client_time, player_id)


@rpc("any_peer", "reliable") func get_lobby_list():
	var player_id : int = multiplayer.get_remote_sender_id()
	receive_lobby_list.rpc_id(player_id, lobby_for_testing)

