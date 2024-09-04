extends Node
class_name CHeadBobEffect
@export var HeadPivot: Node3D;
@export var Camera: Camera3D;

const HEADBOB_FRECUENCY: float = 0.06
const HEADBOB_MOVE_AMOUNT: float = 2.4

var headbob_time := 0.0

func headbobProcess(headbob_time: float) -> void:
	Camera.transform.origin = Vector3 (
		cos(headbob_time * HEADBOB_FRECUENCY * 0.5) * HEADBOB_MOVE_AMOUNT,
		sin(headbob_time * HEADBOB_FRECUENCY) * HEADBOB_MOVE_AMOUNT,
		0
	)
