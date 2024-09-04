extends Node

@export_category("Instances")
@export var PlayerController: CharacterBody3D;
@export var NeckPivot: Node3D;

@export_category("Sensitivity configurations")
@export var currentSensivity: float = 0.1;
@export var currentControllerSensivity: float = 0.05;

@export_category("Clamp value")
@export var minValue: float = deg_to_rad(-60);
@export var maxValue: float = deg_to_rad(80);

var cur_controller_look: Vector2 = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _input(event) -> void:
	if event is InputEventMouseMotion:
		PlayerController.rotate_y(deg_to_rad(-event.relative.x * currentSensivity));
		NeckPivot.rotate_x(deg_to_rad(-event.relative.y * currentSensivity));
		NeckPivot.rotation.x = clamp(NeckPivot.rotation.x, minValue, maxValue);
		

func _handle_controller_input(delta) -> void:
	var target_lock = Input.get_vector("look_left", "look_right", "look_down", "look_right").normalized();
	if target_lock.length() < cur_controller_look.length():
		cur_controller_look = target_lock;
	else:
		cur_controller_look = cur_controller_look.lerp(target_lock, 5.0 * delta)
		
	PlayerController.rotate_y(-cur_controller_look.x * currentControllerSensivity);
	NeckPivot.rotate_x(-cur_controller_look.y * currentControllerSensivity);
	NeckPivot.rotation.x = clamp(NeckPivot.rotation.x, minValue, maxValue);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_controller_input(delta);
