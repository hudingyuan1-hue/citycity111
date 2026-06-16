extends Node3D

const PlayerController := preload("res://scripts/player_controller.gd")

enum GamePhase { MAIN_MENU, HEADPHONE, THEME_SELECT, GREY_VOID, MANIFESTING, CITY, READING, CHOICE, PAUSED }

const MEMORY_POS := Vector3(18.0, 0.0, 10.0)
const PLAYER_SPAWN := Vector3(-48.0, 0.0, -42.0)
const AUDIO_PATH := "res://assets/audio/memory_theme_loop.ogg"
const THEME_NAMES := [
	"记忆", "欲望", "标志", "薄的", "贸易", "眼睛", "姓名", "死的", "天空", "连续的", "隐"
]
const ZONE_POSITIONS := [
	Vector3(18, 0, 10),
	Vector3(-34, 0, 26),
	Vector3(44, 0, -32),
	Vector3(-16, 0, -40),
	Vector3(38, 0, 39),
	Vector3(-45, 0, -3),
	Vector3(7, 0, -48),
	Vector3(49, 0, 1),
	Vector3(-9, 0, 45),
	Vector3(-39, 0, -34),
	Vector3(0, 0, 0)
]
const READING_PAGES := [
	["你抵达的不是城市。", "是一段留下来的回声。"],
	["门开过很多次。", "每一次，都通向从前。"],
	["街道记得脚步。", "窗户记得名字。"],
	["你以为你在寻找它。", "其实它一直等你听见。"],
	["要把这座城留下吗？"]
]

@export_group("Manifestation Polish")
@export var manifestation_duration := 8.0
@export var fog_start_value := 0.075
@export var fog_end_value := 0.0
@export var particle_fade_start := 1.0
@export var particle_fade_end := 7.2
@export var camera_framing_enabled := true
@export var manifestation_camera_pitch_offset := 7.0
@export var manifestation_camera_framing_duration := 7.0

@export_group("Player Feel")
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

@export_group("UI Fade")
@export var ui_fade_in_duration := 1.6
@export var ui_hold_duration := 3.0
@export var ui_fade_out_duration := 2.0
@export var choice_fade_in_duration := 1.0
@export var operation_hint_display_duration := 8.0

@export_group("Dynamic Reverb")
@export var reverb_wet_min := 0.12
@export var reverb_wet_max := 0.48
@export var reverb_room_size_min := 0.28
@export var reverb_room_size_max := 0.86
@export var reverb_transition_speed := 2.2
@export var city_reverb_wet := 0.18
@export var city_reverb_room_size := 0.42

var phase := GamePhase.MAIN_MENU
var previous_phase := GamePhase.MAIN_MENU
var player
var world_environment: WorldEnvironment
var environment: Environment
var ui_root: Control
var main_menu: Control
var headphone_prompt: Control
var theme_select: Control
var hint_label: Label
var reading_panel: Control
var reading_text: Label
var reading_next_button: Button
var choice_panel: Control
var pause_menu: Control
var operation_hint_panel: Control
var operation_hint_label: Label
var direction_tint: ColorRect
var grey_visual_root: Node3D
var grey_particles: GPUParticles3D
var grey_silhouettes: Node3D
var sound_zones: Node3D
var memory_center_trigger: Area3D
var manifested_city: Node3D
var city_visual_root: Node3D
var city_collision_root: Node3D
var reading_trigger: Area3D
var memory_zone_player: AudioStreamPlayer3D
var global_music_player: AudioStreamPlayer
var zone_audio_players: Array[AudioStreamPlayer3D] = []
var generator_playbacks: Array = []
var generator_phases: Array[float] = []
var hint_cache := ""
var reading_page := 0
var can_read_tower := false
var manifest_started := false
var memory_bus_index := -1
var world_reverb_bus_index := -1
var memory_lowpass: AudioEffectLowPassFilter
var world_reverb: AudioEffectReverb
var hint_tween: Tween
var headphone_tween: Tween
var operation_hint_tween: Tween
var manifest_camera_applied_offset := 0.0
var operation_hint_shown_once := false

func _ready() -> void:
	_ensure_input_actions()
	_setup_audio_bus()
	_build_world()
	_build_ui()
	_enter_main_menu()

