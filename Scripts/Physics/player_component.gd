extends CharacterBody3D
# TODO -> Rehacer todo este codigo para que soporte acelaracion y desacelaracion (X)
# TODO -> Anadir soporte para agacharse (X)
# TODO -> Anadir eventos para trackear sonidos de pasos (X)

enum waterType {
	STANDARD,
	SNOW,
	DEEP_SNOW
}


	
var pc_waterType : waterType = waterType.STANDARD;
var pc_waterLevel : int = 0;

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01

var r1 = deg_to_rad(-50)
var r2 = deg_to_rad(60)

@export var NECK_PIVOT : Node3D
@export var CAMERA : Camera3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event): 
	if event is not InputEventMouseMotion:
		return
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		NECK_PIVOT.rotate_y(-event.relative.x * SENSITIVITY)
		CAMERA.rotate_x(-event.relative.y * SENSITIVITY)
		CAMERA.rotation.x = clamp(CAMERA.rotation.x, r1, r2)
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backwards")
	var direction := (NECK_PIVOT.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
