class_name World
extends Node2D

signal game_reset

var bullet_blueprint := preload("res://scenes/bullet/bullet.tscn")
var damage_label_indicator_blueprint := preload("res://scenes/damage_label_indicator/damage_label_indicator.tscn")
var explosion_area_blueprint := preload("res://scenes/explosion_area/explosion_area.tscn")
var enemy_blueprint := preload("res://scenes/enemy/enemy.tscn")
var coin_blueprint := preload("res://scenes/coin/coin.tscn")

@export var enemies : Array[EnemyData]

@onready var player: Player = $Player
@onready var ui: UI = $UI
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var bullet_audio: AudioStreamPlayer = $BulletAudio

func _ready() -> void:
	spawn_enemies()

func spawn_enemies() -> void:
	for i in 20:
		var enemy: Enemy = enemy_blueprint.instantiate()
		enemy.damage_received.connect(_on_enemy_damage_received)
		enemy.destroyed.connect(_on_enemy_destroyed)
		enemy.player = player
		enemy.global_position = player.get_random_spawn_position()
		add_child(enemy)
		var progress := ui.get_game_progress()
		var enemy_data := pick_weighted_enemy(progress)
		enemy.setup(enemy_data)

func pick_weighted_enemy(progress: float) -> EnemyData:
	var total_weights : Array[float] = []
	var sum := 0.0
	for enemy in enemies:
		sum += enemy.frequency.sample(progress)
		total_weights.append(sum)
	var weight_value := randf_range(0, sum)
	for i in enemies.size() - 1:
		if weight_value < total_weights[i]:
			return enemies[i]
	return enemies[-1]

func _on_player_shot(bullet_global_position: Vector2, bullet_global_rotation: float, bullet_damage: int) -> void:
	bullet_audio.play()
	var bullet : Bullet = bullet_blueprint.instantiate()
	add_child(bullet)
	bullet.global_position = bullet_global_position
	bullet.global_rotation = bullet_global_rotation
	bullet.damage = bullet_damage

func _on_enemy_damage_received(damage_global_position: Vector2, damage_amount: int) -> void:
	var label_indicator : DamageLabelIndicator = damage_label_indicator_blueprint.instantiate()
	add_child(label_indicator)
	label_indicator.global_position = damage_global_position
	label_indicator.set_damage(damage_amount)

func _on_enemy_destroyed(enemy_global_position: Vector2, extra_damage: int, reward_type: Coin.CoinType) -> void:
	var explosion : ExplosionArea = explosion_area_blueprint.instantiate()
	add_child.call_deferred(explosion)
	explosion.global_position = enemy_global_position
	explosion.splash_damage = extra_damage
	explosion_audio.play()
	
	var coin : Coin = coin_blueprint.instantiate()
	add_child.call_deferred(coin)
	coin.global_position = enemy_global_position
	coin.type = reward_type

func _on_ui_restart_requested() -> void:
	game_reset.emit()
