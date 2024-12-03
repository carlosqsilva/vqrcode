module main

pub struct Color {
	color string = '#000'
	size  int
	name  string
}

pub fn rect_color(opt Color) Element {
	mut rect := new_element('rect')
	rect.set_attribute('x', '0')
	rect.set_attribute('y', '0')
	rect.set_attribute('height', opt.size.str())
	rect.set_attribute('width', opt.size.str())
	rect.set_attribute('clip-path', 'url(#clip-path-$opt.name)')
	rect.set_attribute('fill', opt.color.str())

	return rect
}

pub fn round_element(x int, y int, filter fn (int, int, int, int) bool) Element {
	left_side := filter(x, y, -1, 0)
	right_side := filter(x, y, 1, 0)
	top_side := filter(x, y, 0, -1)
	bottom_side := filter(x, y, 0, 1)

	pos_x := x * dot_size
	pos_y := y * dot_size

	mut count := 0
	for i in [left_side, right_side, top_side, bottom_side] {
		if i { count++ }
	}

	if count > 2 || (left_side && right_side) || (top_side && bottom_side) {
		return square_element(pos_x, pos_y)
	}

	if count == 2 {
		mut rotation := 0

		if left_side && top_side {
			rotation = 90
		} else if top_side && right_side {
			rotation = 180
		} else if right_side && bottom_side {
			rotation = -90
		}

		return corner_round(pos_x, pos_y, rotation)
	}

	if count == 1 {
		mut rotation := 0

		if top_side {
			rotation = 90
		} else if right_side {
			rotation = 180
		} else if bottom_side {
			rotation = -90
		}

		return side_round(pos_x, pos_y, rotation)
	}

	return circle_element(pos_x, pos_y)
}

fn corner_round(x int, y int, rotation f32) Element {
  center := dot_size / 2
	cx := x + center
	cy := y + center
	mut el := new_element('path')
	el.set_attribute('d', 'M $x ${y}v ${dot_size}h ${dot_size}v ${-center}a ${center} ${center}, 0, 0, 0, ${-center} ${-center}')
	el.set_attribute('transform', 'rotate(${rotation},$cx,$cy)')
	return el
}

fn side_round(x int, y int, rotation f32) Element {
  center := dot_size / 2
	cx := x + center
	cy := y + center
	mut el := new_element('path')
	el.set_attribute('d', 'M $x ${y}v ${dot_size}h ${center}a ${center} ${center}, 0, 0, 0, 0 ${-dot_size}')
	el.set_attribute('transform', 'rotate(${rotation},$cx,$cy)')
	return el
}

pub fn square_element(x int, y int) Element {
	mut el := new_element('rect')
	el.set_attribute('x', x.str())
	el.set_attribute('y', y.str())
  size := dot_size.str()
	el.set_attribute('width', size)
	el.set_attribute('height', size)
	return el
}

pub fn circle_element(x int, y int) Element {
	mut el := new_element('circle')
  radius := dot_size / 2
	el.set_attribute('cx', '${x + radius}')
	el.set_attribute('cy', '${y + radius}')
	el.set_attribute('r', '${radius}')

	return el
}

pub fn dot_element(x int, y int) Element {
  mut dot := circle_element(x, y)
  dot.set_attribute('r', '${(dot_size / 2) - 1}')
  return dot
}

