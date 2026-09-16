class_name Enemy
extends CharacterBody2D

signal damage_received(damage_global_position: Vector2, damage_amount: int)
signal destroyed(enemy_global_position: Vector2, extra_damage: int, reward_type: Coin.CoinType)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var enemy_sprite: Sprite2D = $EnemySprite
@onready var current_health : int = max_health
@onready var damage_label_spawn: Node2D = $DamageLabelSpawn

@export var player : Player = null
@export var speed : float = 10.0
@export var max_health := 10
@export var reward : Coin.CoinType

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
		take_damage(bullet.damage)

func take_damage(amount: int) -> void:
	if current_state != State.Dying and amount > 0:
		animation_player.play("hurt")
		current_state = State.Hurting
		var extra_damage := amount - current_health
		current_health = clamp(current_health - amount, 0, max_health)
		damage_received.emit(damage_label_spawn.global_position, amount)
		if current_health == 0:
			current_state = State.Dying
			extra_damage = extra_damage / 2
			destroyed.emit(global_position, extra_damage, reward)
			queue_free()
	
func recover() -> void:
	animation_player.play("walk")
	current_state = State.Moving
