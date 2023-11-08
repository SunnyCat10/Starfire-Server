extends CharacterBody2D

signal died(player_id : String)

@onready var collision_shape : CollisionShape2D = %CollisionShape2D
@onready var flag_manager : Node2D = %FlagManager
@onready var health_manager : Node = %HealthManager

var is_alive : bool = false

func _ready():
	health_manager


func spawn(spawn_position : Vector2):
	global_position = spawn_position
	health_manager.spawn()
	global_position = spawn_position
	collision_shape.disabled = false
	is_alive = true


func take_damage(damage : int):
	if is_alive:
		health_manager.take_damage(damage)


func on_death():
	is_alive = false
	died.emit(name)
	collision_shape.disabled = true
	
