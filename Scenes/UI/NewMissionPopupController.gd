extends PopupPanel

var mission_queue: Array = []
var is_animating: bool = false

onready var tween = $Tween
onready var timer = $Timer
onready var title = find_node("MissionTitle")


func _ready():
	set("modulate", Color(1, 1, 1, 0))


func _process(_delta):
	if mission_queue.empty() || is_animating:
		return

	title.text = mission_queue.pop_back()

	is_animating = true

	popup_centered()

	tween.interpolate_property(
		self,
		"modulate",
		Color(1, 1, 1, 0),
		Color(1, 1, 1, 1),
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)

	tween.start()
	timer.start()


func _on_timer_timeout():
	tween.interpolate_property(
		self,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)

	tween.connect("tween_all_completed", self, "_on_fadeout_tween_complete")
	tween.start()


func _on_fadeout_tween_complete():
	tween.disconnect("tween_all_completed", self, "_on_fadeout_tween_complete")
	is_animating = false
	hide()


func show_new_mission(mission_key: String):
	var mission = MissionList.list[mission_key]

	mission_queue.append(mission.title)
