extends Node2D

onready var rain_particles: CPUParticles2D = $RainParticles
onready var cloud_particles: CPUParticles2D = $CloudParticles

const rain_particles_base_amount: int = 900
const cloud_particles_base_amount: int = 15

var rain_particles_adjustment_percentage: float = .5
var cloud_particles_adjustment_percentage: float = .5


func _ready():
	window_size_setup()


func window_size_setup():
	get_tree().root.connect("size_changed", self, "on_window_resize")


func on_window_resize():
	setup_rain_particles()
	setup_cloud_particles()


func setup_rain_particles():
	rain_particles.emission_rect_extents = Vector2(
		OS.window_size.x, rain_particles.emission_rect_extents.y
	)

	rain_particles.amount = int(
		clamp(
			(
				(rain_particles_base_amount * rain_particles_adjustment_percentage)
				/ 720
				* OS.window_size.x
			),
			1,
			INF
		)
	)


func setup_cloud_particles():
	cloud_particles.emission_rect_extents = Vector2(
		cloud_particles.emission_rect_extents.x, OS.window_size.y * 2
	)

	cloud_particles.position = Vector2(cloud_particles.position.x, OS.window_size.y / 2)

	cloud_particles.amount = int(
		clamp(
			(
				(cloud_particles_base_amount * cloud_particles_adjustment_percentage)
				/ 340
				* OS.window_size.y
			),
			1,
			INF
		)
	)

	parallax_cloud_position()


func parallax_cloud_position():
	# 1. Determine height of scene via TPLG.current_root_scene
	# 2. Determine position of Player vs. height of scene in %
	# 3. Reposition cloud particles vertically in accordance to above %
	pass
