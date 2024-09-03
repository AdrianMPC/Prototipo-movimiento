extends Node

@export var WorldModel: Node3D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1,false);
		child.set_layer_mask_value(2,true);
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
