extends Node3D
class_name CPlayerMovement
const AUTO_BHOP: bool = false;

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");

@export_category("Controller instances")
@export var Controller_Instance: CharacterBody3D;
@export var HeadBobEffectNode: CHeadBobEffect;

@export var jump_velocity: float = 4.0;
@export var walk_speed: float = 7.0;
@export var sprint_speed: float = 8.5;

@export_category("Air")
@export var air_cap: float = 0.85;
@export var air_acceñ = 800.0;
@export var air_move_speed = 500.0;

var wish_dir: Vector3 = Vector3.ZERO;

var headbob_time: float = 0.0;

func _main_movement_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backwards").normalized();
	wish_dir = Controller_Instance.global_transform.basis * Vector3(input_dir.x ,0, input_dir.y);
	
	if Controller_Instance.is_on_floor():
		if Input.is_action_just_pressed("jump") or (AUTO_BHOP and Input.is_action_pressed("jump")):
			Controller_Instance.velocity.y = jump_velocity;
		_handle_ground_physics(delta);
	else:
		_handle_air_physics(delta);
		
	
func _send_bob_effect(delta) -> void:
	headbob_time += delta * Controller_Instance.velocity.length();
	HeadBobEffectNode.headbobProcess(headbob_time);
	
# TODO - Give control on air
func _handle_air_physics(delta) -> void:
	Controller_Instance.velocity.y -= gravity * delta;

func _handle_ground_physics(delta) -> void:
	Controller_Instance.velocity.x = wish_dir.x * _get_move_speed();
	Controller_Instance.velocity.z = wish_dir.z * _get_move_speed();
	#_send_bob_effect(delta);
	
func _handle_water_physics(delta) -> void:
	pass
	
func _get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
