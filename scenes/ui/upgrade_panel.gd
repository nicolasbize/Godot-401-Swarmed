class_name UpgradePanel
extends TextureRect

signal upgrade_applied(property: String, new_value: float)

enum UpgradeRarity {Common, Uncommon, Rare, Epic}

@export var rarity := UpgradeRarity.Common
@export var rarity_textures : Array[Texture2D]
@onready var upgrade_title: Label = $UpgradeTitle
@onready var upgrade_description: Label = $UpgradeDescription
@onready var upgrade_icon: TextureRect = $UpgradeIcon
@onready var upgrade_stat_name: Label = $UpgradeStatName
@onready var upgrade_before_value: Label = $UpgradeBeforeValue
@onready var upgrade_after_value: Label = $UpgradeAfterValue

var upgraded_property : String
var new_value : float

func set_rarity(upgrade_rarity: UpgradeRarity) -> void:
	rarity = upgrade_rarity
	texture = rarity_textures[rarity]

func roll_rarity() -> void:
	var roll := randf()
	var thresholds := [0.65, 0.85, 0.95, 1.0]
	for i in thresholds.size():
		if roll <= thresholds[i]:
			set_rarity(i)
			break

func setup(upgrade_data: UpgradeData, upgraded_player: Player) -> void:
	upgrade_title.text = upgrade_data.title
	upgrade_description.text = upgrade_data.description
	upgrade_icon.texture = upgrade_data.icon
	upgrade_stat_name.text = upgrade_data.stat_name
	upgrade_before_value.text = upgrade_data.format % upgraded_player.get(upgrade_data.property)
	upgraded_property = upgrade_data.property
	new_value = upgraded_player.get(upgrade_data.property) + upgrade_data.default_increase * (rarity + 1)
	upgrade_after_value.text = upgrade_data.format % new_value
	
func _on_upgrade_button_pressed() -> void:
	upgrade_applied.emit(upgraded_property, new_value)
