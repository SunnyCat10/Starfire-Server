extends Node2D

var _flagpole : Node2D
var _player_team_id : int
var with_flag : bool = false


func setup_manager(player_team_id : int):
	_player_team_id = player_team_id


func load_flag(flagpole : Node2D):
	_flagpole = flagpole
	with_flag = true


func drop_flag(drop_position : Vector2):
	with_flag = false


func capture_flag():
	_flagpole.setup_flag()
	with_flag = false
