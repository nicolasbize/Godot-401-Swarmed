class_name World
extends Node2D

var bullet_blueprint := preload("res://scenes/bullet/bullet.tscn")

func _on_player_shot(bullet_global_position: Vector2, bullet_global_rotation: float) -> void:
	var bullet := bullet_blueprint.instantiate()
	add_child(bullet)
	bullet.global_position = bullet_global_position
	bullet.global_rotation = bullet_global_rotation
