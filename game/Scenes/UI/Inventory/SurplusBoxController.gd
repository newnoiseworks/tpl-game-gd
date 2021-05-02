extends Node2D

var money_queue: Array = []
var is_animating: bool = false
var original_panel_pos: Vector2
var target_panel_pos: Vector2
var current_money: Dictionary

onready var silver_coin_panel: Panel = $SilverCoin
onready var gold_coin_panel: Panel = $GoldCoin
onready var silver_label: Label = find_node("SilverCoinLabel")
onready var gold_label: Label = find_node("GoldCoinLabel")
onready var surplus_label: Label = find_node("SurplusLabel")
onready var tween = $Tween
onready var timer = $Timer
onready var silver_audio: AudioStreamPlayer2D = $SilverAudio


func _ready():
	original_panel_pos = silver_coin_panel.get_rect().position
	target_panel_pos = original_panel_pos + Vector2(0, -30)


func _process(_delta):
	if money_queue.empty() || is_animating || TPLG.ui.mission_update_popup.is_animating:
		return

	current_money = money_queue.pop_front()

	if current_money.type == "corpus":
		for money in money_queue:
			if money.type == "corpus":
				current_money.amount += money.amount
				money_queue.erase(money)

		silver_label.text = "  +%s" % current_money.amount
	elif current_money.type == "community":
		for money in money_queue:
			if money.type == "community":
				current_money.amount += money.amount
				money_queue.erase(money)

		gold_label.text = "  +%s" % current_money.amount

	is_animating = true

	tween.interpolate_property(
		silver_coin_panel if current_money.type == "corpus" else gold_coin_panel,
		"rect_position",
		original_panel_pos,
		target_panel_pos,
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)

	silver_audio.play()

	tween.start()
	timer.start()


func _on_timer_timeout():
	tween.interpolate_property(
		silver_coin_panel if current_money.type == "corpus" else gold_coin_panel,
		"rect_position",
		target_panel_pos,
		original_panel_pos,
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)

	tween.connect("tween_all_completed", self, "_on_fadeout_tween_complete")
	tween.start()


func _on_fadeout_tween_complete():
	tween.disconnect("tween_all_completed", self, "_on_fadeout_tween_complete")
	is_animating = false


func add_corpus_coin(amount: int):
	money_queue.append({"amount": amount, "type": "corpus"})


func add_community_coin(amount: int, surplus: bool = false):
	money_queue.append({"amount": amount, "type": "community", "surplus": surplus})

	if surplus:
		surplus_label.show()
	else:
		surplus_label.hide()
