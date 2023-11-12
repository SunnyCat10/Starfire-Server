extends Area2D

var _flag_team_id : int
var _flagpole : Node2D


func _ready():
	body_entered.connect(on_body_entered)


func load_flag(flagpole : Node2D, flag_team_id : int):
	_flag_team_id = flag_team_id
	_flagpole = flagpole


func take_flag(body: Node2D):
	body.flag_manager.load_flag(_flagpole)
	self.queue_free()


func return_flag():
	_flagpole.return_flag()
	self.queue_free()


func on_body_entered(body: Node2D):
	if body.is_in_group("players") and body.is_alive:
		print("is player alive: ", body.is_alive)
		if body.flag_manager._player_team_id == _flag_team_id:
			return_flag()
		else:
			take_flag(body)
