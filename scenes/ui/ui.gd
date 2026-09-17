class_name UI
extends CanvasLayer

signal restart_requested

@export var game_duration_min := 0.25
@export var player: Player = null
@export var possible_ugprades : Array[UpgradeData]

@onready var time_left_label: Label = $TimeLeftLabel
@onready var coin_label: Label = $CoinLabel
@onready var health_label: Label = $HealthLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_over_time_label: Label = $GameOverPanel/GameOverTimeLabel
@onready var final_score_label: Label = $EndGamePanel/FinalScoreLabel
@onready var upgrade_panels: Array[UpgradePanel] = [$UpgradeDialog/UpgradePanel, $UpgradeDialog/UpgradePanel2, $UpgradeDialog/UpgradePanel3]
@onready var level_up_audio: AudioStreamPlayer = $LevelUpAudio
@onready var coin_audio: AudioStreamPlayer = $CoinAudio

var has_completed_game := false
var has_upgraded := false
var secs_since_start := 0.0

func _ready() -> void:
	player.dead.connect(on_player_death)
	player.leveled_up.connect(on_player_levelup)
	for upgrade_panel in upgrade_panels:
		upgrade_panel.upgrade_applied.connect(on_upgrade_applied)

func _process(delta: float) -> void:
	if not get_tree().paused:
		secs_since_start += delta
	if player != null:
		coin_label.text = "%d/%d" % [player.coins_collected, player.next_lvl_requirement]
		health_label.text = "%d/%d" % [player.current_health, player.max_health]
		var secs_left : int = game_duration_min * 60 - secs_since_start
		var mins : int = secs_left / 60
		var secs := secs_left - mins * 60
		time_left_label.text = "%02d:%02d" % [mins, secs]
		if secs_left == 0 and not has_completed_game:
			finish_game()

func finish_game() -> void:
	has_completed_game = true
	animation_player.play("show_ending")
	final_score_label.text = "SCORE: %d" % player.coins_collected
	get_tree().paused = true

func get_game_progress() -> float:
	var total_secs := game_duration_min * 60.0
	return clamp(secs_since_start / total_secs, 0.0, 1.0)

func on_player_death() -> void:
	animation_player.play("show_game_over")
	game_over_time_label.text = "TIME LEFT: %s" % time_left_label.text 
	get_tree().paused = true

func on_player_levelup() -> void:
	level_up_audio.play()
	get_tree().paused = true
	has_upgraded = false
	var sum_rarity := 0
	for upgrade_panel in upgrade_panels:
		upgrade_panel.roll_rarity()
		sum_rarity += upgrade_panel.rarity
	if sum_rarity == 0:
		upgrade_panels.pick_random().set_rarity(UpgradePanel.UpgradeRarity.Uncommon)
	var upgrades := possible_ugprades.duplicate()
	if player.damage_min + 5 > player.damage_max:
		for upgrade in upgrades:
			if upgrade.property == "damage_min":
				upgrades.erase(upgrade)
				break
	upgrades.shuffle()
	for i in upgrade_panels.size():
		upgrade_panels[i].setup(upgrades[i], player)
	animation_player.play("show_upgrades")

func on_upgrade_applied(property: String, new_value: float) -> void:
	if not has_upgraded:
		coin_audio.play()
		has_upgraded = true
		player.set(property, new_value)
		if property == "max_health":
			player.current_health = player.max_health
		animation_player.play("hide_upgrades")

func resume_gameplay() -> void:
	get_tree().paused = false

func _on_restart_button_pressed() -> void:
	coin_audio.play()
	animation_player.play("hide_game_over")

func restart() -> void:
	get_tree().paused = false
	restart_requested.emit()

func _on_won_restart_button_pressed() -> void:
	coin_audio.play()
	animation_player.play("hide_ending")
