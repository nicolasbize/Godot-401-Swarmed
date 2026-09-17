class_name UI
extends CanvasLayer

signal restart_requested

@export var game_duration_min := 0.25
@export var player: Player = null

@onready var time_left_label: Label = $TimeLeftLabel
@onready var coin_label: Label = $CoinLabel
@onready var health_label: Label = $HealthLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_over_time_label: Label = $GameOverPanel/GameOverTimeLabel
@onready var final_score_label: Label = $EndGamePanel/FinalScoreLabel

var has_completed_game := false
var secs_since_start := 0.0

func _ready() -> void:
	player.dead.connect(on_player_death)

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

func _on_restart_button_pressed() -> void:
	animation_player.play("hide_game_over")

func restart() -> void:
	get_tree().paused = false
	restart_requested.emit()

func _on_won_restart_button_pressed() -> void:
	animation_player.play("hide_ending")
