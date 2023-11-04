extends Node

const MATCH_COOLDOWN_TIME : float = 3.0


var lobby_id : int # maybe uneeded?

var player_list = []
var sorted_list = {}

var ally_score : int = 0
var enemy_score : int = 0
var timer : Timer
var _max_players : int = 2
var current_players : int = 0

var flagpoles = {}

var game_running : bool = false

func setup_game(max_players : int, match_duration : int):
	_max_players = max_players
	
	# ADD TIMER!!!
	
#	var player_id : int = multiplayer.get_unique_id()
#	if (player_list["A"].has(player_id)):
#		allied_team = player_list["A"]
#		enemy_team = player_list["B"]
#	else:
#		allied_team = player_list["B"]
#		enemy_team = player_list["A"]
	
	# set texture of the flags


func start_game():
	print("Game started!")
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
		
