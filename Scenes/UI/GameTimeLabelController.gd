extends Label

var in_game_hour: int
var in_game_minute: int


func _physics_process(_delta: float):
	if in_game_hour != GameTime.in_game_hour && in_game_minute != GameTime.in_game_minute:
		in_game_hour = GameTime.in_game_hour
		in_game_minute = GameTime.in_game_minute
		text = GameTime.get_rounded_time()
