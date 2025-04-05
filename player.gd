extends CharacterBody3D


@export var SPEED = 3.0
@export var WALK_SPEED = 1.0
@export var JUMP_VELOCITY = 4.5
@export_range(0.0, 0.01) var mouse_sensitivity := 0.0025

var camera_input_direction := Vector2.ZERO

@onready var camera: Camera3D = $Camera3D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	var player_is_using_mouse := (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if player_is_using_mouse:
		camera_input_direction.x = -event.relative.x * mouse_sensitivity * camera.fov
		camera_input_direction.y = -event.relative.y * mouse_sensitivity * camera.fov
	
	if event.is_action("zoom_in"):
		camera.fov -= 1
	
	if event.is_action("zoom_out"):
		camera.fov += 1

func _physics_process(delta: float) -> void:
	camera.rotation.x += camera_input_direction.y * delta
	camera.rotation.y += camera_input_direction.x * delta

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
