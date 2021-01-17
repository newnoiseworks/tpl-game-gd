extends KinematicBody2D

const UP = Vector2(0, -1)
const FLAP = 200
const MAX_FALL_SPEED = 200
const GRAVITY = 10

var velocity = Vector2()
var playing: bool = true

onready var audio: AudioStreamPlayer = $AudioStreamPlayer


func _physics_process(_delta):
	if ! playing:
		return

	velocity.y += GRAVITY

	if velocity.y > MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED

	if (
		Input.is_action_just_pressed("action_one")
		|| Input.is_action_just_pressed("action_two")
		|| Input.is_action_just_pressed("action_three")
		|| Input.is_action_just_pressed("action_four")
		|| Input.is_action_just_pressed("action_five")
	):
		audio.play()
		velocity.y = -FLAP

	move_and_slide(velocity, UP)


func _on_body_enter(body: Node):
	if body.name == "UpperWall" || body.name == "LowerWall":
		playing = false
		get_viewport().get_parent().call("loss")

	if body.name == "FinishBar":
		playing = false
		get_viewport().get_parent().call("win")
