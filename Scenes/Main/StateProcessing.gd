extends Node

var world_state = {}
var sync_clock_counter = 0
@onready var server : Node = get_parent()

func _physics_process(delta):
	
#	sync_clock_counter += 1
#	if sync_clock_counter == 3:
#		sync_clock_counter= 0
		if not server.player_state_collection.is_empty():
			world_state = server.player_state_collection.duplicate(true)
			for player in world_state.keys():
				world_state[player].erase("T")
			world_state["T"] = Time.get_unix_time_from_system()
			# Verification
			# Anti-Cheat
			# Cuts ( chunking / maps )
			# Physics checks
			# Anything else :D
			
			server.send_world_state(world_state)
			update_players_collision_position(world_state)
			

func update_players_collision_position(world_state):
	var current_player_list = server.connected_player_list
	for key in current_player_list:
		if int(key) in world_state:# TODO remove when adding spawning system (the initial world_state of players recieved from clients)
#			print(world_state)
	#		print(key)
	#		print(current_player_list)
			var player_node : Node2D= current_player_list[key]
			var player_world_state = world_state[int(key)]
			player_node.position = player_world_state["P"]
			player_node.rotation = player_world_state["R"]
		
		
#	print(world_state)
