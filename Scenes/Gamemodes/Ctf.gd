extends Node

const TEAM_A : int = 0
const TEAM_B : int = 1
const MATCH_COOLDOWN_TIME : float = 3.0
const FLAGPOLE_IDENTIFIER : String = "Flagpole"
const SPAWNER_IDENTIFIER : String = "Spawner"
const RESPAWN_TIME : float = 5.0
const NO_SPAWN_DELAY : float = 0.0

@onready var objectives : Node = get_parent().get_node("ServerMap/Objectives")

var lobby_id : int # maybe uneeded?

var player_list = []
var sorted_list = {}

var ally_score : int = 0
var enemy_score : int = 0
var timer : Timer
var _max_players : int = 2 # TODO: change to 0 once lobby creation is ready
var current_players : int = 0

var flag_list = []
var spawner_list = {Packets.CtfTeam.TEAM_A : [], Packets.CtfTeam.TEAM_B : []}
var random = RandomNumberGenerator.new()

var game_running : bool = false

# TODO: Implement lobby creation from server!
#func setup_game(max_players : int, match_duration : int):
#	print("SET UP THE LOBBY!")
#	_max_players = max_players


func start_game() -> void:
	print("Game started!")
	setup_flags() # TODO: Move to setup_game
	game_running = true
	sort_teams()
	var starting_time : float = Packets.server_time() + MATCH_COOLDOWN_TIME
	Packets.gamemode_started.emit(sorted_list, starting_time)
	await get_tree().create_timer(MATCH_COOLDOWN_TIME).timeout
	setup_player_manager() # FOR NOW -> Remove after spawn system implementation
	setup_spawners()
	spawn_all_players()


func end_game():
	pass


func update_score():
	pass


func join_lobby(player_id : int) -> void:
	print("Player joined!!!")
	if not game_running or current_players == _max_players:
		player_list.append(player_id)
		current_players = current_players + 1
		if current_players == _max_players:
			start_game()


func sort_teams() -> void:
	sorted_list[Packets.CtfTeam.TEAM_A] = {}
	sorted_list[Packets.CtfTeam.TEAM_B] = {}
	var first_team : bool = true
	for player in player_list:
		if first_team:
			sorted_list[Packets.CtfTeam.TEAM_A][player] = null
		else:
			sorted_list[Packets.CtfTeam.TEAM_B][player] = null
		first_team = not first_team


func setup_player_manager() -> void:
	var remote_player : Node2D
	for player in sorted_list[Packets.CtfTeam.TEAM_A]:
		# TODO: Initiate remote player here!
		remote_player = get_parent().get_node(str(player))
		remote_player.flag_manager.setup_manager(Packets.CtfTeam.TEAM_A)
		sorted_list[TEAM_A][player] = remote_player
	for player in sorted_list[Packets.CtfTeam.TEAM_B]:
		# TODO: Initiate remote player here!
		remote_player = get_parent().get_node(str(player))
		remote_player.flag_manager.setup_manager(Packets.CtfTeam.TEAM_B)
		sorted_list[TEAM_B][player] = remote_player


func setup_spawners() -> void:
	for objective in objectives.get_children():
		if objective.name.contains(SPAWNER_IDENTIFIER):
			if objective.team_id == Packets.CtfTeam.TEAM_A:
				spawner_list[Packets.CtfTeam.TEAM_A].append(objective.global_position)
			if objective.team_id == Packets.CtfTeam.TEAM_B:
				spawner_list[Packets.CtfTeam.TEAM_B].append(objective.global_position)


func setup_flags() -> void:
	var flag_id : int = 0
	for objective in objectives.get_children():
		if objective.name.contains(FLAGPOLE_IDENTIFIER):
			objective.setup_flag()
			objective.flag_picked.connect(on_pickup_flag)
#			objective.flag_returned.connect(on_return_flag)
			objective.flag_captured.connect(on_capture_flag)
			flag_list.append(objective)
			objective.id = flag_id
			flag_id = flag_id + 1


func get_spawn_location(team_id : int) -> Vector2:
	var spawners
	if team_id == Packets.CtfTeam.TEAM_A:
		spawners = spawner_list[Packets.CtfTeam.TEAM_A]
	if team_id == Packets.CtfTeam.TEAM_B:
		spawners = spawner_list[Packets.CtfTeam.TEAM_B]
	var index : int = random.randf_range(0, spawners.size() - 1)
	return spawners[index]

# can be turned into one function:

func on_pickup_flag(player_id : int, flag_id : int) -> void:
	var packet = [Packets.Type.PICKUP_FLAG, player_id, flag_id]
	Packets.gamemode_update.emit(sorted_list, packet, Packets.server_time())


#func on_return_flag(team_id : int):
#	var packet = ["", team_id, Packets.FlagStatus.FLAG_DROPPED]
#	Packets.gamemode_update.emit(sorted_list, packet, Time.get_unix_time_from_system())


#func on_capture_flag(team_id : int):
func on_capture_flag(player_id : int, flag_id : int) -> void:
	var packet = [Packets.Type.CAPTURE_FLAG, player_id, flag_id]
	Packets.gamemode_update.emit(sorted_list, packet, Packets.server_time())


func spawn_all_players() -> void:
	var spawn_location : Vector2
	var player_id : int
	for player in sorted_list[TEAM_A]:
		print("A")
		spawn_player(sorted_list[TEAM_A][player], TEAM_A, NO_SPAWN_DELAY)
	for player in sorted_list[TEAM_B]:
		print("B")
		spawn_player(sorted_list[TEAM_B][player], TEAM_B, NO_SPAWN_DELAY)


func spawn_player(player : Node2D, team_id : int, spawn_delay : float) -> void:
	var spawn_location : Vector2 = get_spawn_location(team_id)
	var packet = [Packets.Type.SPAWN_PLAYER, player.name.to_int(), spawn_location]
	print(packet)
	Packets.gamemode_update.emit(sorted_list, packet, Packets.server_time() + spawn_delay)
	if not spawn_delay == 0.0:
		await get_tree().create_timer(spawn_delay).timeout
	player.spawn(spawn_location)


func on_player_death(player_id : int) -> void:
	var spawn_location : Vector2
	var player : Node2D
	if player_id in sorted_list[TEAM_A].keys():
		spawn_location = get_spawn_location(TEAM_A)
		player = sorted_list[TEAM_A][player_id]
	elif player_id in sorted_list[TEAM_B].keys():
		spawn_location = get_spawn_location(TEAM_B)
		player = sorted_list[TEAM_B][player_id]
	else:
		pass
	var packet = [Packets.Type.PLAYER_DEATH, player_id]
	Packets.gamemode_update.emit(sorted_list, packet, Packets.server_time())
	packet = [Packets.Type.SPAWN_PLAYER, player_id, spawn_location]
	Packets.gamemode_update.emit(sorted_list, packet, Packets.server_time() + RESPAWN_TIME)
	await get_tree().create_timer(RESPAWN_TIME).timeout
	player.spawn(spawn_location)
	
