extends CharacterBody3D

@export var _MovementManager: CPlayerMovement;

func _physics_process(delta: float) -> void:
	_MovementManager._main_movement_process(delta);
	move_and_slide();
	
