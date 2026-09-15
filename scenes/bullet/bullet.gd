class_name Bullet
extends AnimatableBody2D

@export var speed := 300.0

func _physics_process(delta: float) -> void:
	var direction := Vector2.from_angle(rotation)
	var velocity := direction * speed
	move_and_collide(velocity * delta)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
