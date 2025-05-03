package invar

import "core:fmt"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1024
WINDOW_HEIGHT :: 768

bg := rl.WHITE

main_client :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "invar")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		update_time()
		update_input()
		SceneManager.current.update(SceneManager.current.data)
	}

	SceneManager.current.cleanup(SceneManager.current.data)
}
