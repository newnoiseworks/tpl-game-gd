extends Node

var in_game_hour: int
var in_game_minute: int

signal daybreak_event
signal nightfall_event

var REAL_WORLD_SECONDS_PER_GAME_DAY = TPLG.real_world_seconds_per_day

const DAYBREAK: int = 6
const NIGHTFALL: int = 20
const LABEL_MINUTES_TO_ROUND_BY: int = 15

var unix_epoch_from_server_on_login: int
var unix_epoch_from_client_on_login: int
var timer: Timer
var client_server_diff: int
var was_night_at_last_check: bool
var was_day_at_last_check: bool


func _ready():
	timer = Timer.new()
	timer.wait_time = 2
	timer.connect("timeout", self, "set_in_game_time_of_day")
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.start()


func start_timer(unix_epoch_from_server_on_login_in_milliseconds: int):
	unix_epoch_from_server_on_login = unix_epoch_from_server_on_login_in_milliseconds
	unix_epoch_from_client_on_login = OS.get_system_time_msecs()
	client_server_diff = unix_epoch_from_client_on_login - unix_epoch_from_server_on_login

	set_in_game_time_of_day()


func is_day():
	return in_game_hour < NIGHTFALL && in_game_hour >= DAYBREAK


func is_night():
	return ! is_day()


func number_of_game_days_from_daybreak_from_unix_timestamp(timestamp):
	var current_time = get_current_timestamp()
	return (
		(
			current_time
			- unix_timestamp_start_of_game_day_from_seconds(timestamp)
			+ (REAL_WORLD_SECONDS_PER_GAME_DAY / 4)
		)
		/ REAL_WORLD_SECONDS_PER_GAME_DAY
	)


func unix_timestamp_start_of_game_day_from_seconds(seconds):
	return seconds - int(seconds % REAL_WORLD_SECONDS_PER_GAME_DAY)


func get_current_timestamp():
	return OS.get_unix_time() + (client_server_diff / 1000)


func get_rounded_time():
	var hour = in_game_hour

	if in_game_hour > 12:
		hour = in_game_hour - 12
	elif in_game_hour == 0:
		hour = 12

	return (
		"%s:%02d %s"
		% [
			hour,
			int(in_game_minute / LABEL_MINUTES_TO_ROUND_BY) * LABEL_MINUTES_TO_ROUND_BY,
			"PM" if in_game_hour > 11 else "AM"
		]
	)


func set_in_game_time_of_day():
	var percentage_of_day_complete = get_percentage_of_day_complete()

	in_game_hour = int(floor(percentage_of_day_complete * 24.0))
	in_game_minute = int(floor(percentage_of_day_complete * 24.0 * 60.0) - (in_game_hour * 60.0))

	if was_day_at_last_check == was_night_at_last_check:
		was_day_at_last_check = is_day()
		was_night_at_last_check = is_night()

	handle_nightfall_and_daybreak()


func get_percentage_of_day_complete():
# 	var unix_epoch_from_client = get_current_timestamp()

# 	var current_time = unix_epoch_from_client + client_server_diff
# 	var start_of_day = OS.get_datetime_from_unix_time(current_time)
# 	start_of_day.hour = 0
# 	start_of_day.minute = 0
# 	start_of_day.second = 0
# #       //DateTime endOfDay = startOfDay.AddDays(1).AddTicks(-1);

# 	var second_of_day = current_time - OS.get_unix_time_from_datetime(start_of_day)
# 	var in_game_second_of_day = second_of_day % (REAL_WORLD_SECONDS_PER_GAME_DAY)
# 	var percentage_of_day_complete = (
# 		float(in_game_second_of_day)
# 		/ float(REAL_WORLD_SECONDS_PER_GAME_DAY)
# 	)

# 	return percentage_of_day_complete

	var unix_epoch_from_client = OS.get_system_time_msecs()

	var current_time = unix_epoch_from_client + client_server_diff

	var start_of_day = OS.get_datetime_from_unix_time(current_time / 1000)
	start_of_day.hour = 0
	start_of_day.minute = 0
	start_of_day.second = 0

	var millisecond_of_day: int = (
		current_time
		- (OS.get_unix_time_from_datetime(start_of_day) * 1000)
	)
	var second_of_day: int = int(millisecond_of_day / 1000)
	var in_game_second_of_day: int = second_of_day % (REAL_WORLD_SECONDS_PER_GAME_DAY)
	var percentage_of_day_complete: float = float(
		in_game_second_of_day / float(REAL_WORLD_SECONDS_PER_GAME_DAY)
	)

	return percentage_of_day_complete


func handle_nightfall_and_daybreak():
	if is_day() && was_night_at_last_check:
		was_night_at_last_check = false
		was_day_at_last_check = true
		emit_signal("daybreak_event")

	if is_night() && was_day_at_last_check:
		was_night_at_last_check = true
		was_day_at_last_check = false
		emit_signal("nightfall_event")
