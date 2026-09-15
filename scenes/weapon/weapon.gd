class_name Weapon
extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func shoot() -> void:
	animation_player.play("shoot")
