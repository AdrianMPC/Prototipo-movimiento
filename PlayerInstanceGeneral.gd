extends CharacterBody3D

@export var MovementManager: CPlayerMovement;
@export var WorldModel: Node3D;

func _ready() -> void:
	for child in WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

func _physics_process(delta: float) -> void:
	MovementManager._main_movement_process(delta);

func _process(_delta: float) -> void:
	if MovementManager.get_usable_component_at_shapecast():
		if Input.is_action_just_pressed("use"):
			MovementManager.get_usable_component_at_shapecast().used_with(self);
