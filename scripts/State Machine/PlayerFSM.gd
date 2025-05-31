extends UPGFSM
class_name PlayerFSM

func get_player() -> Player:
	return get_parent() as Player
