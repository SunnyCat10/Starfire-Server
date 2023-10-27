extends RigidBody2D


var speed : float = 200
var life_time = 1.0
var impulse_rotation
var player_id : int


func _ready():
	body_entered.connect(on_impact)
	apply_central_impulse(Vector2(speed, 0).rotated(global_rotation))
	await get_tree().create_timer(life_time).timeout.connect(destroy_projectile)


func on_impact(body: Node) -> void:
	destroy_projectile()
	

func destroy_projectile():
	set_deferred("freeze", true)
	queue_free()
