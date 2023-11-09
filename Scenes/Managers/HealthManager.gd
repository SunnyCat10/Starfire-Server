extends Node

signal died

@export var max_health : int = 40
var current_health : int


func spawn():
	current_health = max_health


func take_damage(damage : int):
	current_health = current_health - damage
	if current_health <= 0:
		current_health = 0
		died.emit()
	if current_health > max_health:
		current_health = max_health
