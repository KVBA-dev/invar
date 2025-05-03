package invar

import "core:fmt"
import rl "vendor:raylib"

Palette :: struct {
	default:  rl.Color,
	selected: rl.Color,
	clicked:  rl.Color,
	disabled: rl.Color,
}

RenderingData :: struct {
	font:      rl.Font,
	bgPalette: Palette,
	fgPalette: Palette,
	currentBg: rl.Color,
	currentFg: rl.Color,
	fontSize:  f32,
	smoothing: f32,
	alignment: Alignment,
}

UIElement :: union {
	^ButtonInstance,
	^CheckboxData,
	^SliderData,
}

render_element :: proc(elem: UIElement) {
	switch e in elem {
	case ^ButtonInstance:
		if Button(&e.data) do e.cbk()
	case ^CheckboxData:
		Checkbox(e)
	case ^SliderData:
		Slider(e)
	}
}

ButtonData :: struct {
	rendData: RenderingData,
	rect:     rl.Rectangle,
	caption:  cstring,
	enabled:  bool,
}

ButtonInstance :: struct {
	data: ButtonData,
	cbk:  proc(),
}

CheckboxData :: struct {
	rendData: RenderingData,
	rect:     rl.Rectangle,
	caption:  cstring,
	checked:  bool,
	enabled:  bool,
}

SliderData :: struct {
	rendData: RenderingData,
	rect:     rl.Rectangle,
	min:      f32,
	max:      f32,
	value:    f32,
	enabled:  bool,
	held:     bool,
}

Alignment :: enum u8 {
	Left,
	Center,
	Right,
}

PAL_BG_DEFAULT :: Palette {
	default  = rl.BLUE,
	selected = rl.SKYBLUE,
	clicked  = rl.DARKBLUE,
	disabled = rl.GRAY,
}

PAL_FG_DEFAULT :: Palette {
	default  = rl.WHITE,
	selected = rl.WHITE,
	clicked  = rl.WHITE,
	disabled = rl.LIGHTGRAY,
}

PAL_FG_ALT :: Palette {
	default  = rl.BLACK,
	selected = rl.BLACK,
	clicked  = rl.BLACK,
	disabled = rl.DARKGRAY,
}

REND_DEFAULT := RenderingData {
	font      = rl.GetFontDefault(),
	bgPalette = PAL_BG_DEFAULT,
	fgPalette = PAL_FG_DEFAULT,
	currentBg = PAL_BG_DEFAULT.default,
	currentFg = PAL_FG_DEFAULT.default,
	alignment = .Center,
	fontSize  = 30,
	smoothing = 10,
}

init_button :: proc(caption: cstring, rect: rl.Rectangle) -> ButtonData {
	data := ButtonData {
		rendData = REND_DEFAULT,
		rect     = rect,
		caption  = caption,
		enabled  = true,
	}
	data.rendData.font = rl.GetFontDefault()

	return data
}

init_checkbox :: proc(caption: cstring, rect: rl.Rectangle) -> CheckboxData {
	data := CheckboxData {
		rendData = REND_DEFAULT,
		rect     = rect,
		caption  = caption,
		enabled  = true,
		checked  = false,
	}

	data.rendData.font = rl.GetFontDefault()
	return data
}

init_slider :: proc(min, max: f32, rect: rl.Rectangle) -> SliderData {
	data := SliderData {
		rendData = REND_DEFAULT,
		rect     = rect,
		min      = min,
		max      = max,
		value    = min,
		enabled  = true,
	}
	return data
}

slider_val :: proc {
	get_slider_val,
	set_slider_val,
}

get_slider_val :: proc(data: ^SliderData) -> f32 {
	return data.value
}

set_slider_val :: proc(data: ^SliderData, val: f32) {
	if val > data.max do data.value = data.max
	else if val < data.min do data.value = data.min
	else do data.value = val
}

