extends PopupPanel

var mission_queue: Array = []
var is_animating: bool = false

onready var tween = $Tween
onready var timer = $Timer
onready var title = find_node("MissionTitle")
onready var new_audio = $NewAudio
onready var complete_audio = $CompleteAudio
onready var new_mission_label: Label = find_node("NewMissionLabel")
onready var complete_mission_label: Label = find_node("CompleteMissionLabel")


func _ready():
	set("modulate", Color(1, 1, 1, 0))


func _process(_delta):
	if mission_queue.empty() || is_animating:
		return

	var mission = mission_queue.pop_front()

	title.text = '"' + mission.title + '"'

	if mission.complete:
		complete_audio.play()
		new_mission_label.hide()
		complete_mission_label.show()
	else:
		new_audio.play()
		new_mission_label.show()
		complete_mission_label.hide()

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

	mission_queue.append({"title": mission.title, "complete": false})


func show_completed_mission(mission_key: String):
	var mission = MissionList.list[mission_key]

	mission_queue.append({"title": mission.title, "complete": true})
