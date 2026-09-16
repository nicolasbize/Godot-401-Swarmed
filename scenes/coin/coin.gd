class_name Coin
extends Area2D

enum CoinType {Bronze, Jade, Diamond, Sapphire}

@onready var coin_sprite: Sprite2D = $CoinSprite

@export var type := CoinType.Bronze

func _ready() -> void:
	coin_sprite.frame = type
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var player : Player = body
		var coin_values : Array[int] = [1, 3, 5, 10]
		player.add_coins(coin_values[type])
		queue_free()