func _process(delta: float) -> void:
	_fill_generated_audio()
	if phase == GamePhase.GREY_VOID:
		_update_memory_audio()
		_update_direction_feedback()
		_update_dynamic_reverb(delta)
	elif phase == GamePhase.CITY:
		direction_tint.color.a = lerp(direction_tint.color.a, 0.0, delta * 3.0)
		_update_city_reverb(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if phase in [GamePhase.GREY_VOID, GamePhase.CITY]:
			_show_pause_menu()
		elif phase == GamePhase.PAUSED:
			_hide_pause_menu()
	if event.is_action_pressed("repeat_hint") and hint_cache != "":
		if phase in [GamePhase.GREY_VOID, GamePhase.CITY]:
			_show_operation_hint()
		else:
			_show_hint(hint_cache, 3.0)
	if event.is_action_pressed("interact") and phase == GamePhase.CITY and can_read_tower:
		_open_reading()

func _setup_audio_bus() -> void:
	world_reverb_bus_index = AudioServer.get_bus_index("WorldReverb")
	if world_reverb_bus_index == -1:
		AudioServer.add_bus()
		world_reverb_bus_index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(world_reverb_bus_index, "WorldReverb")
	world_reverb = AudioEffectReverb.new()
	world_reverb.wet = reverb_wet_max
	world_reverb.room_size = reverb_room_size_max
	AudioServer.add_bus_effect(world_reverb_bus_index, world_reverb)

	memory_bus_index = AudioServer.get_bus_index("MemoryZone")
	if memory_bus_index == -1:
		AudioServer.add_bus()
		memory_bus_index = AudioServer.get_bus_count() - 1
		AudioServer.set_bus_name(memory_bus_index, "MemoryZone")
	AudioServer.set_bus_send(memory_bus_index, "WorldReverb")
	memory_lowpass = AudioEffectLowPassFilter.new()
	memory_lowpass.cutoff_hz = 650.0
	AudioServer.add_bus_effect(memory_bus_index, memory_lowpass)

func _ensure_input_actions() -> void:
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("interact", KEY_E)
	_add_key_action("repeat_hint", KEY_H)
	_add_key_action("ui_cancel", KEY_ESCAPE)

func _add_key_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if InputMap.action_get_events(action_name).is_empty():
		var event := InputEventKey.new()
		event.keycode = keycode
		InputMap.action_add_event(action_name, event)

func _apply_player_polish_settings() -> void:
	player.mouse_sensitivity = mouse_sensitivity
	player.mouse_smoothing_enabled = mouse_smoothing_enabled
	player.mouse_smoothing_factor = mouse_smoothing_factor
	player.pitch_min = pitch_min
	player.pitch_max = pitch_max
	player.mouse_drag_rotate_enabled = mouse_drag_rotate_enabled
	player.mouse_enabled_in_exploration = mouse_enabled_in_exploration
	player.mouse_disabled_in_ui = mouse_disabled_in_ui
	player.head_bob_enabled = head_bob_enabled
	player.head_bob_amplitude = head_bob_amplitude
	player.head_bob_frequency = head_bob_frequency
	player.head_bob_return_speed = head_bob_return_speed
	player.footstep_enabled = footstep_enabled
	player.footstep_interval = footstep_interval
	player.footstep_volume = footstep_volume
	player.footstep_pitch_random_min = footstep_pitch_random_min
	player.footstep_pitch_random_max = footstep_pitch_random_max

func _build_world() -> void:
	world_environment = WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.55, 0.56, 0.55)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.64, 0.64, 0.62)
	environment.ambient_light_energy = 0.9
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.65, 0.66, 0.65)
	environment.fog_density = 0.075
	environment.fog_sky_affect = 0.75
	environment.adjustment_enabled = true
	environment.adjustment_saturation = 0.22
	environment.adjustment_contrast = 0.65
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.name = "MutedSun"
	sun.rotation_degrees = Vector3(-45, -35, 0)
	sun.light_energy = 1.2
	add_child(sun)

	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PlayerController)
	add_child(player)
	player.global_position = PLAYER_SPAWN
	_apply_player_polish_settings()
	player.set_footstep_bus("WorldReverb")

	var level := Node3D.new()
	level.name = "GreyVoidLevel"
	add_child(level)

	_build_grey_void(level)
	_build_sound_zones(level)
	_build_manifested_city()
	_build_audio_players()

func _build_grey_void(level: Node3D) -> void:
	grey_visual_root = Node3D.new()
	grey_visual_root.name = "GreyVisualRoot"
	level.add_child(grey_visual_root)

	var ground_mesh := MeshInstance3D.new()
	ground_mesh.name = "GreyGround"
	var plane := PlaneMesh.new()
	plane.size = Vector2(120, 120)
	ground_mesh.mesh = plane
	ground_mesh.material_override = _mat(Color(0.42, 0.43, 0.42), 1.0)
	grey_visual_root.add_child(ground_mesh)

	var ground_body := StaticBody3D.new()
	ground_body.name = "GreyGroundCollision"
	ground_body.collision_layer = 1
	ground_body.collision_mask = 2
	level.add_child(ground_body)
	var ground_collision := CollisionShape3D.new()
	var ground_shape := BoxShape3D.new()
	ground_shape.size = Vector3(120, 0.2, 120)
	ground_collision.shape = ground_shape
	ground_collision.position.y = -0.1
	ground_body.add_child(ground_collision)

	grey_silhouettes = Node3D.new()
	grey_silhouettes.name = "DistantBlockOutlines"
	grey_visual_root.add_child(grey_silhouettes)
	for i in range(18):
		var angle := TAU * float(i) / 18.0
		var radius := 37.0 + float(i % 4) * 4.0
		var pos := Vector3(cos(angle) * radius, 2.2, sin(angle) * radius)
		var block := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(4.0 + i % 3, 4.5 + i % 5, 3.0 + i % 4)
		block.mesh = box
		block.position = pos
		block.rotation_degrees.y = i * 17
		block.material_override = _mat(Color(0.35, 0.36, 0.36, 0.34), 0.34)
		grey_silhouettes.add_child(block)

	grey_particles = GPUParticles3D.new()
	grey_particles.name = "GreyParticles"
	grey_particles.amount = 420
	grey_particles.lifetime = 5.0
	grey_particles.visibility_aabb = AABB(Vector3(-60, -4, -60), Vector3(120, 12, 120))
	var particle_mesh := QuadMesh.new()
	particle_mesh.size = Vector2(0.08, 0.08)
	grey_particles.draw_pass_1 = particle_mesh
	var particle_process := ParticleProcessMaterial.new()
	particle_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	particle_process.emission_box_extents = Vector3(55, 4, 55)
	particle_process.gravity = Vector3.ZERO
	particle_process.initial_velocity_min = 0.25
	particle_process.initial_velocity_max = 0.9
	particle_process.direction = Vector3(1, 0, 0)
	particle_process.spread = 80.0
	particle_process.color = Color(0.82, 0.82, 0.78, 0.22)
	grey_particles.process_material = particle_process
	grey_particles.emitting = true
	grey_visual_root.add_child(grey_particles)