Slider :: proc(data: ^SliderData) {
	if data.enabled {
		data.held =
			!data.held && Input.mouse[.Left].pressed && MouseOnRect(data.rect) ||
			data.held && Input.mouse[.Left].held
	}
	if data.held {
		relMP := Input.mousePosition - RectPos(data.rect)
		tPos := relMP.x / data.rect.width
		if tPos > 1 do tPos = 1
		else if tPos < 0 do tPos = 0
		data.value = data.min + tPos * (data.max - data.min)
	}

	t := (data.value - data.min) / (data.max - data.min)
	if t < 0 do t = 0
	else if t > 1 do t = 1
	fillRect := RectLerp({data.rect.x, data.rect.y, 0, data.rect.height}, data.rect, t)

	rl.DrawRectangleRec(fillRect, data.rendData.bgPalette.default)
}

Button :: proc(data: ^ButtonData) -> bool {
	mousePos := Input.mousePosition - {data.rect.x, data.rect.y}
	targetBg := data.rendData.bgPalette.default
	targetFg := data.rendData.fgPalette.default
	isHovering :=
		mousePos.x > 0 &&
		mousePos.x < data.rect.width &&
		mousePos.y > 0 &&
		mousePos.y < data.rect.height
	if !data.enabled {
		targetBg = data.rendData.bgPalette.disabled
		targetFg = data.rendData.fgPalette.disabled
	} else if isHovering {
		if Input.mouse[.Left].held {
			targetFg = data.rendData.fgPalette.clicked
			targetBg = data.rendData.bgPalette.clicked
		} else {
			targetFg = data.rendData.fgPalette.selected
			targetBg = data.rendData.bgPalette.selected
		}
	}

	data.rendData.currentFg = rl.ColorLerp(
		data.rendData.currentFg,
		targetFg,
		data.rendData.smoothing * Time.deltaTime,
	)
	data.rendData.currentBg = rl.ColorLerp(
		data.rendData.currentBg,
		targetBg,
		data.rendData.smoothing * Time.deltaTime,
	)

	rl.DrawRectangleRec(data.rect, data.rendData.currentBg)

	xPos: f32
	textWidth := rl.MeasureTextEx(data.rendData.font, data.caption, data.rendData.fontSize, 0).x
	switch data.rendData.alignment {
	case .Left:
		xPos = 5
	case .Right:
		xPos = data.rect.width - 5 - textWidth
	case .Center:
		xPos = (data.rect.width - textWidth) / 2
	}

	rl.DrawTextEx(
		data.rendData.font,
		data.caption,
		{data.rect.x + xPos, data.rect.y + (data.rect.height - data.rendData.fontSize) / 2},
		data.rendData.fontSize,
		0,
		data.rendData.currentFg,
	)

	return data.enabled && (isHovering && Input.mouse[.Left].pressed)
}

Checkbox :: proc(data: ^CheckboxData) -> bool {
	textSize := rl.MeasureTextEx(data.rendData.font, data.caption, data.rendData.fontSize, 0)

	rect := data.rect
	rect.x = rect.width - rect.height
	rect.width = rect.height

	mousePos := Input.mousePosition - {rect.x, rect.y}
	if mousePos.x > 0 && mousePos.x < rect.width && mousePos.y > 0 && mousePos.y < rect.height {
		if Input.mouse[.Left].pressed {
			data.checked = !data.checked
		}
	}

	rl.DrawRectangleLinesEx(rect, 5, PAL_BG_DEFAULT.default)

	if (data.checked) {
		rect.x += 10
		rect.y += 10
		rect.width -= 20
		rect.height -= 20
		rl.DrawRectangleRec(rect, PAL_BG_DEFAULT.default)
	}

	rl.DrawTextEx(
		data.rendData.font,
		data.caption,
		{data.rect.x + 5, data.rect.y + (data.rect.height - data.rendData.fontSize) / 2},
		data.rendData.fontSize,
		0,
		data.rendData.currentFg,
	)

	return data.checked
}
