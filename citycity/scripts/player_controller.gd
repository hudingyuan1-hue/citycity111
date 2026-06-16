extends CharacterBody3D

@export var move_speed := 4.2
@export var mouse_sensitivity := 0.0025
@export var mouse_smoothing_enabled := true
@export_range(1.0, 40.0, 0.5) var mouse_smoothing_factor := 14.0
@export var pitch_min := -78.0
@export var pitch_max := 78.0
@export var mouse_drag_rotate_enabled := true
@export var mouse_enabled_in_exploration := true
@export var mouse_disabled_in_ui := true

@export var head_bob_enabled := true
@export var head_bob_amplitude := 0.035
@export var head_bob_frequency := 8.0
@export var head_bob_return_speed := 8.0

@export var footstep_enabled := true
@export var footstep_interval := 0.56
@export var footstep_volume := -18.0
@export var footstep_pitch_random_min := 0.92
@export var footstep_pitch_random_max := 1.08
@export var grey_footstep_duration := 0.18
@export var city_footstep_duration := 0.16
@export var footstep_bus := "WorldReverb"

var movement_locked := true
var look_locked := false
var camera: Camera3D
var head: Node3D
var footstep_player: AudioStreamPlayer
var footstep_generator: AudioStreamGenerator
var footstep_playback: AudioStreamGeneratorPlayback
var current_footstep_set := "grey"
var current_yaw := 0.0
var current_pitch := 0.0
var target_yaw := 0.0
var target_pitch := 0.0
var base_camera_y := 1.65
var head_bob_time := 0.0
var footstep_timer := 0.0
var footstep_time_left := 0.0
var footstep_elapsed := 0.0
var footstep_duration := 0.16
var footstep_frequency := 95.0
var footstep_noise_amount := 0.65
var footstep_tone_amount := 0.3
var footstep_rng := RandomNumberGenerator.new()
var is_moving_on_ground := false
var is_mouse_dragging := false

func _ready() -> void:
	footstep_rng.randomize()
	head = Node3D.new()
	head.name = "Head"
	add_child(head)

	camera = Camera3D.new()
	camera.name = "Camera3D"
	camera.current = true
	camera.position.y = base_camera_y
	head.add_child(camera)

	footstep_generator = AudioStreamGenerator.new()
	footstep_generator.mix_rate = 22050
	footstep_generator.buffer_length = 0.12
	footstep_player = AudioStreamPlayer.new()
	footstep_player.name = "FootstepPlayer"
	footstep_player.stream = footstep_generator
	footstep_player.volume_db = footstep_volume
	footstep_player.bus = footstep_bus
	add_child(footstep_player)

	var shape := CollisionShape3D.new()
	shape.name = "PlayerCollision"
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.75
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)

	collision_layer = 2
	collision_mask = 1

func _input(event: InputEvent) -> void:
	if not mouse_enabled_in_exploration:
		return
	if look_locked or (mouse_disabled_in_ui and movement_locked):
		is_mouse_dragging = false
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_mouse_dragging = event.pressed and mouse_drag_rotate_enabled
		return
	if event is InputEventMouseMotion:
		if not mouse_drag_rotate_enabled or not is_mouse_dragging:
			return
		target_yaw -= event.relative.x * mouse_sensitivity
		target_pitch = clamp(target_pitch - event.relative.y * mouse_sensitivity, deg_to_rad(pitch_min), deg_to_rad(pitch_max))

func _process(delta: float) -> void:
	_update_look(delta)
	_update_head_bob(delta)
	_update_footsteps(delta)

