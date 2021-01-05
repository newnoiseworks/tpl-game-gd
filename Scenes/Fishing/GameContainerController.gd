extends ViewportContainer

var game_scene = ResourceLoader.load("res://Scenes/Fishing/Game.tscn")
var game_started: bool = false
var weight: int

onready var vp: Viewport = $Viewport
onready var timer: Timer = $EntryTimer
onready var label: Label = $Label
onready var loss_audio: AudioStreamPlayer = $LossAudio
onready var win_audio: AudioStreamPlayer = $WinAudio


func _physics_process(_delta):
	if (
		! game_started
		&& (
			Input.is_action_just_pressed("action_one")
			|| Input.is_action_just_pressed("action_two")
			|| Input.is_action_just_pressed("action_three")
			|| Input.is_action_just_pressed("action_four")
			|| Input.is_action_just_pressed("action_five")
		)
	):
		game_started = true
		start_game()
		label.queue_free()
		timer.stop()
		timer.queue_free()


func loss():
	loss_audio.connect("finished", self, "_destroy_after_timer")
	loss_audio.play()


func win():
	MatchEvent.fishing_victory({"weight": weight})
	TPLG.inventory.bag.add_item(InventoryItems.FISH)
	win_audio.connect("finished", self, "_destroy_after_timer")
	win_audio.play()


func _destroy_after_timer():
	queue_free()
	Player.is_fishing = false
	Player.lock_movement = false
	Player.current_tool_tile = ""


func start_game():
	vp.call_deferred("add_child", game_scene.instance())
