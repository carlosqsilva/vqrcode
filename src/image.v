module image

import os
import gx
import stbi
import encoding.base64

#include "stbi_image_resize.h"
#flag @VMODROOT/thirdparty/stbi_image_resize.o

fn C.stbir_resize_uint8(input_data voidptr, input_w int, input_h int, input_stride int, output_data voidptr, out_w int, out_h int, out_stride int, channels int) int

pub struct Image {
pub mut:
	width    int
	height   int
	channels int = 3
	ext      string
	buffer   []u8
	data     []byte
}

pub fn new_image(size int) &Image {
	return &Image{
		width: size
		height: size
		data: []byte{len: size * size * 3, init: 255}
	}
}

pub fn load_from_file(path string) &Image {
	if !os.exists(path) {
		panic('$path not found')
	}

	mut file := os.read_file(path) or { panic('Failed to read file at $path') }

	img := stbi.load_from_memory(file.str, file.len) or { panic(err) }

	data := []byte{len: img.width * img.height * img.nr_channels}

	unsafe {
		C.memcpy(data.data, img.data, data.len)
	}

	return &Image{
		width: img.width
		height: img.height
		channels: img.nr_channels
		ext: path.all_after_last('.')
		data: data
		buffer: file.bytes()
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

pub fn (mut img Image) to_base64() string {
	return 'data:image/$img.ext;base64,${base64.url_encode(img.buffer)}'
}

pub fn (mut img Image) resize(width int, height int) {
	data := []byte{len: width * height * img.channels}
	result := C.stbir_resize_uint8(&u8(img.data.data), img.width, img.height, 0, &u8(data.data),
		width, height, 0, img.channels)
	if result != 1 {
		panic('failed to resize image')
	}
	img.width = width
	img.height = height
	img.data = data
}

pub fn (mut img Image) fill_image(x int, y int, image Image) {
	if image.channels == 3 {
		xsize := image.width * image.channels
		for i in 0 .. image.height {
			dx := ((i + y) * img.width + x) * img.channels
			sx := i * xsize
			unsafe {
				C.memcpy(&u8(img.data.data) + dx, &u8(image.data.data) + sx, xsize)
			}
		}
		return
	}

	alpha_blend := fn (background int, foreground int, foreground_alpha int) int {
		alpha := foreground_alpha / f32(255)
		return int((foreground * alpha) + background * (1 - alpha))
	}

	if image.channels == 4 {
		for i in 0 .. image.height {
			for j in 0 .. image.width {
				k := (i * image.width + j) * image.channels
				o := ((i + y) * img.width + (j + x)) * img.channels
				if image.data[k + 3] == 0 {
					continue
				}
				img.data[o] = alpha_blend(img.data[o], image.data[k], image.data[k + 3])
				img.data[o + 1] = alpha_blend(img.data[o + 1], image.data[k + 1], image.data[k + 3])
				img.data[o + 2] = alpha_blend(img.data[o + 2], image.data[k + 2], image.data[k + 3])
			}
		}
	}
}

pub fn (mut img Image) save_image_as(path string) {
	stbi.stbi_write_png(path, img.width, img.height, img.channels, img.data.data, img.width * img.channels) or {
		panic(err)
	}
}
