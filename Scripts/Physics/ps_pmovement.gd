extends Node

@export var chr_controller: CharacterBody3D;
@export var p_stateMachine: Player_State;

# PARAMETROS DE MOVIMIENTO
@export var pm_stopSpeed : float = 100.0;
@export var pm_duckScale : float = 0.25;
@export var pm_swimScale : float = 0.50;
@export var pm_wadeScale : float = 0.70;

@export var pm_accelarate : float = 10.0;
@export var pm_airAccelerate : float = 1.0;
@export var pm_waterAccelerate : float = 4.0;
@export var pm_flyAccelerate : float = 8.0;

@export var pm_friction : float = 6.0;
@export var pm_waterFriction : float = 1.0;
@export var pm_flightFriction : float = 4.0;
#@export var pm_spectatorFriction : float = 5.0;
#var dg_pMove: int = 0;


"""
pm_accelarationHandler retorna void
-------------------------------------
maneja acelaracion inicializada por el jugador
"""

func pm_accelarationHandler(wishDirection: Vector3 , wishSpeed: float, acceleration: float, delta) -> void:
	var addSpeed: float;
	var accelSpeed: float;
	var currentSpeed: float;
	
	currentSpeed = chr_controller.velocity.length();
	addSpeed = wishSpeed - currentSpeed;
	
	if(addSpeed <= 0.0):
		return;
		
	accelSpeed = acceleration * delta * wishSpeed;
	
	if( accelSpeed > addSpeed ):
		accelSpeed = addSpeed;
	
	chr_controller.velocity.x += accelSpeed * wishDirection.x;
	chr_controller.velocity.y += accelSpeed * wishDirection.y;
	chr_controller.velocity.z += accelSpeed * wishDirection.z;
	
"""
pm_frictionHandler retorna void
-------------------------------------
maneja la friction tanto en tierra como agua
"""

func pm_frictionHandler(delta) -> void:
	#var velCopy: Vector3;
	var vel: Vector3;
	var speed: float;
	var newSpeed: float;
	var control: float;
	var drop: float;
	
	vel = chr_controller.velocity;
	
	if p_stateMachine.ps_getPlayerState() & p_stateMachine.playerState.WALKING:
		vel.z = 0;
	
	speed = vel.length();
	if speed < 1.0:
		vel.x = 0;
		vel.y = 0;
		return
	
	drop = 0;
	if !(p_stateMachine.ps_getPlayerState() & p_stateMachine.playerState.SWIMMING):
		if(p_stateMachine.ps_getPlayerState() & p_stateMachine.playerState.WALKING):
			control = pm_stopSpeed if speed < pm_stopSpeed else speed;
	
	if (p_stateMachine.ps_getPlayerState() & p_stateMachine.playerState.SWIMMING):
		drop += speed * pm_waterFriction * delta
	
	newSpeed = speed - drop;
	
	if newSpeed < 0:
		newSpeed = 0;
	
	newSpeed /= speed;
	
	chr_controller.velocity = vel * newSpeed;








# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
