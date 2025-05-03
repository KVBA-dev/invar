package invar

import "core:fmt"
import rl "vendor:raylib"

main_client :: proc() {
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		update_time()
		update_input()
		SceneManager.current.update(SceneManager.current.data)
	}

	SceneManager.current.cleanup(SceneManager.current.data)
	delete_scene_manager()
	delete_input()
}
