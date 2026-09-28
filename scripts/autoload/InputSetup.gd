extends Node
## Autoload que registra as ações de input do jogo em tempo de execução.
## Fazemos isso em código (em vez de editar o InputMap serializado no
## project.godot à mão) porque é mais seguro de revisar e alterar depois.

func _init() -> void:
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("jump", KEY_SPACE)
	_add_key_action("toggle_mouse", KEY_ESCAPE)
	_add_mouse_button_action("attack", MOUSE_BUTTON_LEFT)
	_add_mouse_button_action("power_1", MOUSE_BUTTON_RIGHT)


func _add_key_action(action_name: String, keycode: Key) -> void:
	if InputMap.has_action(action_name):
		return
	InputMap.add_action(action_name)
	var event := InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(action_name, event)


func _add_mouse_button_action(action_name: String, button: MouseButton) -> void:
	if InputMap.has_action(action_name):
		return
	InputMap.add_action(action_name)
	var event := InputEventMouseButton.new()
	event.button_index = button
	InputMap.action_add_event(action_name, event)
