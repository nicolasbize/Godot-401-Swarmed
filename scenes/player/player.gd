class_name Player
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var body_sprite: Sprite2D = $BodySprite

@export var speed := 50.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed 
	move_and_slide()

	if direction == Vector2.ZERO:
		animation_player.play("idle")
	else:
		animation_player.play("walk")
	aim_at(get_global_mouse_position())

func aim_at(target: Vector2) -> void:
	var weapon_direction := weapon_pivot.global_position.direction_to(target)
	weapon_pivot.rotation = weapon_direction.angle()
	if target.x < global_position.x:
		weapon_pivot.scale.y = -1
	else:
		weapon_pivot.scale.y = 1
	body_sprite.flip_h = weapon_pivot.scale.y < 0
