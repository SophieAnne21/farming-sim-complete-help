extends Node

signal pause_state_changed(is_paused: bool)

var pause_sources := {
	"inventory": false,
	"menu": false,
	"stun": false
}

func set_paused(source: String, value: bool) -> void:
	if not pause_sources.has(source):
		push_error("Pause source '%s' not recognized" % source)
		return

	pause_sources[source] = value
	update_pause_state()

func get_pause_state(source: String) -> bool:
	return pause_sources.get(source, false)

func update_pause_state() -> void:
	var is_any_paused = false
	for val in pause_sources.values():
		if val:
			is_any_paused = true
			break

	get_tree().paused = is_any_paused
	emit_signal("pause_state_changed", is_any_paused)

func is_paused() -> bool:
	return get_tree().paused
