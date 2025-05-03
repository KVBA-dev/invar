package invar

import "core:fmt"

Scene :: struct {
	data:    rawptr,
	init:    proc(data: rawptr),
	update:  proc(data: rawptr),
	cleanup: proc(data: rawptr),
}

_SceneManager :: struct {
	backlog:  [dynamic]Scene,
	current:  Scene,
	hasScene: bool,
}

SceneManager := _SceneManager {
	backlog  = make([dynamic]Scene, 0, 16),
	hasScene = false,
}

set_scene :: proc(scene: Scene) {
	if (SceneManager.hasScene) {
		SceneManager.current.cleanup(SceneManager.current.data)
	}
	SceneManager.hasScene = true
	SceneManager.current = scene
	SceneManager.current.init(SceneManager.current.data)
}

push_scene :: proc(scene: Scene) {
	append(&SceneManager.backlog, SceneManager.current)
	SceneManager.current = scene
	SceneManager.current.init(SceneManager.current.data)
}

pop_scene :: proc() -> Scene {
	assert(len(SceneManager.backlog) > 0, "cannot pop from empty scene stack")
	SceneManager.current.cleanup(SceneManager.current.data)
	scene := SceneManager.current
	idx := len(SceneManager.backlog) - 1
	SceneManager.current = SceneManager.backlog[idx]
	unordered_remove(&SceneManager.backlog, idx)
	return scene
}

delete_scene_manager :: proc() {
	if len(SceneManager.backlog) > 0 {
		top_idx := len(SceneManager.backlog) - 1
		for top_idx >= 0 {
			curr := &SceneManager.backlog[top_idx]
			curr.cleanup(curr.data)
			curr.data = nil
			top_idx -= 1
		}
	}
	delete(SceneManager.backlog)
}
