extends Node2D


var gerbil_projectile : PackedScene = preload("res://Scenes/Projectiles/GerbilProjectile.tscn")
var remote_player : PackedScene = preload("res://Scenes/Entities/remote_player.tscn")


func spawn_attack(position : Vector2, rotation : float, client_time : float, player_id : int):
	var projectile_instance : Node2D = gerbil_projectile.instantiate()
	projectile_instance.position = position
	projectile_instance.rotation = rotation
	add_child(projectile_instance)
