module draw

import src.element

pub struct Color {
	color string = '#000'
	size  int
	name  string
}

pub fn rect_color(opt Color) element.Element {
	mut rect := element.new_element('rect')
	rect.set_attribute('x', '0')
	rect.set_attribute('y', '0')
	rect.set_attribute('height', opt.size.str())
	rect.set_attribute('width', opt.size.str())
	rect.set_attribute('clip-path', 'url(#clip-path-$opt.name)')
	rect.set_attribute('fill', opt.color.str())

	return rect
}
