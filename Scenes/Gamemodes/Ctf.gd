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
var flag_drop_list = [null, null] # We don`t really use this

var game_running : bool = false


func _ready():
	Events.OnItemPickup.connect(on_flag_pickup)


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
		setup_player(player, TEAM_A, sorted_list)
	for player in sorted_list[Packets.CtfTeam.TEAM_B]:
		setup_player(player, TEAM_B, sorted_list)


func setup_player(player_id : int, player_team : int, player_list) -> void:
	# TODO: Initiate remote player here!
	var remote_player : Node2D = get_parent().get_node(str(player_id))
	remote_player.flag_manager.setup_manager(player_team)
	remote_player.flag_manager.flag_dropped.connect(on_flag_drop)
	player_list[player_team][player_id] = remote_player
	remote_player.died.connect(on_player_death)


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
			# objective.flag_returned.connect(on_return_flag)
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


func on_flag_pickup(item_type : int, item_id : int, player_id : int) -> void:
	var packet = [Packets.Type.PICKUP_ITEM, Packets.ItemType.FLAG, item_id, player_id]
	Packets.gamemode_update.emit(sorted_list, packet, Packets.server_time())


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


func player_death(player_id : int) -> void:
	var packet = [Packets.Type.PLAYER_DEATH, player_id]
	Packets.gamemode_update.emit(sorted_list, packet, Packets.server_time())


func on_player_death(player_id : int) -> void:
	player_death(player_id)
	
	var player : Node2D
	var team_id : int
	if player_id in sorted_list[TEAM_A].keys():
		player = sorted_list[TEAM_A][player_id]
		team_id = TEAM_A
	elif player_id in sorted_list[TEAM_B].keys():
		player = sorted_list[TEAM_B][player_id]
		team_id = TEAM_B
	else:
		pass
	
	spawn_player(player, team_id, RESPAWN_TIME)


func on_flag_drop(player_id : int, flag_drop : Node2D) -> void:
	var item_id : int
	if flag_drop._flag_team_id == TEAM_A:
		flag_drop_list[TEAM_A] = flag_drop
		item_id = TEAM_A
	elif flag_drop._flag_team_id == TEAM_B:
		flag_drop_list[TEAM_B] = flag_drop
		item_id = TEAM_B
	else:
		pass
	
	var packet = [Packets.Type.DROP_ITEM, 0, item_id, flag_drop.global_position, player_id]
	Packets.gamemode_update.emit(sorted_list, packet, Packets.server_time())
