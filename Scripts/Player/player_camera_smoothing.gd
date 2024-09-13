extends Node
class_name CPlayerCameraSmoothing;
@export_category("Camera instance")
@export var SmoothCamera: Node3D;
@export var ControllerInstance: CharacterBody3D;
var _saved_camera_global_pos = null;

func _save_camera_pos_for_smoothing()-> void:
	if _saved_camera_global_pos == null:
		_saved_camera_global_pos = SmoothCamera.global_position;

func _slide_camera_smooth_back_to_origin(delta: float, walk_speed: float):
	var fixed = 0.7;
	if _saved_camera_global_pos == null:
		return
	SmoothCamera.global_position.y = _saved_camera_global_pos.y
	SmoothCamera.position.y = clampf(SmoothCamera.position.y, -fixed, fixed) # Clamp incase teleported
	var move_amount = max(ControllerInstance.velocity.length() * delta, walk_speed/2 * delta)
	SmoothCamera.position.y = move_toward(SmoothCamera.position.y, 0.0, move_amount)
	_saved_camera_global_pos = SmoothCamera.global_position
	if SmoothCamera.position.y == 0:
		_saved_camera_global_pos = null # Stop smoothing camera
