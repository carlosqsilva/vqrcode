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

pub fn (mut img Image) to_base64() string {
	return 'data:image/$img.ext;base64,${base64.encode(img.buffer)}'
}

