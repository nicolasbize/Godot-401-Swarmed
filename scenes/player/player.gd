class_name Player
extends CharacterBody2D

signal shot(bullet_global_position: Vector2, bullet_global_rotation: float, bullet_damage: int)
signal dead
signal leveled_up

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var body_sprite: Sprite2D = $BodySprite
@onready var weapon: Weapon = $WeaponPivot/Weapon
@onready var shot_timer: Timer = $ShotTimer
@onready var bullet_spawn_location: Node2D = $WeaponPivot/Weapon/BulletSpawnLocation
@onready var magnet_area: Area2D = $MagnetArea
@onready var magnet_sphere: CollisionShape2D = $MagnetArea/MagnetSphere
@onready var current_health = max_health
@onready var coin_audio: AudioStreamPlayer = $CoinAudio
@onready var hurt_audio: AudioStreamPlayer = $HurtAudio

@export var speed := 50.0
@export var fire_rate := 2.0
@export var damage_min := 3
@export var damage_max := 5
@export var magnet_strength := 20.0
@export var max_health := 10
@export var coins_collected := 0

enum State {Moving, Hurting, Dying}

var current_state := State.Moving
var current_level := 1
var next_lvl_requirement := 5
var level_cost_increase := 2

func _ready() -> void:
	shot_timer.start(1.0 / fire_rate)
	magnet_sphere.shape.radius = magnet_strength

func _physics_process(delta: float) -> void:
	if current_state != State.Dying:
		var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity = direction * speed 
		move_and_slide()
		if current_state == State.Moving:
			play_moving_animation(direction)
		aim_at(get_global_mouse_position())
		attract_coins(delta)

func play_moving_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		animation_player.play("idle")
	else:
		animation_player.play("walk")

func attract_coins(delta: float) -> void:
	if current_state != State.Dying:
		for area : Area2D in magnet_area.get_overlapping_areas():
			if area is Coin:
				var coin : Coin = area
				var coin_direction := coin.position.direction_to(position)
				coin.position += coin_direction * magnet_strength * delta

func add_coins(amount: int) -> void:
	if current_state != State.Dying:
		coins_collected += amount
		coin_audio.play()
		if coins_collected >= next_lvl_requirement:
			current_level += 1
			level_cost_increase += current_level * 2
			next_lvl_requirement += level_cost_increase
			leveled_up.emit()

func aim_at(target: Vector2) -> void:
	var weapon_direction := weapon_pivot.global_position.direction_to(target)
	weapon_pivot.rotation = weapon_direction.angle()
	if target.x < global_position.x:
		weapon_pivot.scale.y = -1
	else:
		weapon_pivot.scale.y = 1
	body_sprite.flip_h = weapon_pivot.scale.y < 0

func _on_shot_timer_timeout() -> void:
	if current_state != State.Dying:
		weapon.shoot()
		var damage := randi_range(damage_min, damage_max)
		shot.emit(bullet_spawn_location.global_position, bullet_spawn_location.global_rotation, damage)
	
func get_random_spawn_position() -> Vector2:
	var random_angle := randf_range(0, TAU)
	return position + Vector2.from_angle(random_angle) * 300

func _on_enemy_detection_area_body_entered(body: Node2D) -> void:
	if body is Enemy and current_state == State.Moving:
		current_health -= 1
		hurt_audio.play()
		if current_health == 0:
			current_state = State.Dying
			dead.emit()
		else:
			current_state = State.Hurting
			animation_player.play("hurt")

func recover() -> void:
	current_state = State.Moving
	animation_player.play("walk")
