extends KinematicBody2D

const UP = Vector2(0, -1)
const FLAP = 200
const MAX_FALL_SPEED = 200
const GRAVITY = 10

var velocity = Vector2()


func _physics_process(_delta):
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
		velocity.y = -FLAP

	move_and_slide(velocity, UP)


func _on_body_enter(body: Node):
	if body.name == "UpperWall" || body.name == "LowerWall":
		exit_game()

	if body.name == "FinishBar":
		exit_game()


func exit_game():
	get_viewport().get_parent().queue_free()
	Player.is_fishing = false
	Player.lock_movement = false
	Player.current_tool_tile = ""
