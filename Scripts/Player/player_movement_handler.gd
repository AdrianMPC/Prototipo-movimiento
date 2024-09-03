extends Node
class_name MovementManager
@export var playerComponent: CharacterBody3D;
@export var NeckPivot: Node3D;

var currentSpeed: float = 5.0;
@export var jumpVelocity: float = 4.0;

@export_category("Speed parameters")
@export var walkSpeed: float = 6.0;
@export var sprintSpeed: float = 8.0;
@export var crouchSpeed: float = 3.0;

@export_category("Lerp parameters")
@export var lerpMovementSpeed: float = 15.0;
@export var lerpSpeedChange: float = 4.0

@export_category("Crouching parameters")
@export var crouchDepth: float = -0.4;
@export var defaultDepth: float = 0.614;

var _direction = Vector3.ZERO;

func pm_moveHandler(delta: float):
	
	_pm_playerStateHandler(delta);
	
	if not playerComponent.is_on_floor():
		playerComponent.velocity += playerComponent.get_gravity() * delta

	# Handle jump.
	if _pm_canJump():
		playerComponent.velocity.y = jumpVelocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backwards")
	var calc := (playerComponent.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	_direction = lerp(_direction, calc, delta * lerpMovementSpeed);
	
	if _direction:
		playerComponent.velocity.x = _direction.x * currentSpeed
		playerComponent.velocity.z = _direction.z * currentSpeed
	else:
		playerComponent.velocity.x = move_toward(playerComponent.velocity.x, 0, currentSpeed)
		playerComponent.velocity.z = move_toward(playerComponent.velocity.z, 0, currentSpeed)
		

func _pm_playerStateHandler(delta: float) -> void:
	var targetSpeed: float;
	if _pm_isCrouch():
		_pm_crouchHandler(true);
		if playerComponent.is_on_floor():
			targetSpeed = crouchSpeed;
	else:
		_pm_crouchHandler(false);
		if _pm_isSprint():
			targetSpeed = sprintSpeed;
		else:
			targetSpeed = walkSpeed;
			
	currentSpeed = lerp(currentSpeed, targetSpeed, delta * lerpSpeedChange)

# TODO - En vez de cambiar la posicion del pivot, mejor cambio el tamaño del collision y snapearlo al terreno en caso estaba en tierra
# Permitiria hacer crouch jump
func _pm_crouchHandler(cur: bool) -> void:
	if cur:
		NeckPivot.position.y = defaultDepth + crouchDepth;
	else:
		NeckPivot.position.y = defaultDepth;

func _pm_canJump() -> bool:
	if Input.is_action_just_pressed("jump") and playerComponent.is_on_floor():
		return true
		
	return false

func _pm_isCrouch() -> bool:
	return	Input.is_action_pressed("crouch");
		
func _pm_isSprint() -> bool:
	return Input.is_action_pressed("sprint");