func _build_sound_zones(level: Node3D) -> void:
	sound_zones = Node3D.new()
	sound_zones.name = "SoundZones"
	level.add_child(sound_zones)
	for i in range(THEME_NAMES.size()):
		var marker := Node3D.new()
		marker.name = "Zone_%s" % _ascii_zone_name(THEME_NAMES[i], i)
		marker.position = ZONE_POSITIONS[i]
		sound_zones.add_child(marker)

	memory_center_trigger = Area3D.new()
	memory_center_trigger.name = "MemoryCenterTrigger"
	memory_center_trigger.position = MEMORY_POS
	memory_center_trigger.collision_layer = 0
	memory_center_trigger.collision_mask = 2
	var trigger_shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 5.0
	trigger_shape.shape = sphere
	memory_center_trigger.add_child(trigger_shape)
	memory_center_trigger.body_entered.connect(_on_memory_center_entered)
	sound_zones.add_child(memory_center_trigger)

func _build_manifested_city() -> void:
	manifested_city = Node3D.new()
	manifested_city.name = "ManifestedCity"
	manifested_city.visible = false
	add_child(manifested_city)

	city_visual_root = Node3D.new()
	city_visual_root.name = "CityVisualRoot"
	manifested_city.add_child(city_visual_root)

	city_collision_root = Node3D.new()
	city_collision_root.name = "CityCollisionRoot"
	manifested_city.add_child(city_collision_root)

	_build_memory_courtyard()
	_build_repeated_doors()
	_build_corridor_blocks()
	_build_echo_tower()
	_set_city_collision_enabled(false)

func _build_memory_courtyard() -> void:
	var root := Node3D.new()
	root.name = "MemoryCourtyard"
	city_visual_root.add_child(root)

	var disk := CSGCylinder3D.new()
	disk.name = "RingPlaza"
	disk.radius = 18.0
	disk.height = 0.18
	disk.sides = 48
	disk.position.y = 0.02
	disk.material = _mat(Color(0.62, 0.61, 0.56), 1.0)
	root.add_child(disk)
	_add_box_collision("RingPlazaCollision", Vector3(0, 0.08, 0), Vector3(36, 0.18, 36))

	for i in range(12):
		var angle := TAU * float(i) / 12.0
		var stone := CSGBox3D.new()
		stone.name = "PlazaMarker_%02d" % i
		stone.size = Vector3(1.1, 0.3, 3.4)
		stone.position = Vector3(cos(angle) * 17.0, 0.25, sin(angle) * 17.0)
		stone.rotation.y = -angle
		stone.material = _mat(Color(0.47, 0.47, 0.44), 1.0)
		root.add_child(stone)

func _build_repeated_doors() -> void:
	var root := Node3D.new()
	root.name = "RepeatedDoors"
	city_visual_root.add_child(root)
	for row in range(2):
		for i in range(7):
			var x := -24.0 + i * 8.0
			var z := -24.0 if row == 0 else 24.0
			_add_door_frame(root, Vector3(x, 0, z), 0.0 if row == 0 else 180.0)

