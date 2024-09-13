extends Node3D
class_name CPlayerMovement

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity");

@export_category("MOVEMENT OPTIONS")
@export var SURF: bool = true;
@export var NOCLIP: bool = false;
@export var AUTO_BHOP: bool = false;

@export_category("Controller instances")
@export var Controller_Instance: CharacterBody3D;
@export var NeckPivot: Node3D;
@export var HeadBobEffectNode: CHeadBobEffect;
@export var PlayerCollision: CollisionShape3D;

@export_category("Speed related")
@export var jump_velocity: float = 4.0;
@export var walk_speed: float = 7.0;
@export var sprint_speed: float = 8.5;
@export var ground_accel: float = 14.0
@export var ground_decel: float = 10.0;
@export var ground_friction: float = 6.0;

@export_category("Air")
@export var air_cap: float = 1;
@export var air_accel = 800.0;
@export var air_move_speed = 500.0;
@export var noclip_move_speed_mult = 3.0;

@export_category("Stairs Control")
@export var StairsBelowRayCast3D: RayCast3D;
@export var StairsAheadRayCast3D: RayCast3D;
@export var MAX_STEP_HEIGHT: float = 0.5;

@export_category("Camera related")
@export var CameraSmoothingModule: CPlayerCameraSmoothing;

var _snapped_to_stairs_last_frame: bool = false;
var _last_frame_was_onfloor: float = -INF;

var wish_dir: Vector3 = Vector3.ZERO;
var cam_aligned_wish_dir = Vector3.ZERO;


var headbob_time: float = 0.0;

func _main_movement_process(delta: float) -> void:
	if Controller_Instance.is_on_floor(): 
		_last_frame_was_onfloor = Engine.get_physics_frames()
	var input_dir = Input.get_vector("left", "right", "forward", "backwards").normalized();
	wish_dir = Controller_Instance.global_transform.basis * Vector3(input_dir.x ,0, input_dir.y);
	cam_aligned_wish_dir = NeckPivot.global_transform.basis * Vector3(input_dir.x ,0, input_dir.y);

	if not handle_noclip(delta):
		if Controller_Instance.is_on_floor() or _snapped_to_stairs_last_frame:
			if Input.is_action_just_pressed("jump") or (AUTO_BHOP and Input.is_action_pressed("jump")):
				Controller_Instance.velocity.y = jump_velocity;
			_handle_ground_physics(delta);
		else:
			_handle_air_physics(delta);
			
		if not _snap_up_to_stairs_check(delta):
			Controller_Instance.move_and_slide()
			_snap_down_to_stairs_check()
		
	CameraSmoothingModule._slide_camera_smooth_back_to_origin(delta, walk_speed);

func _send_bob_effect(delta) -> void:
	headbob_time += delta * Controller_Instance.velocity.length();
	HeadBobEffectNode.headbobProcess(headbob_time);
	
func _handle_air_physics(delta) -> void:
	Controller_Instance.velocity.y -= gravity * delta
	var cur_speed_in_wish_dir = Controller_Instance.velocity.dot(wish_dir)
	var capped_speed = min((air_move_speed * wish_dir).length(), air_cap)
	var add_speed_till_cap = capped_speed - cur_speed_in_wish_dir
	if add_speed_till_cap > 0:
		var accel_speed = air_accel * air_move_speed * delta 
		accel_speed = min(accel_speed, add_speed_till_cap) 
		Controller_Instance.velocity += accel_speed * wish_dir

	if Controller_Instance.is_on_wall() and SURF:
		if _is_surface_too_steep(Controller_Instance.get_wall_normal()):
			Controller_Instance.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		else:
			Controller_Instance.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
			
		_clip_velocity(Controller_Instance.get_wall_normal(), 1, delta) 

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
	
	if curr_length > 0.0:
		new_speed /= curr_length
	Controller_Instance.velocity *= new_speed;
	#_send_bob_effect(delta);
	
	