pub fn pointed_element(x int, y int, filter fn (int, int, int, int) bool) Element {
	left_side := filter(x, y, -1, 0)
	right_side := filter(x, y, 1, 0)
	top_side := filter(x, y, 0, -1)
	bottom_side := filter(x, y, 0, 1)

	mut count := 0
	for i in [left_side, right_side, top_side, bottom_side] {
		if i { count++ }
	}

	pos_x := x * dot_size
	pos_y := y * dot_size

	if count > 2 || (left_side && right_side) || (top_side && bottom_side) {
		return square_element(pos_x, pos_y)
	}

	if count == 2 {
		mut rotation := f32(0)

    if left_side && top_side {
			rotation = 90
		} else if top_side && right_side {
			rotation = 180
		} else if right_side && bottom_side {
			rotation = -90
		}

		return corner_round(pos_x, pos_y, rotation)
	}

	mut container := new_element('g')
	container.set_attribute('transform', 'translate(${pos_x},${pos_y}) scale(0.1,0.1)')

	if count == 0 {
	  mut polygon := new_element('polygon')
		polygon.set_attribute('points', '99.999,49.999 99.998,49.999 49.999,0 0,49.999 -0.001,49.999 -0.001,50 0,50 49.999,99.999 99.998,50 99.999,50
			99.998,50')
		container.append_child(polygon)
	}

	if count == 1 {
	  mut pointed_side := new_element('polygon')

		match true {
		  left_side { pointed_side.set_attribute('points', '0,100 100,50 100,50 0,0') }
			right_side { pointed_side.set_attribute('points', '100,100 0,50 0,50 100,0') }
			top_side { pointed_side.set_attribute('points', '0,-0.001 50,99.999 50,99.999 100,-0.001') }
			// bottom
			else { pointed_side.set_attribute('points', '100,100 50,0 50,0 0,100') }
		}

		container.append_child(pointed_side)
	}

	return container
}

pub fn sharp_element(x int, y int, filter fn (int, int, int, int) bool) Element {
  left_side := filter(x, y, -1, 0)
	right_side := filter(x, y, 1, 0)
	top_side := filter(x, y, 0, -1)
	bottom_side := filter(x, y, 0, 1)

	mut count := 0
	for i in [left_side, right_side, top_side, bottom_side] {
		if i { count++ }
	}

	pos_x := x * dot_size
	pos_y := y * dot_size

	if count == 0 {
		return circle_element(pos_x, pos_y)
	}

	if count > 2 || (left_side && right_side) || (top_side && bottom_side) {
		return square_element(pos_x, pos_y)
	}

	if count == 2 {
		mut rotation := f32(0)

    if left_side && top_side {
			rotation = 90
		} else if top_side && right_side {
			rotation = 180
		} else if right_side && bottom_side {
			rotation = -90
		}

		return corner_round(pos_x, pos_y, rotation)
	}

	mut container := new_element('g')
	container.set_attribute('transform', 'translate(${pos_x},${pos_y}) scale(0.715,0.715)')

	if count == 1 {
	  mut sharp_side := new_element('path')

		match true {
		  left_side { sharp_side.set_attribute('d', 'M0,14V0c0,0,9.15,4.38,14,0.55C14,0.55,14.24,14,0,14z') }
			right_side { sharp_side.set_attribute('d', 'M13.999,0v14c0,0-9.151-4.381-14-0.551C-0.001,13.449-0.242,0,13.999,0z') }
			top_side { sharp_side.set_attribute('d', 'M-0.001,0l14,0c0,0-4.381,9.151-0.551,14C13.448,14-0.001,14.24-0.001,0z') }
			// bottom
			else { sharp_side.set_attribute('d', 'M14,14H0c0,0,4.38-9.15,0.55-14C0.55,0,14-0.24,14,14z') }
		}

		container.append_child(sharp_side)
	}

	return container
}

pub fn dot_frame(frame_size int) []Element {
  mut circle := new_element('circle')
  circle.set_attribute('cx', '35')
  circle.set_attribute('cy', '35')
  circle.set_attribute('r', '15')

  mut path := new_element('path')
  path.set_attribute('transform', 'scale(0.687,0.687)')
  path.set_attribute('d', 'M51,1C23.387,1,1,23.387,1,51s22.387,50,50,50s50-22.387,50-50S78.613,1,51,1z M51,86c-19.299,0-35-15.701-35-35
		s15.701-35,35-35s35,15.701,35,35S70.299,86,51,86z')


  mut top_left := new_element('g')
  top_left.append_child(circle)
  top_left.append_child(path)

  position := (frame_size - 7) * 10

  mut top_right := new_element('g')
  top_right.set_attribute('transform', 'translate(${position},0)')
  top_right.append_child(circle)
  top_right.append_child(path)

  mut bottom_left := new_element('g')
  bottom_left.set_attribute('transform', 'translate(0,${position})')
  bottom_left.append_child(circle)
  bottom_left.append_child(path)

  return [top_left, top_right, bottom_left]
}

pub fn round_frame(frame_size int) []Element {
  mut outer_path := new_element('path')
  outer_path.set_attribute('transform', 'scale(0.7,0.7)')
  outer_path.set_attribute('d', 'M65.859,0.008H34.141h0C18.683,0.008,5.587,10.221,1.4,24.18c-0.433,1.444-0.771,2.928-1.006,4.445
		C0.135,30.299,0,32.013,0,33.758v32.471c0,18.619,15.32,33.76,34.141,33.76L50,99.992l15.859-0.004
		c18.82,0,34.141-15.141,34.141-33.76V33.758C100,15.148,84.68,0.008,65.859,0.008z M85,66.229c0,10.344-8.586,18.76-19.145,18.76
		L50,84.992l-15.855-0.004C23.586,84.988,15,76.572,15,66.229V33.758c0-3.231,0.838-6.273,2.313-8.931
		c1.42-2.557,3.429-4.756,5.848-6.421c3.11-2.141,6.897-3.398,10.979-3.398h31.719C76.414,15.008,85,23.419,85,33.758V66.229z')

  mut inner_path := new_element('path')
  inner_path.set_attribute('transform', 'translate(20,20) scale(0.3,0.3)')
  inner_path.set_attribute('d', 'M27.351,100c-15.09,0-27.365-12.032-27.365-26.808V26.794c0-4.616,1.2-8.96,3.301-12.761
				c2.029-3.658,4.901-6.802,8.36-9.174C16.09,1.801,21.506,0,27.336,0h45.327c15.076,0,27.351,12.018,27.351,26.793v46.398
				c0,14.775-12.274,26.808-27.351,26.808H50H27.351z')

  mut top_left := new_element('g')
  top_left.append_child(outer_path)
  top_left.append_child(inner_path)

  position := (frame_size - 7) * 10

  mut top_right := new_element('g')
  top_right.set_attribute('transform', 'translate(${position},0)')
  top_right.append_child(outer_path)
  top_right.append_child(inner_path)

  mut bottom_left := new_element('g')
  bottom_left.set_attribute('transform', 'translate(0,${position})')
  bottom_left.append_child(outer_path)
  bottom_left.append_child(inner_path)

  return [top_left, top_right, bottom_left]
}

pub fn pointed_frame(frame_size int) []Element {
  mut outer_path := new_element('path')
  outer_path.set_attribute('transform', 'scale(0.7,0.7)')
  outer_path.set_attribute('d', 'M100,66.221V33.75C100,15.141,84.68,0,65.859,0H34.14C15.32,0,0,15.141,0,33.75V100l65.859-0.02
		C84.68,99.98,100,84.84,100,66.221z M85,66.221c0,10.344-8.586,18.76-19.145,18.76L15,84.996V33.75C15,23.411,23.586,15,34.14,15
		h31.719C76.414,15,85,23.411,85,33.75V66.221z')

  mut inner_path := new_element('path')
  inner_path.set_attribute('transform', 'translate(20,20) scale(0.3,0.3)')
  inner_path.set_attribute('d', 'M100,72.779V27.195C100,12.203,87.604,0,72.37,0H27.63C12.397,0,0,12.203,0,27.195V100l72.37-0.042
	C87.604,99.958,100,87.771,100,72.779z')

  mut top_left := new_element('g')
  top_left.set_attribute('transform', 'translate(70,0) scale(-1,1)')
  top_left.append_child(outer_path)
  top_left.append_child(inner_path)

  position := (frame_size - 7) * 10

  mut top_right := new_element('g')
  top_right.set_attribute('transform', 'translate(${position},0)')
  top_right.append_child(outer_path)
  top_right.append_child(inner_path)

  mut bottom_left := new_element('g')
  bottom_left.set_attribute('transform', 'translate(70,${position + 70}) scale(-1,-1)')
  bottom_left.append_child(outer_path)
  bottom_left.append_child(inner_path)

  return [top_left, top_right, bottom_left]
}

pub fn sharp_frame(frame_size int) []Element {
  mut outer_path := new_element('path')
  outer_path.set_attribute('transform', 'scale(0.7,0.7)')
  outer_path.set_attribute('d', 'M66.25,0H33.78C15.16,0,0.02,15.32,0.02,34.14L0,100h66.25C84.86,100,100,84.68,100,65.86V34.14V0H66.25z M85,65.86
		C85,76.414,76.589,85,66.25,85H15.004l0.016-50.855C15.02,23.586,23.436,15,33.78,15H85V65.86z')

  mut inner_path := new_element('path')
  inner_path.set_attribute('transform', 'translate(20,20) scale(0.3,0.3)')
  inner_path.set_attribute('d', 'M72.744-0.021H27.23c-2.341,0-4.612,0.297-6.771,0.875C15.679,2.11,11.418,4.648,8.04,8.09
	c-0.617,0.621-1.206,1.284-1.752,1.96c-3.883,4.767-6.21,10.903-6.21,17.561L0.05,99.979h72.694
	c14.971,0,27.138-12.397,27.138-27.63V27.625v-0.014l0.168-27.617C100.05-0.006,82.107-0.021,72.744-0.021z')

  mut top_left := new_element('g')
  top_left.set_attribute('transform', 'translate(70,0) scale(-1,1)')
  top_left.append_child(outer_path)
  top_left.append_child(inner_path)

  position := (frame_size - 7) * 10

  mut top_right := new_element('g')
  top_right.set_attribute('transform', 'translate(${position},0)')
  top_right.append_child(outer_path)
  top_right.append_child(inner_path)

  mut bottom_left := new_element('g')
  bottom_left.set_attribute('transform', 'translate(70,${position + 70}) scale(-1,-1)')
  bottom_left.append_child(outer_path)
  bottom_left.append_child(inner_path)

  return [top_left, top_right, bottom_left]
}

pub fn octagon_frame(frame_size int) []Element {
  mut outer_path := new_element('path')
  outer_path.set_attribute('d', 'M0 20 20 0h30l20 20v30L50 70H20L0 50Zm10 25.714L24.286 60h21.428L60 45.714V24.286L45.714 10H24.286L10 24.286Z')

  mut inner_path := new_element('circle')
  inner_path.set_attribute("cx", "35")
  inner_path.set_attribute("cy", "35")
  inner_path.set_attribute("r", "15")

  mut top_left := new_element('g')
  top_left.append_child(outer_path)
  top_left.append_child(inner_path)

  position := (frame_size - 7) * 10

  mut top_right := new_element('g')
  top_right.set_attribute('transform', 'translate(${position},0)')
  top_right.append_child(outer_path)
  top_right.append_child(inner_path)

  mut bottom_left := new_element('g')
  bottom_left.set_attribute('transform', 'translate(0,${position})')
  bottom_left.append_child(outer_path)
  bottom_left.append_child(inner_path)

  return [top_left, top_right, bottom_left]
}
