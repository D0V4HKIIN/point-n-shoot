extends CharacterBody3D


@export var SPEED = 1.5
@export var WALK_SPEED = 0.7
@export var JUMP_VELOCITY = 4.5
@export_range(0.0, 0.01) var mouse_sensitivity := 0.0025

var camera_input_direction := Vector2.ZERO

@onready var camera: Camera3D = $Camera3D
@onready var camera_model = $Camera
@onready var physical_camera = $Camera3D/PhysicalCamera3D
@onready var hud = %HUD
@onready var soundplayer = $AudioStreamPlayer3D


var photoMode = false
var current_aperture = 2
var apertures = [4.5, 4.5, 5.6, 5.6, 6.7, 6.7, 8, 8, 9.5, 9.5, 11, 11, 13, 13, 16, 16, 22, 22, 32]

signal focus_changed
signal focal_length_changed
signal aperture_changed
signal shutter_speed_changed
signal iso_changed


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if photoMode:
			hud.visible = false
			soundplayer.play(2.1)
			await get_tree().process_frame
			await get_tree().process_frame
			var i = 0
			var filename = "./photos/photo" + str(i) + ".png"
			while FileAccess.file_exists(filename):
				i += 1
				filename = "./photos/photo" + str(i) + ".png"
			physical_camera.get_viewport().get_texture().get_image().save_png(filename)
			hud.visible = true


func _unhandled_input(event: InputEvent) -> void:
	var player_is_using_mouse := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if player_is_using_mouse:
		var fov = camera.fov
		if photoMode:
			fov = physical_camera.fov
		camera_input_direction.x = -event.relative.x * mouse_sensitivity * fov
		camera_input_direction.y = -event.relative.y * mouse_sensitivity * fov
	
	if event.is_action("zoom_in"):
		if Input.is_action_pressed("focus"):
			physical_camera.attributes.frustum_focus_distance += 0.05
			focus_changed.emit()
		elif Input.is_action_pressed("iso"):
			physical_camera.attributes.exposure_sensitivity *= sqrt(2)
			iso_changed.emit()
		elif Input.is_action_pressed("shutter_speed"):
			physical_camera.attributes.exposure_shutter_speed *= sqrt(2)
			shutter_speed_changed.emit()
		elif Input.is_action_pressed("aperture"):
			if current_aperture < len(apertures) - 1:
				current_aperture += 1
				physical_camera.attributes.exposure_aperture = apertures[current_aperture]
				aperture_changed.emit()
		else:
			if physical_camera.attributes.frustum_focal_length < 200:
				physical_camera.attributes.frustum_focal_length += 1
			else:
				physical_camera.attributes.frustum_focal_length += 10
			focal_length_changed.emit()
	
	if event.is_action("zoom_out"):
		if Input.is_action_pressed("focus"):
			physical_camera.attributes.frustum_focus_distance -= 0.05
			focus_changed.emit()
		elif Input.is_action_pressed("iso"):
			physical_camera.attributes.exposure_sensitivity /= sqrt(2)
			iso_changed.emit()
		elif Input.is_action_pressed("shutter_speed"):
			physical_camera.attributes.exposure_shutter_speed /= sqrt(2)
			shutter_speed_changed.emit()
		elif Input.is_action_pressed("aperture"):
			if current_aperture > 0:
				current_aperture -= 1
				physical_camera.attributes.exposure_aperture = apertures[current_aperture]
				aperture_changed.emit()
		else:
			if physical_camera.attributes.frustum_focal_length < 200:
				physical_camera.attributes.frustum_focal_length -= 1
			else:
				physical_camera.attributes.frustum_focal_length -= 10
			focal_length_changed.emit()

func set_new_camera():
	physical_camera.make_current()
	camera_model.visible = false


func set_old_camera():
	camera.make_current()
	camera_model.visible = true

func _physics_process(delta: float) -> void:
	camera.rotation.x += camera_input_direction.y * delta
	camera.rotation.y += camera_input_direction.x * delta
	camera_model.rotation.y += camera_input_direction.x * delta
	var np = camera.position - camera.global_basis.z / 4 - camera.global_basis.y / 10
	camera_model.position.x = np.x
	camera_model.position.z = np.z
	
	if Input.is_action_just_pressed("duck"):
		$CollisionShape3D.scale.y *= 0.35
	
	if Input.is_action_just_released("duck"):
		$CollisionShape3D.scale.y = 1.0
		
	
	
	if Input.is_action_just_pressed("camera"):
		photoMode = !photoMode
		hud.visible = !hud.visible
		#camera_model.rotation.x = PI/2
		#camera_model.position.y = -0.41
		if photoMode:
			var p = camera.position - camera.global_basis.z / 4 - camera.global_basis.y / 10
			var tween = get_tree().create_tween()
			
			tween.tween_property(camera_model, "position", p, 0.4)
			tween.parallel().tween_property(camera_model, "rotation:x", -camera.rotation.x, 0.4)
			tween.tween_callback(set_new_camera)
		else:
			set_old_camera()
			var tween = get_tree().create_tween()
			tween.tween_property(camera_model, "position:y", -0.41, 0.4)
			tween.parallel().tween_property(camera_model, "rotation:x", PI/2, 0.4)
			

	camera_input_direction = Vector2.ZERO
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var forward := camera.global_basis.z
	var right := camera.global_basis.x
	var move_direction := forward * direction.z + right * direction.x
	if direction:
		var speed = SPEED
		if Input.is_action_pressed("walk"):
			speed = WALK_SPEED
		velocity.x = move_direction.x * speed
		velocity.z = move_direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
