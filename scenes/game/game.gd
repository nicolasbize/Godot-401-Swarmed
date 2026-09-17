class_name Game
extends Node2D

var world_blueprint := preload("res://scenes/world/world.tscn")

var world : World = null

func _ready() -> void:
	restart_level()

func restart_level() -> void:
	if world != null:
		world.queue_free()
	world = world_blueprint.instantiate()
	world.game_reset.connect(restart_level)
	add_child(world)
