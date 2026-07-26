extends CharacterBody3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var SPRINT_SPEED = 10.0
@export var TURN_RATE = 12

@export var mouse_sensitivity: float = 0.003
@export var camera: Camera3D

@export var Body : Node3D
@export var Collision : Node3D


const min_pitch: float = -89.0 
const max_pitch: float = 89.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)		
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		var camera_rot = camera.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, min_pitch, max_pitch)
		camera.rotation_degrees = camera_rot

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			

func _physics_process(delta: float) -> void:
	# 1. Apply downward gravity if airborne
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Handle Jump input
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Get 2D vector input from keyboard arrow keys / WASD
	var input_dir := Input.get_vector("l-side", "r-side", "front", "back")
	
	# 4. Map the 2D input onto the 3D ground plane (X and Z axes)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var s=SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		if is_on_floor():
			s=SPRINT_SPEED
		
	# 5. Apply velocity smoothly
	if direction:
		var target_angle=(-global_transform.basis.z).signed_angle_to(direction,Vector3.UP)
		Body.rotation.y = rotate_toward(Body.rotation.y, target_angle, TURN_RATE * delta)
		Collision.rotation.y=rotate_toward(Collision.rotation.y,target_angle,TURN_RATE*delta)
		
		velocity.x = direction.x * s
		velocity.z = direction.z * s
	else:
		velocity.x = move_toward(velocity.x, 0, s/8)
		velocity.z = move_toward(velocity.z, 0, s/8)

	
	# 6. Move the body and handle slopes/walls
	move_and_slide()
