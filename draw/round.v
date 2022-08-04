module draw

import element
import math

pub fn round(x int, y int, size int, filter fn (int, int) bool) element.Element {
	left_side := filter(-1, 0)
	right_side := filter(1, 0)
	top_side := filter(0, -1)
	bottom_side := filter(0, 1)

	mut count := 0
	for i in [left_side, right_side, top_side, bottom_side] {
		if i {
			count++
		}
	}

	if count == 0 {
		return dot(x, y, size)
	}

	if count > 2 || (left_side && right_side) || (top_side && bottom_side) {
		return square(x, y, size)
	}

	if count == 2 {
		mut rotation := f32(0)

		if left_side && top_side {
			rotation = math.pi / 2
		} else if top_side && right_side {
			rotation = math.pi
		} else if right_side && bottom_side {
			rotation = -math.pi / 2
		}

		return corner_round(x, y, size, rotation)
	}

	if count == 1 {
		mut rotation := f32(0)

		if top_side {
			rotation = math.pi / 2
		} else if right_side {
			rotation = math.pi
		} else if bottom_side {
			rotation = -math.pi / 2
		}

		return side_round(x, y, size, rotation)
	}

	return dot(x, y, size)
}

fn corner_round(x int, y int, size int, rotation f32) element.Element {
	cx := x + size / f32(2)
	cy := y + size / f32(2)
	mut el := element.new_element('path')
	el.set_attribute('d', 'M $x ${y}v ${size}h ${size}v ${-size / f32(2)}a ${size / f32(2)} ${size / f32(2)}, 0, 0, 0, ${-size / f32(2)} ${-size / f32(2)}')
	el.set_attribute('transform', 'rotate(${(180 * rotation) / math.pi},$cx,$cy)')
	return el
}

fn side_round(x int, y int, size int, rotation f32) element.Element {
	cx := x + size / f32(2)
	cy := y + size / f32(2)
	mut el := element.new_element('path')
	el.set_attribute('d', 'M $x ${y}v ${size}h ${size / f32(2)}a ${size / f32(2)} ${size / f32(2)}, 0, 0, 0, 0 ${-size}')
	el.set_attribute('transform', 'rotate(${(180 * rotation) / math.pi},$cx,$cy)')
	return el
}
