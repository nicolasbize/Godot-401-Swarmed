class_name Player
extends CharacterBody2D

signal shot(bullet_global_position: Vector2, bullet_global_rotation: float, bullet_damage: int)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var body_sprite: Sprite2D = $BodySprite
@onready var weapon: Weapon = $WeaponPivot/Weapon
@onready var shot_timer: Timer = $ShotTimer
@onready var bullet_spawn_location: Node2D = $WeaponPivot/Weapon/BulletSpawnLocation

@export var speed := 50.0
@export var fire_rate := 2.0
@export var damage_min := 3
@export var damage_max := 5

func _ready() -> void:
	shot_timer.start(1.0 / fire_rate)

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

func _on_shot_timer_timeout() -> void:
	weapon.shoot()
	var damage := randi_range(damage_min, damage_max)
	shot.emit(bullet_spawn_location.global_position, bullet_spawn_location.global_rotation, damage)
	
