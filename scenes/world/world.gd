class_name World
extends Node2D

var bullet_blueprint := preload("res://scenes/bullet/bullet.tscn")
var damage_label_indicator_blueprint := preload("res://scenes/damage_label_indicator/damage_label_indicator.tscn")
var explosion_area_blueprint := preload("res://scenes/explosion_area/explosion_area.tscn")
var enemy_blueprint := preload("res://scenes/enemy/enemy.tscn")

@onready var player: Player = $Player

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

func _on_player_shot(bullet_global_position: Vector2, bullet_global_rotation: float, bullet_damage: int) -> void:
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

func _on_enemy_destroyed(enemy_global_position: Vector2, extra_damage: int) -> void:
	var explosion : ExplosionArea = explosion_area_blueprint.instantiate()
	add_child.call_deferred(explosion)
	explosion.global_position = enemy_global_position
	explosion.splash_damage = extra_damage
