extends "res://Scenes/Character/Farmer/FarmerController.gd"

var lock_movement: bool
# var current_farm_grid: Node2D
var item_under_target: Node2D
var area_to_use_equipped_item: Vector2
var last_move_counter: float
var map_constraints: Dictionary = {}

const MOVE_POSITION_FROM_BUTTON: int = 32
const MOVE_DELAY_MINIMUM: float = .25
const MOVEMENT_PING_TIMER_INTERVAL: float = 30.0  # .15

onready var camera: Camera2D = $Camera2D
onready var movement_ping_timer: Timer = $MovementPing


func _ready():
	movement_ping_timer.wait_time = MOVEMENT_PING_TIMER_INTERVAL
	movement_ping_timer.connect("timeout", self, "on_movement_ping_timer_event")

	find_node("CharacterInteractItem").queue_free()
	get_parent().call_deferred("remove_child", self)  # remove from tree on entry


func _enter_tree():
	move_target_as_needed(position)
	# if movement_ping_timer != null:
	# 	movement_ping_timer.autostart = true
	pass


func _exit_tree():
	movement_ping_timer.stop()


func _physics_process(delta: float):
	if movement_ping_timer == null || avatar_data == null:
		return

	if navigation_points == null || navigation_points.size() == 0:
		if movement_ping_timer.paused == false:
			movement_ping_timer.stop()
			# send_movement_ping_update()
	else:
		movement_ping_timer.start()

		# base._Physics_process(delta);

	if lock_movement:
		return

	last_move_counter += delta

	# 	if (Input_controller.Moving(null, true, true) && !Input_controller.Moving(null))
	if was_moving() && is_moving() == false:
		orient_target_to_position_on_button_up(position)
	elif last_move_counter >= MOVE_DELAY_MINIMUM && is_moving():
		update_target_if_needed()

	if (
		area_to_use_equipped_item != Vector2.INF
		&& area_to_use_equipped_item.distance_to(position) < 3
	):
		use_equipped_item()
		area_to_use_equipped_item = Vector2.INF


func is_moving():
	return (
		Input.is_action_pressed("move_down")
		|| Input.is_action_pressed("move_up")
		|| Input.is_action_pressed("move_left")
		|| Input.is_action_pressed("move_right")
	)


func was_moving():
	return (
		Input.is_action_just_released("move_down")
		|| Input.is_action_just_released("move_up")
		|| Input.is_action_just_released("move_left")
		|| Input.is_action_just_released("move_right")
	)


func _unhandled_input(event: InputEvent):
	if lock_movement:
		return

	if event is InputEventMouseButton:
		if Input.is_action_just_released("action_one"):
			if (
				update_target_if_needed(true) == false
				&& item_under_target != null
				&& item_under_target.current_interacting_player == self
			):
				item_under_target.interact()

		if Input.is_action_just_released("action_two"):
			update_target_if_needed(true)
			area_to_use_equipped_item = movement_target

		if Input.is_action_just_released("action_three"):
			secondary_action_on_cursor_item()

		return

	if event.is_action_released("action_one"):
		if item_under_target != null:
			item_under_target.interact()

	if event.is_action_released("action_two"):
		use_equipped_item()

	if event.is_action_released("action_three"):
		secondary_action_on_cursor_item()

	if event.is_action_released("action_four"):
		# Inventory_controller.instance.Shift_equipt_item(false);
		pass

	if event.is_action_released("action_five"):
		# Inventory_controller.instance.Shift_equipt_item();
		pass


func restrict_camera_to_tile_map(map: TileMap):
	var limits: Rect2 = map.get_used_rect()
	var cell_size: Vector2 = map.cell_size

	camera.limit_left = int(round(limits.position.x * cell_size.x))
	camera.limit_right = int(round(limits.end.x * cell_size.x))
	camera.limit_top = int(round(limits.position.y * cell_size.y))
	camera.limit_bottom = int(round(limits.end.y * cell_size.y))

	map_constraints["left"] = camera.limit_left
	map_constraints["right"] = camera.limit_right
	map_constraints["top"] = camera.limit_top
	map_constraints["bottom"] = camera.limit_bottom


func on_movement_ping_timer_event():
	send_movement_ping_update()


func send_movement_ping_update():
	if user_id != null:
		MatchEvent.movement({"ping": true, "position": {"x": position.x, "y": position.y}})


func use_equipped_item():
	# if Inventory_controller.instance.equipped_item != null)
	#       Inventory_controller.instance.equipped_item.Primary_action();
	#   }
	pass


func secondary_action_on_cursor_item():
#       IEquiptable_dual_action_item item = item_under_target as IEquiptable_dual_action_item;

#       if (item != null) {
#         item.Secondary_action();
#       }
#     }
	pass


func update_target_if_needed(mouse_movement: bool = false):
	var target: Vector2

	if mouse_movement:
		target = get_global_mouse_position()
	else:
		target = position

	if Input.is_action_pressed("move_up"):
		target.y -= MOVE_POSITION_FROM_BUTTON

	if Input.is_action_pressed("move_down"):
		target.y += MOVE_POSITION_FROM_BUTTON + 16

	if Input.is_action_pressed("move_left"):
		target.x -= MOVE_POSITION_FROM_BUTTON + 16

	if Input.is_action_pressed("move_right"):
		target.x += MOVE_POSITION_FROM_BUTTON + 16

	if (
		target.x < map_constraints["left"]
		|| target.x > map_constraints["right"]
		|| target.y < map_constraints["top"]
		|| target.y > map_constraints["bottom"]
	):
		return false

	return move_target_as_needed(target, mouse_movement)


func orient_target_to_position_on_button_up(position: Vector2):
	var offset: Vector2

	if is_right():
		offset = Vector2(1, 0)
	elif is_left():
		offset = Vector2(-1, 0)
	elif is_up():
		offset = Vector2(0, -1)
	else:
		offset = Vector2(0, 1)

	var target: Vector2 = position + offset

	MatchEvent.movement({"ping": false, "position": {"x": target.x, "y": target.y}})

	target = MoveTarget.world_to_map(position)

	if is_right():
		target.x = target.x + 1
	elif is_left():
		target.x = target.x - 1

	if is_down():
		target.y = target.y + 2
	elif is_up():
		target.y = target.y - 1

	MoveTarget.set_target_tile_from(target * 16)


func move_target_as_needed(target: Vector2, mouse_movement: bool = false):
	if mouse_movement:
		MoveTarget.set_target_tile_from(target)

		target = MoveTarget.get_tile_position()

		direction = get_direction_relative_to_target(target * 16)

		if is_right():
			target.x -= 1
		if is_left():
			target.x += 1
		if is_down():
			target.y -= 1
		if is_up():
			target.y += 1

		print(target)

		target *= 16

		target.x += 8  # compensating as farmers are "centered"

		if target != movement_target:
			last_move_counter = 0
			MatchEvent.movement({"ping": false, "position": {"x": target.x, "y": target.y}})
			return true
	else:
		# if is_left() || is_right():
		# 	target.y = target.y + 1

		MoveTarget.set_target_tile_from(target)

		if target != movement_target:
			last_move_counter = 0
			MatchEvent.movement({"ping": false, "position": {"x": target.x, "y": target.y}})
			return true

	return false
