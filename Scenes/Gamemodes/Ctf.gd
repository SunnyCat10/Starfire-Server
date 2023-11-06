extends Node

const MATCH_COOLDOWN_TIME : float = 3.0
const FLAGPOLE_IDENTIFIER : String = "Flagpole"

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

var game_running : bool = false

# TODO: Implement lobby creation from server!
#func setup_game(max_players : int, match_duration : int):
#	print("SET UP THE LOBBY!")
#	_max_players = max_players


func start_game():
	print("Game started!")
	setup_flags() # TODO: Move to setup_game
	game_running = true
	sort_teams()
	var starting_time : float = Time.get_unix_time_from_system() + MATCH_COOLDOWN_TIME
	Packets.gamemode_started.emit(sorted_list, starting_time)
	await get_tree().create_timer(MATCH_COOLDOWN_TIME).timeout
	setup_player_manager() # FOR NOW -> Remove after spawn system implementation


func end_game():
	pass


func update_score():
	pass


func join_lobby(player_id : int):
	print("Player joined!!!")
	if not game_running or current_players == _max_players:
		player_list.append(player_id)
		current_players = current_players + 1
		if current_players == _max_players:
			start_game()


func sort_teams():
	sorted_list[Packets.CtfTeam.TEAM_A] = {}
	sorted_list[Packets.CtfTeam.TEAM_B] = {}
	var first_team : bool = true
	for player in player_list:
		if first_team:
			sorted_list[Packets.CtfTeam.TEAM_A][player] = null
		else:
			sorted_list[Packets.CtfTeam.TEAM_B][player] = null
		first_team = not first_team


func setup_player_manager():
	for player in sorted_list[Packets.CtfTeam.TEAM_A]:
		# TODO: Initiate remote player here!
		get_parent().get_node(str(player)).flag_manager.setup_manager(Packets.CtfTeam.TEAM_A)
	for player in sorted_list[Packets.CtfTeam.TEAM_B]:
		# TODO: Initiate remote player here!
		get_parent().get_node(str(player)).flag_manager.setup_manager(Packets.CtfTeam.TEAM_B)


func setup_flags():
	var flag_id : int = 0
	for objective in objectives.get_children():
		if objective.name.contains(FLAGPOLE_IDENTIFIER):
			objective.setup_flag()
			objective.flag_picked.connect(on_pickup_flag)
#			objective.flag_returned.connect(on_return_flag)
#			objective.flag_captured.connect(on_capture_flag)
			flag_list.append(objective)
			objective.id = flag_id
			flag_id = flag_id + 1


# can be turned into one function:

func on_pickup_flag(player_id : int, flag_id : int):
	var packet = [Packets.Type.PICKUP_FLAG, player_id, flag_id]
	Packets.gamemode_update.emit(sorted_list, packet, Time.get_unix_time_from_system())


#func on_return_flag(team_id : int):
#	var packet = ["", team_id, Packets.FlagStatus.FLAG_DROPPED]
#	Packets.gamemode_update.emit(sorted_list, packet, Time.get_unix_time_from_system())


#func on_capture_flag(team_id : int):
#	var packet = ["", team_id, Packets.FlagStatus.FLAG_CAPTURED]
#	Packets.gamemode_update.emit(sorted_list, packet, Time.get_unix_time_from_system())
