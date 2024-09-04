extends Node3D
class_name CPlayerMovement
const AUTO_BHOP: bool = false;

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");

@export_category("Controller instances")
@export var Controller_Instance: CharacterBody3D;
@export var HeadBobEffectNode: CHeadBobEffect;

@export_category("Speed related")
@export var jump_velocity: float = 4.0;
@export var walk_speed: float = 7.0;
@export var sprint_speed: float = 8.5;
@export var ground_accel: float = 14.0
@export var ground_decel: float = 10.0;
@export var ground_friction: float = 6.0;

@export_category("Air")
@export var air_cap: float = 0.85;
@export var air_accel = 800.0;
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
	
func _handle_air_physics(delta) -> void:
	Controller_Instance.velocity.y -= gravity * delta;

	# product dot como en quake
	var current_speed_wishdir = Controller_Instance.velocity.dot(wish_dir);
	var capped_speed = min((air_move_speed*wish_dir).length(), air_cap);
	
	var add_speed_till_cap = capped_speed - current_speed_wishdir;
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta;
		accel_speed = min(accel_speed, add_speed_till_cap);
		Controller_Instance.velocity += accel_speed * wish_dir;
		

func _handle_ground_physics(delta) -> void:
	var cur_speed_in_wish_dir = Controller_Instance.velocity.dot(wish_dir);
	var add_speed_till_cap = _get_move_speed() - cur_speed_in_wish_dir;
	if add_speed_till_cap > 0:
		var accel_speed = ground_accel * delta * _get_move_speed();
		accel_speed = min(accel_speed, add_speed_till_cap);
		Controller_Instance.velocity += accel_speed * wish_dir;
	
	# friction
	var curr_length = Controller_Instance.velocity.length();
	var control = max(curr_length, ground_decel);
	var drop = control * ground_friction * delta;
	var new_speed = max(curr_length - drop, 0.0);
	
	if curr_length > 0:
		new_speed /= curr_length
	Controller_Instance.velocity *= new_speed;
	#_send_bob_effect(delta);
	
func _handle_water_physics(delta) -> void:
	pass
	
func _get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
