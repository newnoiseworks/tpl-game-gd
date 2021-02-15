extends Node2D

onready var rain_particles: CPUParticles2D = $RainParticles
onready var cloud_particles: CPUParticles2D = $CloudParticles

const rain_particles_base_amount: int = 1800
const cloud_particles_base_amount: int = 6

var sky
var data: Dictionary

var rain_particles_adjustment_percentage: float = .5
var cloud_particles_adjustment_percentage: float = .5
var initial_realm_setup_complete: bool = false


func _ready():
	TPLG.set_weather(self)
	_window_size_setup()
	RealmEvent.connect("weather_change", self, "_handle_server_weather_change")


func _exit_tree():
	RealmEvent.disconnect("weather_change", self, "_handle_server_weather_change")


func _window_size_setup():
	get_tree().root.connect("size_changed", self, "_on_window_resize")


func _handle_server_weather_change(state, _presence):
	print_debug(state)

	data = JSON.parse(state).result

	execute_weather_change()


func execute_weather_change():
	if sky == null || ! data.has("cloudLevel"):
		return

	cloud_particles_adjustment_percentage = data.cloudLevel
	rain_particles_adjustment_percentage = data.rainLevel
	sky.sun_intensity_variability = data.sunLevel

	if rain_particles_adjustment_percentage > 0:
		sky.set_raining(true)
		rain_particles.show()
		_setup_rain_particles()
	else:
		sky.set_raining(false)
		rain_particles.hide()

	if cloud_particles_adjustment_percentage > 0:
		cloud_particles.show()
		_setup_cloud_particles()
	else:
		cloud_particles.hide()


func _on_window_resize():
	_setup_rain_particles()
	_setup_cloud_particles()


func _setup_rain_particles():
	rain_particles.emission_rect_extents = Vector2(
		OS.window_size.x, rain_particles.emission_rect_extents.y
	)

	var new_amount = int(
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

	if rain_particles.amount != new_amount:
		rain_particles.amount = new_amount


func _setup_cloud_particles():
	cloud_particles.emission_rect_extents = Vector2(
		cloud_particles.emission_rect_extents.x, OS.window_size.y * 2
	)

	cloud_particles.position = Vector2(cloud_particles.position.x, OS.window_size.y / 2)

	var new_amount = int(
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

	if cloud_particles.amount != new_amount:
		cloud_particles.amount = new_amount

	_parallax_cloud_position()


func _parallax_cloud_position():
	# 1. Determine height of scene via TPLG.current_root_scene
	# 2. Determine position of Player vs. height of scene in %
	# 3. Reposition cloud particles vertically in accordance to above %
	pass
