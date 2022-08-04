module draw

import element

pub fn dot(x int, y int, size int) element.Element {
	mut el := element.new_element('circle')
	el.set_attribute('cx', '${x + size / 2}')
	el.set_attribute('cy', '${y + size / 2}')
	el.set_attribute('r', '${size / 2}')

	return el
}
