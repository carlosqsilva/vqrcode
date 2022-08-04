module draw

import element

pub fn square(x int, y int, size int) element.Element {
	mut el := element.new_element('rect')
	el.set_attribute('x', '"$x.str()"')
	el.set_attribute('y', '"$y.str()"')
	el.set_attribute('width', '"$size.str()"')
	el.set_attribute('height', '"$size.str()"')
	return el
}
