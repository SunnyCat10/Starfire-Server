extends Node2D

var _flagpole : Node2D
var _player_team_id : int
var with_flag : bool = false

@onready var flag_drop_scene: PackedScene = preload("res://Scenes/Drops/Flag.tscn")


func setup_manager(player_team_id : int):
	_player_team_id = player_team_id


func load_flag(flagpole : Node2D):
	_flagpole = flagpole
	with_flag = true


func drop_flag(drop_position : Vector2):
	with_flag = false
	var flag_drop : Node2D = flag_drop_scene.instantiate()
	get_parent().get_parent().get_parent().add_child(flag_drop)
	flag_drop.global_position = drop_position
	flag_drop.load_flag(_flagpole, _flagpole.flag_team_id)


func capture_flag():
	_flagpole.setup_flag()
	with_flag = false