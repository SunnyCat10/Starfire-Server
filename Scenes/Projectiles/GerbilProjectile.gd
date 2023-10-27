extends RigidBody2D

@onready var area2d :Area2D = $Area2D
@onready var server : Node = get_parent().get_parent()

var speed : float = 200
var life_time = 1.0
var impulse_rotation
var player_id : int
var damage = 10


func _ready():
#	body_entered.connect(on_impact)
	area2d.body_entered.connect(on_impact)
	apply_central_impulse(Vector2(speed, 0).rotated(global_rotation))
	
	await get_tree().create_timer(life_time).timeout.connect(destroy_projectile)


func on_impact(body: Node2D) -> void:
	if body.name != str(player_id):
		print(body.name,"was hit by projectile owned by", player_id)
		if body.is_in_group("players"):
			server.send_damage(player_id, damage)
		destroy_projectile()


func destroy_projectile():
	set_deferred("freeze", true)
	queue_free()
