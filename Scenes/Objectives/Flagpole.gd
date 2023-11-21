extends Area2D

signal flag_picked(player_id : int, flag_id : int)
#signal flag_returned(player_id : int, flag_id : int)
signal flag_captured(player_id : int, flag_id : int)


@export var flag_team_id : int

var is_empty : bool = false
var id : int

func _ready():
	body_entered.connect(on_body_entered)


func setup_flag():
	is_empty = false


func pickup_flag(player : Node2D):
	flag_picked.emit(player.name.to_int(), id)
	is_empty = true


func return_flag(player : Node2D):
	#flag_returned.emit(player.name.to_int(), id)
	setup_flag()
	is_empty = false


func capture_flag(player : Node2D):
	print("FLAG CAPTURED!")
	flag_captured.emit(player.name.to_int(), player.flag_manager._flagpole.id)


func on_body_entered(body: Node2D):
	if body.is_in_group("players"):
		if not body.flag_manager._player_team_id == flag_team_id and not is_empty:
			pickup_flag(body)
			print("PICKED!")
			body.flag_manager.load_flag(self)
		if body.flag_manager._player_team_id == flag_team_id and body.flag_manager.with_flag:
			body.flag_manager.capture_flag()
			capture_flag(body)
