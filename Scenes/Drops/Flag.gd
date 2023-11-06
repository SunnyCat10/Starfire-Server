extends Area2D

var _flag_team_id : int
var _flagpole : Node2D


func _ready():
	body_entered.connect(on_body_entered)


func load_flag(flagpole : Node2D, flag_team_id : int):
	_flag_team_id = flag_team_id
	_flagpole = flagpole


func take_flag(body: Node2D):
	body.flag_manager.load_flag(_flagpole, body._player_team_id)
	self.queue_free()


func return_flag():
	_flagpole.return_flag
	self.queue_free()


func on_body_entered(body: Node2D):
	if body.is_in_group("client_player"):
		if not body._player_team_id == _flag_team_id:
			take_flag(body)
		else:
			return_flag()
