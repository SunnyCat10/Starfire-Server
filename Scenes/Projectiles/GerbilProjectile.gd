extends RigidBody2D


var speed : float = 200
var life_time = 1.0
var impulse_rotation
var player_id : int
@onready var area2d :Area2D = $Area2D

func _ready():
#	body_entered.connect(on_impact)
	area2d.body_entered.connect(on_impact)
	apply_central_impulse(Vector2(speed, 0).rotated(global_rotation))
	
	await get_tree().create_timer(life_time).timeout.connect(destroy_projectile)


func on_impact(body: Node2D) -> void:
	if body.name != str(player_id):
		print(body.name,"was hit by projectile owned by", player_id)
		if body.is_in_group("players"):
			print("Hit player") # TODO SEND RPC
		
		destroy_projectile()


func destroy_projectile():
	set_deferred("freeze", true)
	queue_free()