func _build_corridor_blocks() -> void:
	var root := Node3D.new()
	root.name = "CorridorBlocks"
	city_visual_root.add_child(root)

	var block_specs := [
		[Vector3(-30, 2.2, -8), Vector3(7, 4.4, 10), 8.0],
		[Vector3(-28, 1.8, 12), Vector3(9, 3.6, 7), -13.0],
		[Vector3(28, 2.4, -12), Vector3(8, 4.8, 9), -6.0],
		[Vector3(31, 1.7, 11), Vector3(6, 3.4, 12), 11.0],
		[Vector3(-8, 1.6, 31), Vector3(18, 3.2, 5), 0.0],
		[Vector3(9, 2.0, -33), Vector3(16, 4.0, 5), 0.0]
	]
	for i in range(block_specs.size()):
		var box := CSGBox3D.new()
		box.name = "EmptyRoomBlock_%02d" % i
		box.position = block_specs[i][0]
		box.size = block_specs[i][1]
		box.rotation_degrees.y = block_specs[i][2]
		box.material = _mat(Color(0.52, 0.53, 0.50), 1.0)
		root.add_child(box)
		_add_box_collision(box.name + "Collision", box.position, box.size, box.rotation_degrees.y)

	for i in range(5):
		var wall := CSGBox3D.new()
		wall.name = "LeaningOldWall_%02d" % i
		wall.size = Vector3(1.0, 4.6, 8.0)
		wall.position = Vector3(-18 + i * 9, 2.3, 38)
		wall.rotation_degrees = Vector3(0, -18 + i * 8, -5 + i * 2)
		wall.material = _mat(Color(0.45, 0.46, 0.44), 1.0)
		root.add_child(wall)
		_add_box_collision(wall.name + "Collision", wall.position, wall.size, wall.rotation_degrees.y)

	for i in range(8):
		var z := -8.0 + i * 2.4
		_add_arch(root, Vector3(42, 0, z), 90.0, i)

func _build_echo_tower() -> void:
	var root := Node3D.new()
	root.name = "EchoTower"
	city_visual_root.add_child(root)

	var base := CSGCylinder3D.new()
	base.name = "TowerBase"
	base.radius = 4.4
	base.height = 1.1
	base.sides = 32
	base.position.y = 0.55
	base.material = _mat(Color(0.50, 0.50, 0.47), 1.0)
	root.add_child(base)
	_add_box_collision("EchoTowerBaseCollision", Vector3(0, 0.55, 0), Vector3(9, 1.1, 9))

	var shaft := CSGCylinder3D.new()
	shaft.name = "CylinderMainTower"
	shaft.radius = 2.35
	shaft.height = 15.0
	shaft.sides = 40
	shaft.position.y = 8.1
	shaft.material = _mat(Color(0.58, 0.58, 0.53), 1.0)
	root.add_child(shaft)
	_add_box_collision("EchoTowerShaftCollision", Vector3(0, 8.1, 0), Vector3(5, 15, 5))

	for i in range(6):
		var angle := TAU * float(i) / 6.0
		var win := CSGBox3D.new()
		win.name = "BlackWindow_%02d" % i
		win.size = Vector3(0.08, 1.6, 0.8)
		win.position = Vector3(cos(angle) * 2.38, 9.0, sin(angle) * 2.38)
		win.rotation.y = -angle
		win.material = _mat(Color(0.03, 0.035, 0.04), 1.0)
		root.add_child(win)

	var bell := CSGCylinder3D.new()
	bell.name = "SimpleBellTop"
	bell.radius = 3.0
	bell.height = 2.2
	bell.sides = 32
	bell.position.y = 16.8
	bell.material = _mat(Color(0.43, 0.43, 0.39), 1.0)
	root.add_child(bell)

	var cap := CSGCylinder3D.new()
	cap.name = "FlatCap"
	cap.radius = 1.6
	cap.height = 1.2
	cap.sides = 24
	cap.position.y = 18.5
	cap.material = _mat(Color(0.36, 0.36, 0.34), 1.0)
	root.add_child(cap)

	reading_trigger = Area3D.new()
	reading_trigger.name = "ReadingTrigger"
	reading_trigger.position = Vector3(0, 0.8, 5.2)
	reading_trigger.collision_layer = 0
	reading_trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 3.2
	shape.shape = sphere
	reading_trigger.add_child(shape)
	reading_trigger.body_entered.connect(_on_reading_trigger_entered)
	reading_trigger.body_exited.connect(_on_reading_trigger_exited)
	manifested_city.add_child(reading_trigger)

func _build_audio_players() -> void:
	global_music_player = AudioStreamPlayer.new()
	global_music_player.name = "GlobalMemoryMusic"
	global_music_player.volume_db = -12.0
	global_music_player.bus = "WorldReverb"
	global_music_player.stream = _memory_stream()
	add_child(global_music_player)
	_register_generator(global_music_player, 196.0)

	for i in range(THEME_NAMES.size()):
		var p := AudioStreamPlayer3D.new()
		p.name = "Audio_%s" % _ascii_zone_name(THEME_NAMES[i], i)
		p.position = ZONE_POSITIONS[i]
		p.max_distance = 75.0
		p.unit_size = 12.0
		p.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		p.volume_db = -8.0 if i == 0 else -25.0
		p.stream = _memory_stream()
		if i == 0:
			p.bus = "MemoryZone"
			memory_zone_player = p
		add_child(p)
		_register_generator(p, 196.0 + float(i) * 17.0)

