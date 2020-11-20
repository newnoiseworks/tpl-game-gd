extends KinematicBody2D

export var user_id: String
export var character_base: String
# export var dialogue_file: String
# export var dialogue_section: String
export var current_tile: String

const POSITION_COMPARATOR_TIMER_INTERVAL: int = 3

var username: String  # TODO: Move this to Farmer / Player Controller?
var server_derived_position: String
var movement_target: Vector2
var position_from_server: Vector2
var navigation_points: PoolVector2Array = []
var current_nav_index: int
var next_movement_point: Vector2
var direction: Vector2
var velocity: Vector2
var player_position_at_start: Vector2

onready var position_comparator_timer: Timer = $PositionComparator
onready var body_tile_map: TileMap = find_node("Body")
onready var walk_animation: AnimationPlayer = find_node("Walk")
# onready var visibility_notifier: VisibilityNotifier2D = find_node("VisibilityNotifier2D")
onready var username_label: Label = $IGN


func is_up() -> bool:
	return direction == Vector2.UP


func is_down() -> bool:
	return direction == Vector2.DOWN


func is_left() -> bool:
	return direction == Vector2.LEFT


func is_right() -> bool:
	return direction == Vector2.RIGHT


func _ready():
	position_comparator_timer.wait_time = POSITION_COMPARATOR_TIMER_INTERVAL
	position_comparator_timer.one_shot = true
	position_comparator_timer.connect("timeout", self, "_server_position_check")


func _enter_tree():
	if username_label != null && username != null && username != "":
		_set_username(username)

	if server_derived_position:
		move_event_on_load()
	else:
		movement_target = position

	if user_id != null:
		MatchEvent.connect("movement", self, "_handle_move_event")

#       Material = Material.Duplicate() as Material;

	direction = Vector2.DOWN
	# set_idle()


func _exit_tree():
	if user_id != null:
		MatchEvent.disconnect("movement", self, "_handle_move_event")


func _set_username(_username: String):
	username_label.text = _username
	username_label.show()


func set_idle():
	walk_animation.Stop()
	current_tile = "1"
	update_current_tile()


func update_current_tile():
	var dir_str: String = "Up"

	if is_down():
		dir_str = "Down"
	elif is_right():
		dir_str = "Right"
	elif is_left():
		dir_str = "Left"

	var base_tile: String = "%s%s %s" % [character_base, dir_str, current_tile]

	var set: TileSet = body_tile_map.tile_set

	if body_tile_map.get_cell(0, -1) != set.find_tile_by_name(base_tile):
		body_tile_map.set_cell(0, -1, set.find_tile_by_name(base_tile), is_left(), false)


func get_direction_relative_to_target(target: Vector2):
	var vector_diff: Vector2 = position - target
	var _direction: Vector2 = Vector2.DOWN

	if vector_diff == Vector2.ZERO:
		_direction = Vector2.DOWN
	elif abs(vector_diff.x) > abs(vector_diff.y):
		_direction = Vector2.RIGHT if vector_diff.x < 0 else Vector2.LEFT
	else:
		_direction = Vector2.DOWN if vector_diff.y < 0 else Vector2.UP

	return _direction


func _physics_process(_delta: float):
	if navigation_points.size() == 0:
		set_idle()
		return

	if next_movement_point.distance_to(position) <= 1:
		if current_nav_index + 1 < navigation_points.size():
			current_nav_index = current_nav_index + 1
			next_movement_point = navigation_points[current_nav_index]
		else:
			next_movement_point = Vector2.ONE * -1  # ????
			navigation_points = []
			set_idle()

	if position_comparator_timer.is_stopped():
		player_position_at_start = position
		position_comparator_timer.start(POSITION_COMPARATOR_TIMER_INTERVAL)

	if walk_animation.is_playing() == false:
		walk_animation.play()

	_physics_loop()


func _physics_loop():
	direction = get_direction_relative_to_target(movement_target)

	velocity = (next_movement_point - position).normalized()

	var collision: KinematicCollision2D = move_and_collide(velocity)

	if collision != null:
		_on_collision(collision)

	update_current_tile()


func _on_collision(_collision: KinematicCollision2D):
	print_debug("character collision")


func _server_position_check():
	var is_player_stuck: bool = position.distance_to(player_position_at_start) < 8
	var player_far_from_server_position: bool = position.distance_to(position_from_server) > 32

	if is_player_stuck && player_far_from_server_position:
		position = position_from_server


func move_event_on_load():
	_move_event({"x": movement_target.x, "y": movement_target.y, "ping": "0"})


#     public virtual void Interact() {
#       if (!dialogueFile.Empty() && !dialogueSection.Empty()) {
#         DialogueController.Start(dialogueFile, dialogueSection);
#       } else {
#         Logger.Log("Character interaction");
#       }
#     }


func _handle_move_event(msg, presence):
	if msg == null:
		return

	if presence.user_id != user_id:
		return

	var args = JSON.parse(msg).result
	_move_event(args)


func _move_event(args):
	if args.ping == "1":
		position_from_server = Vector2(args.x, args.y)
		return

	movement_target = Vector2(args.x, args.y)
	# navigation_points = TPLNavigation2DController.get_simple_path(position, movement_target, true);
	navigation_points = [movement_target]

#       // NOTE: The below lines draw the dots
#       //TPLNavigation2DController.instance.navigationPoints = navigationPoints;
#       //TPLNavigation2DController.instance.Update();

	current_nav_index = 0

	# if navigation_points != null && navigation_points.size() > 1:
	if navigation_points != null && navigation_points.size() > 0:
		next_movement_point = navigation_points[current_nav_index]
	else:
		next_movement_point = Vector2.ONE * -1  # ????

	update()

#     public void ColorSwap(
#       string shaderTarget,
#       Vector3 targetColor,
#       Vector3 changeColor
#     ) {
#       ShaderMaterial mat = Material as ShaderMaterial;
#       mat.SetShaderParam($"{shaderTarget}Color", targetColor);
#       mat.SetShaderParam($"{shaderTarget}ChangeColor", changeColor);
#     }
