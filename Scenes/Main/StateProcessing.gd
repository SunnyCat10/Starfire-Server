extends Node

var world_state = {}

@onready var server : Node = get_parent()

func _physics_process(delta):
	if not server.player_state_collection.is_empty():
		world_state = server.player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("T")
		world_state["T"] = Time.get_unix_time_from_datetime_string(Time.get_time_string_from_system())
		# Verification
		# Anti-Cheat
		# Cuts ( chunking / maps )
		# Physics checks
		# Anything else :D
		server.send_world_state(world_state)