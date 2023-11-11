extends CharacterBody2D

signal died(player_id : int)

@onready var collision_shape : CollisionShape2D = %CollisionShape2D
@onready var flag_manager : Node2D = %FlagManager
@onready var health_manager : Node = %HealthManager

var is_alive : bool = false

func _ready():
	health_manager.died.connect(on_death)


func spawn(spawn_position : Vector2):
	global_position = spawn_position
	rotation = 0
	
	
	health_manager.spawn()
	# global_position = spawn_position
	collision_shape.set_deferred("disabled", false)
	is_alive = true


func take_damage(damage : int):
	if is_alive:
		health_manager.take_damage(damage)


func on_death():
	is_alive = false
	died.emit(name.to_int())
	collision_shape.set_deferred("disabled", true)
	if flag_manager.with_flag:
		flag_manager.drop_flag()
	
