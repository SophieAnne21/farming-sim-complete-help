extends Node
class_name UPGState

signal entered
signal exited

func _ready() -> void:
	
	if not get_fsm():
		queue_free()
		push_warning(name, " initialized without a valid state machine parent! ", get_path())
		return

func enter() -> void:
	# print(get_path(), " entering!")
	entered.emit()

func exit() -> void:
	# print(get_path(), " exiting!")
	exited.emit()

func tick(delta: float) -> void:
	pass

func physics_tick(delta: float) -> void:
	pass

func get_fsm() -> UPGFSM:
	return get_parent() as UPGFSM

func switch_to(new_state: UPGState) -> void:
	if new_state:
		print(get_path(), " is transitioning to ", new_state.get_path())
	else:
		print(get_path(), " is entering a null state! Behavior will cease.")
	if get_fsm():
		get_fsm().switch_to(new_state)

func create_transition(target_state: UPGState) -> Callable:
	return switch_to.bind(target_state)
