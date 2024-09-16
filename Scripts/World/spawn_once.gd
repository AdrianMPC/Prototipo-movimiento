extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_DISABLED;
	self.hide();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _enable_cube() -> void:
	self.process_mode = Node.PROCESS_MODE_INHERIT;
	self.show();


func _on_c_usable_component_used() -> void:
	print("Used by them");
	_enable_cube();
