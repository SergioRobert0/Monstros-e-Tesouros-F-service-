extends RefCounted

var history: Array[Dictionary] = []
var listeners: Array[Callable] = []

func subscribe(listener: Callable) -> void:
	if not listeners.has(listener):
		listeners.append(listener)

func publish(event: Dictionary) -> void:
	var confirmed := event.duplicate(true)
	history.append(confirmed)
	for listener in listeners:
		if listener.is_valid():
			listener.call(confirmed)
