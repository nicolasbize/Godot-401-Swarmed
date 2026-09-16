class_name Enemy
extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var enemy_sprite: Sprite2D = $EnemySprite
@onready var current_health = max_health

@export var player : Player = null
@export var speed : float = 10.0
@export var max_health := 10

enum State {Moving, Hurting, Dying}

var current_state := State.Moving

func _ready() -> void:
	timer.start(randf_range(0, 0.6))

func _physics_process(delta: float) -> void:
	if player != null and current_state == State.Moving:
		var direction := position.direction_to(player.position)
		velocity = direction * speed
		enemy_sprite.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _on_timer_timeout() -> void:
	animation_player.play("walk")

func _on_bullet_detection_area_body_entered(body: Node2D) -> void:
	if body is Bullet:
		var bullet : Bullet = body
		bullet.queue_free()
		animation_player.play("hurt")
		current_state = State.Hurting
		current_health = clamp(current_health - bullet.damage, 0, max_health)
		if current_health == 0:
			current_state = State.Dying
			queue_free()

func recover() -> void:
	animation_player.play("walk")
	current_state = State.Moving
