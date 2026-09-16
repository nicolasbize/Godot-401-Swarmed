class_name ExplosionArea
extends Area2D

@export var splash_damage : int = 0

func explode() -> void:
	if splash_damage > 0:
		for body: Node2D in get_overlapping_bodies():
			if body is Enemy:
				var enemy : Enemy = body
				enemy.take_damage(splash_damage)
	queue_free()
