extends Node
class_name UPGFSM

signal state_entered(entered_state: UPGState)
signal state_exited(exited_state: UPGState)

@export var start_node: UPGState

var current_state: UPGState:
	get:
		return current_state
	set(value):
		
		if current_state == value:
			return
		
		if value and not is_ancestor_of(value):
			push_warning(get_path(), " cannot enter ", value.get_path(), " because it is not an ancestor of ", name)
			return
		
		if current_state:
			## Enable this statement if you want to see when this machine is leaving its current state
			# print(get_path(), " is exiting ", current_state.name)
			current_state.exit()
			state_exited.emit(current_state)
		
		current_state = value
		
		if current_state:
			## Enable this statement if you want to see when this machine is entering a new state
			print(get_path(), " entering ", current_state.name)
			current_state.enter()
			state_entered.emit(current_state)

func _ready() -> void:
	
	await get_tree().create_timer(0.1).timeout
	
	if not start_node:
		push_warning(get_path(), " has no start node!")
		return

	current_state = start_node

func _process(delta: float) -> void:
	if current_state:
		current_state.tick(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_tick(delta)

func _exit_tree() -> void:
	if current_state:
		current_state.exit()

func switch_to(state: UPGState) -> void:
	current_state = state
