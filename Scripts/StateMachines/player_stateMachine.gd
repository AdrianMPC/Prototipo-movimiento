extends Node
class_name Player_State

enum playerState {
	WALKING,
	CROUCHING,
	JUMPING,
	SPRINTING,
	SWIMMING
}


var _ps_playerState: playerState = playerState.WALKING;

func ps_getPlayerState():
	return _ps_playerState
	
func ps_setPlayerState(_playerState: playerState):
	_ps_playerState = _playerState;
