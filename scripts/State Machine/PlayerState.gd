extends UPGState
class_name PlayerState

var player: Player:
	get:
		return get_player_fsm().get_player()

func get_player_fsm() -> PlayerFSM:
	return get_fsm() as PlayerFSM
