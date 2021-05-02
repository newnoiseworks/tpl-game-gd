extends Node2D

onready var radial = find_node("RadialProgressBar")
onready var label: Label = $Label
onready var name_label: Label = $Name
onready var tween: Tween = $Tween


func _ready():
	if SessionManager.wallet_data.has("ExperienceCoin-" + SessionManager.current_avatar.key):
		set_exp(SessionManager.wallet_data["ExperienceCoin-" + SessionManager.current_avatar.key])

	name_label.text = SessionManager.current_avatar.name


func _exp_required_at_level(lvl: int):
	return lvl * 1.25 * 100


func _current_level_from_experience(expts: int):
	for i in range(99):
		if expts < _exp_required_at_level(i):
			return i - 1


func set_exp(expts: int):
	var lvl = _current_level_from_experience(expts)
	label.text = "Lv %s" % lvl

	var curr_lvl_exp_req = _exp_required_at_level(lvl + 1) - _exp_required_at_level(lvl)
	var curr_progress = expts - _exp_required_at_level(lvl)
	var progress = float(curr_progress) / float(curr_lvl_exp_req) * 100.0
	var progress_animate_delay: float = 0.0

	# TODO: Make some logic for passing 100%, returning to 0 when going through levels
	if progress < radial.progress:
		progress_animate_delay = 1.5
		tween.interpolate_property(
			radial, "progress", radial.progress, 100, 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN
		)
		tween.start()

	tween.interpolate_property(
		radial,
		"progress",
		0 if progress_animate_delay > 0 else radial.progress,
		progress,
		1.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		progress_animate_delay
	)

	tween.start()