func _build_ui() -> void:
	ui_root = Control.new()
	ui_root.name = "UI"
	ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(ui_root)

	direction_tint = ColorRect.new()
	direction_tint.name = "DirectionFeedbackController"
	direction_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	direction_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	direction_tint.color = Color(0.72, 0.62, 0.45, 0.0)
	ui_root.add_child(direction_tint)

	main_menu = _center_panel("MainMenu")
	var title := _label("看不见的城市\nInvisible Cities", 38)
	main_menu.add_child(title)
	main_menu.add_child(_button("开始", _on_start_pressed))
	main_menu.add_child(_button("选项", func(): _show_hint("第一版仅保留基础音量与鼠标体验。", 3.0)))
	main_menu.add_child(_button("退出", func(): get_tree().quit()))
	ui_root.add_child(main_menu)

	headphone_prompt = _center_panel("HeadphonePrompt")
	headphone_prompt.add_child(_label("请戴上耳机。\n在看见之前，先听见。", 30))
	headphone_prompt.add_child(_button("继续", _enter_theme_select))
	ui_root.add_child(headphone_prompt)

	theme_select = _center_panel("ThemeSelect")
	theme_select.add_child(_label("选择一座看不见的城市", 30))
	for i in range(THEME_NAMES.size()):
		var b := _button(THEME_NAMES[i], _on_memory_theme_pressed if i == 0 else _disabled_theme_pressed)
		if i != 0:
			b.disabled = true
			b.modulate = Color(0.55, 0.55, 0.55, 0.75)
		theme_select.add_child(b)
	ui_root.add_child(theme_select)

	hint_label = Label.new()
	hint_label.name = "HintText"
	hint_label.text = ""
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 24)
	hint_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint_label.offset_top = -120
	hint_label.offset_bottom = -48
	hint_label.modulate.a = 0.0
	ui_root.add_child(hint_label)

	reading_panel = _center_panel("ReadingPanel")
	reading_text = _label("", 28)
	reading_panel.add_child(reading_text)
	reading_next_button = _button("继续", _advance_reading)
	reading_panel.add_child(reading_next_button)
	ui_root.add_child(reading_panel)

	choice_panel = _center_panel("ChoicePanel")
	choice_panel.add_child(_label("要把这座城留下吗？", 28))
	choice_panel.add_child(_button("留：让它成为我的城市", _choose_stay))
	choice_panel.add_child(_button("去：前往下一座看不见的城市", _choose_leave))
	ui_root.add_child(choice_panel)

	pause_menu = _center_panel("PauseMenu")
	pause_menu.add_child(_label("暂停", 30))
	pause_menu.add_child(_button("继续", _hide_pause_menu))
	pause_menu.add_child(_button("返回主题选择", _return_to_theme_select))
	ui_root.add_child(pause_menu)

	operation_hint_panel = PanelContainer.new()
	operation_hint_panel.name = "OperationHint"
	operation_hint_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	operation_hint_panel.offset_left = -260
	operation_hint_panel.offset_right = -24
	operation_hint_panel.offset_top = 24
	operation_hint_panel.offset_bottom = 230
	operation_hint_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	operation_hint_panel.modulate.a = 0.0
	var hint_style := StyleBoxFlat.new()
	hint_style.bg_color = Color(0.04, 0.045, 0.05, 0.34)
	hint_style.corner_radius_top_left = 6
	hint_style.corner_radius_top_right = 6
	hint_style.corner_radius_bottom_left = 6
	hint_style.corner_radius_bottom_right = 6
	operation_hint_panel.add_theme_stylebox_override("panel", hint_style)
	operation_hint_label = Label.new()
	operation_hint_label.text = "前进：W\n后退：S\n左移：A\n右移：D\n转动视角：按住鼠标左键拖动\n交互：E\n暂停：Esc\n帮助：H"
	operation_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	operation_hint_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	operation_hint_label.add_theme_font_size_override("font_size", 16)
	operation_hint_label.add_theme_color_override("font_color", Color(0.88, 0.88, 0.82, 0.88))
	operation_hint_label.set("theme_override_constants/line_spacing", 4)
	operation_hint_panel.add_child(operation_hint_label)
	ui_root.add_child(operation_hint_panel)

	_hide_all_ui()

func _enter_main_menu() -> void:
	phase = GamePhase.MAIN_MENU
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.set_locked(true)
	player.set_look_locked(true)
	_hide_operation_hint()
	_hide_all_ui()
	main_menu.visible = true

func _on_start_pressed() -> void:
	phase = GamePhase.HEADPHONE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.set_locked(true)
	player.set_look_locked(true)
	_hide_operation_hint()
	_hide_all_ui()
	headphone_prompt.visible = true
	headphone_prompt.modulate.a = 0.0
	if headphone_tween != null:
		headphone_tween.kill()
	headphone_tween = create_tween()
	headphone_tween.tween_property(headphone_prompt, "modulate:a", 1.0, ui_fade_in_duration)
	headphone_tween.tween_interval(ui_hold_duration)
	headphone_tween.tween_property(headphone_prompt, "modulate:a", 0.0, ui_fade_out_duration)
	headphone_tween.tween_callback(func():
		if phase == GamePhase.HEADPHONE:
			_enter_theme_select()
	)

func _enter_theme_select() -> void:
	if headphone_tween != null:
		headphone_tween.kill()
	phase = GamePhase.THEME_SELECT
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	player.set_locked(true)
	player.set_look_locked(true)
	_hide_operation_hint()
	_reset_level_state()
	_hide_all_ui()
	theme_select.visible = true