func _physics_process(_delta: float) -> void:
	if movement_locked:
		velocity = Vector3.ZERO
		is_moving_on_ground = false
		move_and_slide()
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var wish_dir := (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	velocity.x = wish_dir.x * move_speed
	velocity.z = wish_dir.z * move_speed
	velocity.y = 0.0
	move_and_slide()
	is_moving_on_ground = input_dir.length() > 0.05 and is_on_floor()

func set_locked(locked: bool) -> void:
	movement_locked = locked
	if locked:
		is_mouse_dragging = false
		is_moving_on_ground = false
		footstep_timer = 0.0
		_stop_footstep_burst()
		sync_look_targets()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_look_locked(locked: bool) -> void:
	look_locked = locked
	if locked:
		is_mouse_dragging = false
		sync_look_targets()

func set_footstep_set(set_name: String) -> void:
	current_footstep_set = set_name

func set_footstep_bus(bus_name: String) -> void:
	footstep_bus = bus_name
	if footstep_player != null:
		footstep_player.bus = bus_name

func add_pitch_offset(offset_degrees: float) -> void:
	target_pitch = clamp(target_pitch + deg_to_rad(offset_degrees), deg_to_rad(pitch_min), deg_to_rad(pitch_max))
	current_pitch = clamp(current_pitch + deg_to_rad(offset_degrees), deg_to_rad(pitch_min), deg_to_rad(pitch_max))
	head.rotation.x = current_pitch

func sync_look_targets() -> void:
	current_yaw = rotation.y
	target_yaw = rotation.y
	current_pitch = head.rotation.x
	target_pitch = head.rotation.x

func _update_look(delta: float) -> void:
	if mouse_smoothing_enabled:
		var weight := 1.0 - exp(-mouse_smoothing_factor * delta)
		current_yaw = lerp_angle(current_yaw, target_yaw, weight)
		current_pitch = lerp(current_pitch, target_pitch, weight)
	else:
		current_yaw = target_yaw
		current_pitch = target_pitch
	rotation.y = current_yaw
	head.rotation.x = clamp(current_pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))

func _update_head_bob(delta: float) -> void:
	if head_bob_enabled and is_moving_on_ground and not movement_locked:
		var speed_factor: float = clamp(Vector2(velocity.x, velocity.z).length() / max(move_speed, 0.01), 0.0, 1.4)
		head_bob_time += delta * head_bob_frequency * speed_factor
		camera.position.y = base_camera_y + sin(head_bob_time) * head_bob_amplitude * speed_factor
	else:
		head_bob_time = 0.0
		camera.position.y = lerp(camera.position.y, base_camera_y, 1.0 - exp(-head_bob_return_speed * delta))

func _update_footsteps(delta: float) -> void:
	_fill_footstep_burst(delta)
	if not footstep_enabled or movement_locked or not is_moving_on_ground:
		footstep_timer = 0.0
		return

	var speed_factor: float = clamp(Vector2(velocity.x, velocity.z).length() / max(move_speed, 0.01), 0.35, 1.5)
	footstep_timer -= delta * speed_factor
	if footstep_timer <= 0.0:
		_trigger_footstep(speed_factor)
		footstep_timer = footstep_interval / speed_factor

func _trigger_footstep(speed_factor: float) -> void:
	if current_footstep_set == "city":
		footstep_duration = city_footstep_duration
		footstep_frequency = footstep_rng.randf_range(145.0, 235.0)
		footstep_noise_amount = 0.42
		footstep_tone_amount = 0.22
	else:
		footstep_duration = grey_footstep_duration
		footstep_frequency = footstep_rng.randf_range(55.0, 105.0)
		footstep_noise_amount = 0.78
		footstep_tone_amount = 0.12
	footstep_time_left = footstep_duration
	footstep_elapsed = 0.0
	footstep_player.volume_db = footstep_volume
	footstep_player.pitch_scale = footstep_rng.randf_range(footstep_pitch_random_min, footstep_pitch_random_max) * lerp(0.95, 1.05, speed_factor - 0.35)
	footstep_player.play()
	footstep_playback = footstep_player.get_stream_playback()

func _fill_footstep_burst(_delta: float) -> void:
	if footstep_time_left <= 0.0:
		return
	if footstep_playback == null:
		footstep_playback = footstep_player.get_stream_playback()
	if footstep_playback == null:
		return

	var frames := footstep_playback.get_frames_available()
	for i in range(frames):
		if footstep_time_left <= 0.0:
			_stop_footstep_burst()
			return
		var t := footstep_elapsed
		var envelope := pow(max(1.0 - t / footstep_duration, 0.0), 2.3)
		var noise := footstep_rng.randf_range(-1.0, 1.0) * footstep_noise_amount
		var tone := sin(TAU * footstep_frequency * t) * footstep_tone_amount
		var sample := (noise + tone) * envelope * 0.18
		footstep_playback.push_frame(Vector2(sample, sample))
		footstep_elapsed += 1.0 / footstep_generator.mix_rate
		footstep_time_left -= 1.0 / footstep_generator.mix_rate

func _stop_footstep_burst() -> void:
	footstep_time_left = 0.0
	if footstep_player != null and footstep_player.playing:
		footstep_player.stop()
