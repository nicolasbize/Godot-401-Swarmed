class_name DamageLabelIndicator
extends Node2D

@onready var damage_label: Label = $DamageLabel

func set_damage(amount: int) -> void:
	damage_label.text = str(amount)