func _on_memory_theme_pressed() -> void:
	phase = GamePhase.GREY_VOID
	_hide_all_ui()
	player.global_position = PLAYER_SPAWN
	player.rotation = Vector3.ZERO
	player.head.rotation = Vector3.ZERO
	player.sync_look_targets()
	player.set_footstep_set("grey")
	player.set_look_locked(false)
	player.set_locked(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	manifested_city.visible = false
	grey_visual_root.visible = true
	grey_particles.emitting = true
	memory_zone_player.play()
	for p in zone_audio_players:
		if not p.playing:
			p.play()
	_show_hint("在看见之前，先听见。", 4.0)
	if not operation_hint_shown_once:
		operation_hint_shown_once = true
		_show_operation_hint()

func _disabled_theme_pressed() -> void:
	pass

func _on_memory_center_entered(body: Node3D) -> void:
	if body == player and phase == GamePhase.GREY_VOID and not manifest_started:
		_start_manifest_sequence()

func _start_manifest_sequence() -> void:
	manifest_started = true
	phase = GamePhase.MANIFESTING
	player.set_locked(true)
	player.set_look_locked(true)
	_hide_operation_hint()
	manifest_camera_applied_offset = 0.0
	manifested_city.visible = true
	_set_city_collision_enabled(false)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(environment, "fog_density", fog_end_value, manifestation_duration).from(fog_start_value).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(environment, "adjustment_saturation", 1.0, manifestation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(environment, "adjustment_contrast", 1.0, manifestation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(grey_particles, "amount", 0, max(particle_fade_end - particle_fade_start, 0.1)).set_delay(particle_fade_start).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(memory_zone_player, "volume_db", -40.0, 2.0)
	tween.tween_property(global_music_player, "volume_db", -9.0, 2.0)
	tween.tween_callback(func(): grey_silhouettes.visible = false).set_delay(max(manifestation_duration - 1.4, 0.1))
	tween.tween_property(world_reverb, "wet", city_reverb_wet, manifestation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(world_reverb, "room_size", city_reverb_room_size, manifestation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if camera_framing_enabled:
		tween.tween_method(_apply_manifest_camera_offset, 0.0, manifestation_camera_pitch_offset, manifestation_camera_framing_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	global_music_player.play()
	for p in zone_audio_players:
		if p != memory_zone_player:
			tween.tween_property(p, "volume_db", -45.0, 1.6)
	await tween.finished
	grey_visual_root.visible = false
	grey_particles.emitting = false
	_set_city_collision_enabled(true)
	phase = GamePhase.CITY
	player.set_footstep_set("city")
	player.set_look_locked(false)
	player.sync_look_targets()
	player.set_locked(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_show_hint("去寻找回声塔。", 4.0)

func _apply_manifest_camera_offset(offset_degrees: float) -> void:
	var delta := offset_degrees - manifest_camera_applied_offset
	manifest_camera_applied_offset = offset_degrees
	player.add_pitch_offset(delta)

func _on_reading_trigger_entered(body: Node3D) -> void:
	if body == player and phase == GamePhase.CITY:
		can_read_tower = true
		_show_hint("按 E 阅读回声塔。", 2.5)

func _on_reading_trigger_exited(body: Node3D) -> void:
	if body == player:
		can_read_tower = false

func _open_reading() -> void:
	phase = GamePhase.READING
	player.set_locked(true)
	player.set_look_locked(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_hide_operation_hint()
	reading_page = 0
	_hide_all_ui()
	_show_reading_page()
	_show_panel_fade(reading_panel, choice_fade_in_duration)

func _show_reading_page() -> void:
	reading_text.text = "\n".join(READING_PAGES[reading_page])
	reading_next_button.text = "完成" if reading_page == READING_PAGES.size() - 1 else "继续"

func _advance_reading() -> void:
	if reading_page < READING_PAGES.size() - 1:
		reading_page += 1
		_show_reading_page()
	else:
		phase = GamePhase.CHOICE
		reading_panel.visible = false
		_show_panel_fade(choice_panel, choice_fade_in_duration)

func _choose_stay() -> void:
	phase = GamePhase.CITY
	choice_panel.visible = false
	player.set_look_locked(false)
	player.set_locked(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_show_hint("你仍在记忆之城。回到塔底可再次阅读。", 3.0)

func _choose_leave() -> void:
	_enter_theme_select()

func _return_to_theme_select() -> void:
	_hide_pause_menu()
	_enter_theme_select()

func _show_pause_menu() -> void:
	previous_phase = phase
	phase = GamePhase.PAUSED
	player.set_locked(true)
	player.set_look_locked(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_hide_operation_hint()
	pause_menu.visible = true

func _hide_pause_menu() -> void:
	pause_menu.visible = false
	phase = previous_phase
	if phase in [GamePhase.GREY_VOID, GamePhase.CITY]:
		player.set_look_locked(false)
		player.set_locked(false)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		player.set_locked(true)
		player.set_look_locked(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _reset_level_state() -> void:
	manifest_started = false
	can_read_tower = false
	manifested_city.visible = false
	_set_city_collision_enabled(false)
	grey_visual_root.visible = true
	grey_silhouettes.visible = true
	grey_particles.amount = 420
	grey_particles.emitting = true
	environment.fog_enabled = true
	environment.fog_density = 0.075
	environment.adjustment_saturation = 0.22
	environment.adjustment_contrast = 0.65
	world_reverb.wet = reverb_wet_max
	world_reverb.room_size = reverb_room_size_max
	player.set_footstep_set("grey")
	direction_tint.color.a = 0.0
	global_music_player.stop()
	global_music_player.volume_db = -12.0
	for i in range(zone_audio_players.size()):
		zone_audio_players[i].stop()
		zone_audio_players[i].volume_db = -8.0 if i == 0 else -25.0

func _update_memory_audio() -> void:
	var distance: float = player.global_position.distance_to(MEMORY_POS)
	var closeness: float = clamp(1.0 - distance / 70.0, 0.0, 1.0)
	memory_lowpass.cutoff_hz = lerp(520.0, 7400.0, closeness)
	memory_zone_player.volume_db = lerp(-24.0, -4.0, closeness)

func _update_dynamic_reverb(delta: float) -> void:
	var distance: float = player.global_position.distance_to(MEMORY_POS)
	var closeness: float = clamp(1.0 - distance / 70.0, 0.0, 1.0)
	var target_wet: float = lerp(reverb_wet_max, reverb_wet_min, closeness)
	var target_room_size: float = lerp(reverb_room_size_max, reverb_room_size_min, closeness)
	var weight: float = 1.0 - exp(-reverb_transition_speed * delta)
	world_reverb.wet = lerp(world_reverb.wet, target_wet, weight)
	world_reverb.room_size = lerp(world_reverb.room_size, target_room_size, weight)

func _update_city_reverb(delta: float) -> void:
	var weight: float = 1.0 - exp(-reverb_transition_speed * delta)
	world_reverb.wet = lerp(world_reverb.wet, city_reverb_wet, weight)
	world_reverb.room_size = lerp(world_reverb.room_size, city_reverb_room_size, weight)

func _update_direction_feedback() -> void:
	var to_memory: Vector3 = (MEMORY_POS - player.global_position).normalized()
	var forward: Vector3 = -player.global_transform.basis.z.normalized()
	var facing: float = clamp((forward.dot(to_memory) + 1.0) * 0.5, 0.0, 1.0)
	var distance: float = player.global_position.distance_to(MEMORY_POS)
	var near: float = clamp(1.0 - distance / 75.0, 0.0, 1.0)
	direction_tint.color.a = lerp(direction_tint.color.a, facing * near * 0.14, 0.08)
	var process_material := grey_particles.process_material as ParticleProcessMaterial
	process_material.initial_velocity_min = lerp(0.15, 0.55, facing)
	process_material.initial_velocity_max = lerp(0.5, 1.6, facing)

func _show_hint(text: String, seconds: float) -> void:
	hint_cache = text
	hint_label.text = text
	if hint_tween != null:
		hint_tween.kill()
	hint_label.modulate.a = 0.0
	hint_tween = create_tween()
	hint_tween.tween_property(hint_label, "modulate:a", 1.0, ui_fade_in_duration)
	hint_tween.tween_interval(max(seconds, ui_hold_duration))
	hint_tween.tween_property(hint_label, "modulate:a", 0.0, ui_fade_out_duration)

func _show_panel_fade(panel: Control, duration: float) -> void:
	panel.visible = true
	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, duration)

func _show_operation_hint() -> void:
	if operation_hint_panel == null:
		return
	if operation_hint_tween != null:
		operation_hint_tween.kill()
	operation_hint_panel.visible = true
	operation_hint_panel.modulate.a = 0.0
	operation_hint_tween = create_tween()
	operation_hint_tween.tween_property(operation_hint_panel, "modulate:a", 1.0, ui_fade_in_duration)
	operation_hint_tween.tween_interval(operation_hint_display_duration)
	operation_hint_tween.tween_property(operation_hint_panel, "modulate:a", 0.0, ui_fade_out_duration)
	operation_hint_tween.tween_callback(func(): operation_hint_panel.visible = false)

func _hide_operation_hint() -> void:
	if operation_hint_tween != null:
		operation_hint_tween.kill()
	if operation_hint_panel != null:
		operation_hint_panel.visible = false
		operation_hint_panel.modulate.a = 0.0

func _hide_all_ui() -> void:
	for c in [main_menu, headphone_prompt, theme_select, reading_panel, choice_panel, pause_menu]:
		if c != null:
			c.visible = false
			c.modulate.a = 1.0

func _set_city_collision_enabled(enabled: bool) -> void:
	for child in city_collision_root.get_children():
		if child is CollisionObject3D:
			child.collision_layer = 1 if enabled else 0
			child.collision_mask = 2 if enabled else 0

func _add_door_frame(parent: Node3D, pos: Vector3, yaw_degrees: float) -> void:
	var frame := Node3D.new()
	frame.name = "WhiteboxDoorFrame"
	frame.position = pos
	frame.rotation_degrees.y = yaw_degrees
	parent.add_child(frame)
	var parts: Array = [
		[Vector3(-1.6, 2.0, 0), Vector3(0.55, 4.0, 0.65)],
		[Vector3(1.6, 2.0, 0), Vector3(0.55, 4.0, 0.65)],
		[Vector3(0, 4.0, 0), Vector3(3.75, 0.55, 0.65)]
	]
	for i in range(parts.size()):
		var box := CSGBox3D.new()
		box.name = "DoorPart_%02d" % i
		box.position = parts[i][0]
		box.size = parts[i][1]
		box.material = _mat(Color(0.56, 0.55, 0.51), 1.0)
		frame.add_child(box)
		var collision_pos: Vector3 = pos + parts[i][0].rotated(Vector3.UP, deg_to_rad(yaw_degrees))
		_add_box_collision("DoorPartCollision", collision_pos, parts[i][1], yaw_degrees)

func _add_arch(parent: Node3D, pos: Vector3, yaw_degrees: float, index: int) -> void:
	var arch := Node3D.new()
	arch.name = "ContinuousArch_%02d" % index
	arch.position = pos
	arch.rotation_degrees.y = yaw_degrees
	parent.add_child(arch)
	for x in [-1.35, 1.35]:
		var pillar := CSGBox3D.new()
		pillar.size = Vector3(0.6, 3.3, 0.7)
		pillar.position = Vector3(x, 1.65, 0)
		pillar.material = _mat(Color(0.53, 0.52, 0.49), 1.0)
		arch.add_child(pillar)
		var pillar_pos := pos + pillar.position.rotated(Vector3.UP, deg_to_rad(yaw_degrees))
		_add_box_collision("ArchPillarCollision_%02d" % index, pillar_pos, pillar.size, yaw_degrees)
	var top := CSGCylinder3D.new()
	top.radius = 1.65
	top.height = 0.65
	top.sides = 24
	top.position = Vector3(0, 3.25, 0)
	top.rotation_degrees.x = 90
	top.material = _mat(Color(0.53, 0.52, 0.49), 1.0)
	arch.add_child(top)
	var top_pos := pos + top.position.rotated(Vector3.UP, deg_to_rad(yaw_degrees))
	_add_box_collision("ArchTopCollision_%02d" % index, top_pos, Vector3(3.8, 0.65, 0.8), yaw_degrees)

func _add_box_collision(name: String, pos: Vector3, size: Vector3, yaw_degrees := 0.0) -> void:
	var body := StaticBody3D.new()
	body.name = name
	body.position = pos
	body.rotation_degrees.y = yaw_degrees
	body.collision_layer = 0
	body.collision_mask = 0
	city_collision_root.add_child(body)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)

func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(300, 44)
	button.pressed.connect(callback)
	return button

func _label(text: String, size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	return label

func _center_panel(name: String) -> VBoxContainer:
	var panel := VBoxContainer.new()
	panel.name = name
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -260
	panel.offset_right = 260
	panel.offset_top = -190
	panel.offset_bottom = 190
	panel.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_theme_constant_override("separation", 14)
	return panel

func _mat(color: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, alpha)
	material.roughness = 0.85
	if alpha < 1.0:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material

func _memory_stream() -> AudioStream:
	if ResourceLoader.exists(AUDIO_PATH):
		var loaded := load(AUDIO_PATH)
		if loaded is AudioStream:
			return loaded
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = 22050
	generator.buffer_length = 0.5
	return generator

func _register_generator(player_node: Node, frequency: float) -> void:
	if player_node.get("stream") is AudioStreamGenerator:
		generator_phases.append(frequency)
	if player_node is AudioStreamPlayer3D:
		zone_audio_players.append(player_node)

func _fill_generated_audio() -> void:
	var all_players: Array = [global_music_player]
	all_players.append_array(zone_audio_players)
	while generator_playbacks.size() < all_players.size():
		generator_playbacks.append(null)
	while generator_phases.size() < all_players.size():
		generator_phases.append(196.0)
	for i in range(all_players.size()):
		var p = all_players[i]
		if p == null or not p.playing or not (p.stream is AudioStreamGenerator):
			continue
		if generator_playbacks[i] == null:
			generator_playbacks[i] = p.get_stream_playback()
		var playback: AudioStreamGeneratorPlayback = generator_playbacks[i]
		if playback == null:
			continue
		var frames := playback.get_frames_available()
		var phase_hz := generator_phases[i]
		for f in range(frames):
			var t := float(Time.get_ticks_msec() % 100000) / 1000.0 + float(f) / 22050.0
			var sample := sin(t * TAU * phase_hz) * 0.05 + sin(t * TAU * phase_hz * 1.5) * 0.025
			playback.push_frame(Vector2(sample, sample))

func _ascii_zone_name(_label_text: String, index: int) -> String:
	var names := ["Memory", "Desire", "Signs", "Thin", "Trading", "Eyes", "Names", "Dead", "Sky", "Continuous", "Hidden"]
	return names[index]