# Allow sliding
func _clip_velocity(normal: Vector3, overbounce: float, delta: float):
	var backoff := Controller_Instance.velocity.dot(normal) * overbounce;
	if backoff >= 0:
		return
	
	var change := normal * backoff;
	Controller_Instance.velocity -= change;
	
	var adjust := Controller_Instance.velocity.dot(normal);
	if adjust >= 0.0:
		Controller_Instance.velocity -= normal * adjust;
	
func _handle_water_physics(delta) -> void:
	pass

func _snap_down_to_stairs_check() -> void:
	var did_snap: bool = false;
	StairsBelowRayCast3D.force_raycast_update();
	var floor_below : bool = StairsBelowRayCast3D.is_colliding() and not _is_surface_too_steep(StairsBelowRayCast3D.get_collision_normal());
	var was_on_floor_last_frame = Engine.get_physics_frames() == _last_frame_was_onfloor;
	if not Controller_Instance.is_on_floor() and Controller_Instance.velocity.y <= 0 and (was_on_floor_last_frame or _snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = KinematicCollision3D.new();
		if Controller_Instance.test_move(Controller_Instance.global_transform, Vector3(0,-MAX_STEP_HEIGHT,0), body_test_result):
			CameraSmoothingModule._save_camera_pos_for_smoothing();
			var translate_y = body_test_result.get_travel().y;
			Controller_Instance.position.y += translate_y;
			Controller_Instance.apply_floor_snap();
			did_snap = true;
	_snapped_to_stairs_last_frame = did_snap;

func _snap_up_to_stairs_check(delta: float) -> bool:
	if not Controller_Instance.is_on_floor() and not _snapped_to_stairs_last_frame: 
		return false;
		
	if Controller_Instance.velocity.y > 0 or (Controller_Instance.velocity * Vector3(1,0,1)).length() == 0: 
		return false;
		
	var expected_move_motion = Controller_Instance.velocity * Vector3(1,0,1) * delta;
	var step_pos_with_clearance = Controller_Instance.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0));
	
	var down_check_result = KinematicCollision3D.new();
	if (Controller_Instance.test_move(step_pos_with_clearance, Vector3(0,-MAX_STEP_HEIGHT*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((step_pos_with_clearance.origin + down_check_result.get_travel()) - self.global_position).y;
		if step_height > MAX_STEP_HEIGHT or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > MAX_STEP_HEIGHT: 
			return false;
			
		StairsAheadRayCast3D.global_position = down_check_result.get_position() + Vector3(0,MAX_STEP_HEIGHT,0) + expected_move_motion.normalized() * 0.1;
		StairsAheadRayCast3D.force_raycast_update();
		if StairsAheadRayCast3D.is_colliding() and not _is_surface_too_steep(StairsAheadRayCast3D.get_collision_normal()):
			CameraSmoothingModule._save_camera_pos_for_smoothing();
			Controller_Instance.global_position = step_pos_with_clearance.origin + down_check_result.get_travel();
			Controller_Instance.apply_floor_snap();
			_snapped_to_stairs_last_frame = true;
			return true;
	return false;
	
func handle_noclip(delta) -> bool:
	var _speed = 2.0;
	if Input.is_action_just_pressed("noclip") and OS.has_feature("debug"):
		NOCLIP = !NOCLIP;
		noclip_move_speed_mult = _speed;
	PlayerCollision.disabled = NOCLIP;
	
	if not NOCLIP:
		return false;
	
	var speed = _get_move_speed() * noclip_move_speed_mult;
	if Input.is_action_pressed("sprint"):
		speed *= _speed;
	
	Controller_Instance.velocity = cam_aligned_wish_dir * speed;	#Vector3.ZERO if you dont want the gmod style noclip
	Controller_Instance.global_position += Controller_Instance.velocity * delta;
	return true

func _get_move_speed() -> float:
	return sprint_speed if Input.is_action_pressed("sprint") else walk_speed;
	
func _is_surface_too_steep(normal: Vector3):
		return normal.angle_to(Vector3.UP) > Controller_Instance.floor_max_angle;
