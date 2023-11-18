module main

import os
import stbi
import encoding.base64

pub struct Image {
pub mut:
	width    int
	height   int
	nr_channels int = 3
	ext      string
	data     []u8
  buffer   []u8
}

pub fn new_image(size int) &Image {
	return &Image{
		width: size
		height: size
		data: []u8{len: size * size * 3, init: 255}
	}
}

pub fn load_image_from_file(path string) &Image {
	if !os.exists(path) {
		panic('$path not found')
	}

	mut file := os.read_file(path) or { panic('Failed to read file at $path') }
	img := stbi.load_from_memory(file.str, file.len) or { panic(err) }

	data := []u8{len: img.width * img.height * img.nr_channels}

	unsafe {
		C.memcpy(data.data, img.data, data.len)
	}

	return &Image{
		width: img.width
		height: img.height
		nr_channels: img.nr_channels
		ext: path.all_after_last('.')
		data: data,
    buffer: file.bytes()
	}
}

pub fn (mut img Image) set_pixel(x int, y int, padding int, dot_size int) {
	x_start := padding + x * dot_size
	x_final := x_start + dot_size

	y_start := padding + y * dot_size
	y_final := y_start + dot_size

	for i in y_start .. y_final {
		for j in x_start .. x_final {
			pos := (i * img.width + j) * img.nr_channels

			img.data[pos] = 0
			img.data[pos + 1] = 0
			img.data[pos + 2] = 0
		}
	}
}

pub fn (mut img Image) to_base64() string {
	return 'data:image/$img.ext;base64,${base64.encode(img.buffer)}'
}

pub fn (mut img Image) resize(width int, height int) {
  new_image := stbi.resize_uint8(
      &stbi.Image{width: img.width, height: img.height, data: img.data.data, nr_channels: img.nr_channels},
      width,
      height
    ) or {
    panic('failed to resize image')
  }

	mut data := []u8{len: width * height * img.nr_channels}

  unsafe {
    C.memcpy(data.data, new_image.data, data.len)
  }

	img.width = width
	img.height = height
	img.data = data
}

pub fn (mut img Image) fill_image(x int, y int, logo Image) {
	if logo.nr_channels == 3 {
		xsize := logo.width * logo.nr_channels
		for i in 0 .. logo.height {
			dx := ((i + y) * img.width + x) * img.nr_channels
			sx := i * xsize
			unsafe {
				C.memcpy(&u8(img.data.data) + dx, &u8(logo.data.data) + sx, xsize)
			}
		}
		return
	}

	alpha_blend := fn (background int, foreground int, foreground_alpha int) u8 {
		alpha := foreground_alpha / f32(255)
		return u8((foreground * alpha) + background * (1 - alpha))
	}

	if logo.nr_channels == 4 {
		for i in 0 .. logo.height {
			for j in 0 .. logo.width {
				k := (i * logo.width + j) * logo.nr_channels
				o := ((i + y) * img.width + (j + x)) * img.nr_channels
				if logo.data[k + 3] == 0 {
					continue
				}
				img.data[o] = alpha_blend(img.data[o], logo.data[k], logo.data[k + 3])
				img.data[o + 1] = alpha_blend(img.data[o + 1], logo.data[k + 1], logo.data[k + 3])
				img.data[o + 2] = alpha_blend(img.data[o + 2], logo.data[k + 2], logo.data[k + 3])
			}
		}
	}
}

pub fn (mut img Image) save_image_as(path string) {
	stbi.stbi_write_png(path, img.width, img.height, img.nr_channels, img.data.data, img.width * img.nr_channels) or {
		panic(err)
	}
}
