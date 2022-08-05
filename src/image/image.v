module image

import gx
import stbi

pub struct Image {
	width    int
	height   int
	channels int = 3
mut:
	data []byte
}

pub fn new_image(size int) &Image {
	return &Image{
		width: size
		height: size
		data: []byte{len: size * size * 3, init: 255}
	}
}

pub fn (mut img Image) set_pixel(x int, y int, padding int, dot_size int, is_filled bool) {
	color := if is_filled { gx.black } else { gx.white }

	x_start := padding + x * dot_size
	x_final := x_start + dot_size

	y_start := padding + y * dot_size
	y_final := y_start + dot_size

	for i in y_start .. y_final {
		for j in x_start .. x_final {
			pos := (i * img.width + j) * img.channels

			img.data[pos] = color.r
			img.data[pos + 1] = color.g
			img.data[pos + 2] = color.b
		}
	}
}

pub fn (mut img Image) save_image_as(path string) {
	stbi.stbi_write_png(path, img.width, img.height, img.channels, img.data.data, img.width * img.channels) or {
		panic(err)
	}
}
