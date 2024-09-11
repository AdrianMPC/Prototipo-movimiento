extends CharacterBody3D

@export var _MovementManager: CPlayerMovement;

func _physics_process(delta: float) -> void:
	var _last_frame_was_onfloor = -INF;
	if is_on_floor(): 
		_last_frame_was_onfloor = Engine.get_physics_frames();
		
	_MovementManager._main_movement_process(delta, _last_frame_was_onfloor);
	if not _MovementManager.NOCLIP:
		move_and_slide();
	_MovementManager._snap_down_to_stairs_check();
