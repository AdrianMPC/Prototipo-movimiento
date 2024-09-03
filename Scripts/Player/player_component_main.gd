extends CharacterBody3D
#@export var movementManager: MovementManager;

func _physics_process(delta: float) -> void:
	# Add the gravity.
	movementManager.pm_moveHandler(delta)
	move_and_slide()
	var debug_speed = velocity.length();
	print(debug_speed);
