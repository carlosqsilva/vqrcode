module draw

import element

pub struct Color {
	color  string = '#000'
	x      int
	y      int
	width  int
	height int
	name   string
}

pub fn rect_color(opt Color) element.Element {
	mut rect := element.new_element('rect')
	rect.set_attribute('x', opt.x.str())
	rect.set_attribute('y', opt.y.str())
	rect.set_attribute('height', opt.height.str())
	rect.set_attribute('width', opt.width.str())
	rect.set_attribute('clip-path', 'url(#clip-path-$opt.name)')
	rect.set_attribute('color', opt.color.str())

	return rect
}
