extends Area2D

signal flag_picked(team_id : int, player_id : int)
signal flag_captured(team_id : int)
signal flag_returned(team_id : int)

@export var flag_team_id : int

var is_empty : bool = false


func _ready():
	body_entered.connect(on_body_entered)


func setup_flag():
	is_empty = false


func pickup_flag(player : Node2D):
	flag_picked.emit(flag_team_id, player.name.to_int())
	is_empty = true


func capture_flag():
	print("FLAG CAPTURED!")
	flag_captured.emit(flag_team_id)


func return_flag(client_team_id : int):
	flag_returned.emit(flag_team_id)
	setup_flag()
	is_empty = false


func on_body_entered(body: Node2D):
	if body.is_in_group("players"):
		if not body.flag_manager._player_team_id == flag_team_id and not is_empty:
			pickup_flag(body)
			print("PICKED!")
			body.flag_manager.load_flag(self)
		if body.flag_manager._player_team_id == flag_team_id and body.flag_manager.with_flag:
			body.flag_manager.capture_flag()
			capture_flag()
