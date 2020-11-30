extends Node2D

onready var path_follow: PathFollow2D = find_node("SunPathFollow2D")
onready var timer: Timer = Timer.new()
onready var sun: Light2D = find_node("Sun")
onready var night_sky: CanvasModulate = find_node("NightSky")


func _ready():
	show()
	timer.wait_time = 1000
	timer.connect("timeout", self, "process_atmospher")
	timer.autostart = true
	add_child(timer)

	process_atmosphere()


func _exit_tree():
	timer.stop()


func process_atmosphere():
	if timer == null:
		print_debug("Timer still elapsing on Sun Controller for some reason...")
		return

	if GameTime.is_day():
		call_deferred("position_sun")
	else:
		call_deferred("setup_night_sky")


func setup_night_sky():
	if sun.enabled:
		sun.enabled = false
	if night_sky.visible == false:
		night_sky.show()

	var hours_of_nightfall_passed

	# TODO: Maybe move the below into a generic GameTime.GetPercentageOfNightComplete
	if GameTime.in_game_hour > 12:
		hours_of_nightfall_passed = GameTime.in_game_hour - GameTime.NIGHTFALL
	else:
		hours_of_nightfall_passed = GameTime.in_game_hour + (24 - GameTime.NIGHTFALL)

	var percentage_of_night_complete: float = (
		hours_of_nightfall_passed
		/ ((24 - GameTime.NIGHTFALL) + GameTime.DAYBREAK)
	)

	var current_night_intensity_percentage: float

	if percentage_of_night_complete > 0.5:
		current_night_intensity_percentage = 1 - abs(percentage_of_night_complete - 0.5) / 0.5
	else:
		current_night_intensity_percentage = percentage_of_night_complete * 2

	var color = night_sky.color

	color.r = 1 - ((1 - 0.17) * current_night_intensity_percentage)
	color.g = 1 - ((1 - 0.03) * current_night_intensity_percentage)
	color.b = 1 - ((1 - 0.38) * current_night_intensity_percentage)

	night_sky.color = color


func position_sun():
	if sun.enabled == false:
		sun.enabled = true

	var color: Color = night_sky.color
	color.r = 1
	color.g = 1
	color.b = 1
	night_sky.color = color

	var percentage_of_day_complete: float = GameTime.get_percentage_of_day_complete()
	var percentage_of_sun_path_complete: float = clamp(
		(percentage_of_day_complete - 0.25) / (0.83 - 0.25), 0, 0.99
	)

	var energy_of_sun = abs(percentage_of_sun_path_complete - 0.5) + .75

	sun.energy = energy_of_sun
	path_follow.unit_offset = percentage_of_sun_path_complete
