extends CharacterBody3D

@export var MovementManager: CPlayerMovement;
@export var WorldModel: Node3D;

func _ready() -> void:
	for child in WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

func _physics_process(delta: float) -> void:
	MovementManager._main_movement_process(delta);
