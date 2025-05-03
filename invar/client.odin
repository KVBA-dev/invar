package invar

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

WINDOW_WIDTH :: 1024
WINDOW_HEIGHT :: 768

bg := rl.WHITE

main_client :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "game-test-git")
	defer rl.CloseWindow()
	btn_test := init_button("testin", rl.Rectangle{0, 200, 300, 50})
	chk_test := init_checkbox("testin again", rl.Rectangle{0, 260, 300, 50})
	chk_test.rendData.fgPalette = PAL_FG_ALT
	chk_test.rendData.currentFg = PAL_FG_ALT.default
	sld_test := init_slider(0, 1, rl.Rectangle{0, 320, 300, 50})
	sld_test.enabled = false
	sld_test2 := init_slider(0, 1, rl.Rectangle{0, 380, 300, 50})
	sld_test3 := init_slider(0, 1, rl.Rectangle{0, 440, 300, 50})
	slider_val(&sld_test2, .2)
	slider_val(&sld_test3, .6)
	rl.SetTargetFPS(60)


	for !rl.WindowShouldClose() {
		update_time()
		update_input()

		slider_val(&sld_test, cast(f32)math.sin(Time.time) * .5 + .5)
		rl.BeginDrawing()
		{
			rl.ClearBackground(bg)
			rl.DrawText("Hello, world!", 20, 20, 20, rl.RED)
			if Button(&btn_test) {
				bg = rl.ColorFromHSV(cast(f32)Time.time * 90, .5, 1)
			}

			if Checkbox(&chk_test) {}

			Slider(&sld_test)
			Slider(&sld_test2)
			Slider(&sld_test3)
		}
		rl.EndDrawing()
	}
}
