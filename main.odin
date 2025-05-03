/*
  Invar - a game framework for Odin
  This is a sample project, meant to showcase what you can do with Invar
*/

package main

import "core:math"
import iv "invar"
import rl "vendor:raylib" // Invar is based on raylib, so you're gonna need it

WINDOW_WIDTH :: 1024
WINDOW_HEIGHT :: 768

main :: proc() {
	// Initialise
	iv.init(WINDOW_WIDTH, WINDOW_HEIGHT)

	// Set initial scene
	// Every scene needs a pointer to data and 3 procedures: init, update and cleanup
	// Remember to free the data in cleanup!
	iv.set_scene({new(GameCtx), game_init, game_update, game_cleanup})

	// Run the game!
	iv.run()
}

GameCtx :: struct {
	btn_test:                       iv.ButtonData,
	chk_test:                       iv.CheckboxData,
	sld_test, sld_test2, sld_test3: iv.SliderData,
	bg:                             rl.Color,
}

game_init :: proc(data: rawptr) {
	using data := cast(^GameCtx)data
	btn_test = iv.init_button("testin", rl.Rectangle{0, 200, 300, 50})
	chk_test = iv.init_checkbox("testin again", rl.Rectangle{0, 260, 300, 50})
	chk_test.rendData.fgPalette = iv.PAL_FG_ALT
	chk_test.rendData.currentFg = iv.PAL_FG_ALT.default
	sld_test = iv.init_slider(0, 1, rl.Rectangle{0, 320, 300, 50})
	sld_test.enabled = false
	sld_test2 = iv.init_slider(0, 1, rl.Rectangle{0, 380, 300, 50})
	sld_test3 = iv.init_slider(0, 1, rl.Rectangle{0, 440, 300, 50})
	iv.slider_val(&sld_test2, .2)
	iv.slider_val(&sld_test3, .6)

	bg = rl.WHITE
}

game_update :: proc(data: rawptr) {
	using data := cast(^GameCtx)data

	iv.slider_val(&sld_test, cast(f32)math.sin(iv.Time.time) * .5 + .5)
	rl.BeginDrawing()
	{
		rl.ClearBackground(bg)
		rl.DrawText("Hello, world!", 20, 20, 20, rl.RED)
		if iv.Button(&btn_test) {
			bg = rl.ColorFromHSV(cast(f32)iv.Time.time * 90, .5, 1)
			iv.set_scene({new(Game2Ctx), game2_init, game2_update, game2_cleanup})
		}

		if iv.Checkbox(&chk_test) {}

		iv.Slider(&sld_test)
		iv.Slider(&sld_test2)
		iv.Slider(&sld_test3)
	}
	rl.EndDrawing()
}

game_cleanup :: proc(data: rawptr) {
	data := cast(^GameCtx)data

	free(data)

}

Game2Ctx :: struct {
	bg: rl.Color,
}

game2_init :: proc(data: rawptr) {
	using data := cast(^Game2Ctx)data
	bg = rl.RED

	iv.
}

game2_update :: proc(data: rawptr) {
	using data := cast(^Game2Ctx)data

	rl.BeginDrawing()
	{
		rl.ClearBackground(bg)


	}
	rl.EndDrawing()
}

game2_cleanup :: proc(data: rawptr) {
	using data := cast(^Game2Ctx)data

	free(data)
}
