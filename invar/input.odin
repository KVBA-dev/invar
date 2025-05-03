package invar

import rl "vendor:raylib"

MouseButton :: enum {
	Left,
	Right,
	Middle,
}

ActionTrigger :: enum {
	Press,
	Hold,
	Release,
}

InputAction :: struct {
	func:    proc(key: rl.KeyboardKey, data: rawptr),
	data:    rawptr,
	trigger: ActionTrigger,
}

_Input :: struct {
	actions:       map[rl.KeyboardKey]InputAction,
	mouse:         [MouseButton]KeyState,
	keyboard:      map[rl.KeyboardKey]KeyState,
	mousePosition: [2]f32,
}

KeyState :: struct {
	pressed:  bool,
	held:     bool,
	released: bool,
}

Input := _Input {
	actions  = make(map[rl.KeyboardKey]InputAction),
	keyboard = make(map[rl.KeyboardKey]KeyState),
}

register_input_key :: proc(key: rl.KeyboardKey) {
	Input.keyboard[key] = KeyState{}
}

rebind_key :: proc(from, to: rl.KeyboardKey) -> ^KeyState {
	if elem, ok := Input.keyboard[from]; ok {
		delete_key(&Input.keyboard, from)
		Input.keyboard[to] = elem
		return &Input.keyboard[to]
	}
	return nil
}

get_key_state :: proc(key: rl.KeyboardKey) -> ^KeyState {
	return &Input.keyboard[key]
}

bind_action :: proc(
	key: rl.KeyboardKey,
	cbk: proc(key: rl.KeyboardKey, data: rawptr),
	data: rawptr,
	trigger: ActionTrigger = .Press,
) {
	Input.actions[key] = {cbk, data, trigger}
}

rebind_action :: proc(from, to: rl.KeyboardKey) {
	action, ok := Input.actions[from]
	if !ok do return
	delete_key(&Input.actions, from)
	Input.actions[to] = action
}

remove_action :: proc(key: rl.KeyboardKey) {
	if _, ok := Input.actions[key]; !ok do return
	delete_key(&Input.actions, key)
}

update_input :: proc() {
	get_rl_button :: proc(b: MouseButton) -> (rb: rl.MouseButton) {
		switch b {
		case .Left:
			rb = .LEFT
		case .Right:
			rb = .RIGHT
		case .Middle:
			rb = .MIDDLE
		}
		return rb
	}
	Input.mousePosition = rl.GetMousePosition()
	for but, _ in MouseButton {
		rlbut := get_rl_button(but)
		Input.mouse[but].pressed = rl.IsMouseButtonPressed(rlbut)
		Input.mouse[but].held = rl.IsMouseButtonDown(rlbut)
		Input.mouse[but].released = rl.IsMouseButtonReleased(rlbut)
	}

	for key, &state in Input.keyboard {
		state.held = rl.IsKeyDown(key)
		state.pressed = rl.IsKeyPressed(key)
		state.released = rl.IsKeyReleased(key)
	}

	for key, &action in Input.actions {
		switch (action.trigger) {
		case .Hold:
			if rl.IsKeyDown(key) do action.func(key, action.data)
		case .Press:
			if rl.IsKeyPressed(key) do action.func(key, action.data)
		case .Release:
			if rl.IsKeyReleased(key) do action.func(key, action.data)
		case:
		}
	}
}
