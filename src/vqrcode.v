module main

import math
import strings

#flag -I @VMODROOT/thirdparty
#flag @VMODROOT/thirdparty/qrcodegen.o
#include "qrcodegen.h"

enum ErrorCorrectionLevel {
	low = 0 // The QR Code can tolerate about  7% erroneous codewords
	medium = 1 // The QR Code can tolerate about 15% erroneous codewords
	quartile = 2 // The QR Code can tolerate about 25% erroneous codewords
	high = 3 // The QR Code can tolerate about 30% erroneous codewords
}

enum QRCodeMask {
	auto = -1
	level0 = 0
	level1 = 1
	level2 = 2
	level3 = 3
	level4 = 4
	level5 = 5
	level6 = 6
	level7 = 7
}

fn C.qrcodegen_encodeText(text &char, tempBuffer &u8, qrcode &u8, ecl int, min int, max int, mask int, boost bool) bool

fn C.qrcodegen_getSize(qrcode &u8) int

fn C.qrcodegen_getModule(qrcode &u8, x int, y int) bool

fn buffer_for_version(version int) int {
	return ((version * 4 + 17) * (version * 4 + 17) + 7) / 8 + 1
}

const version_min    = 1
const version_max    = 40
const	buffer_len_max = buffer_for_version(version_max)

enum QrcodeStyle {
	dot
	round
	square
}

struct Logo {
mut:
	logo     Image
	has_logo bool
	width    int
	height   int
	x        int
	y        int
	start_x  int
	end_x    int
	start_y  int
	end_y    int
}

fn (l Logo) is_image_background(x int, y int) bool {
	if !l.has_logo {
		return false
	}

	return (x >= l.start_x && x <= l.end_x) && (y >= l.start_y && y <= l.end_y)
}

struct Qrcode {
	Logo
	encode_text []u8
	size        int
	style       QrcodeStyle = .dot
}

fn new_qrcode(text string, ecl int, style QrcodeStyle) ?Qrcode {
	mut qrcode := []u8{len: buffer_len_max}
	mut temp_buffer := []u8{len: buffer_len_max}

	ok := C.qrcodegen_encodeText(&char(text.str), &u8(temp_buffer.data), &u8(qrcode.data),
		ecl, version_min, version_max, int(QRCodeMask.auto), true)

	if ok {
		return Qrcode{
			encode_text: qrcode
			size: C.qrcodegen_getSize(&u8(qrcode.data))
			style: style
		}
	}

	return none
}

fn (qr Qrcode) is_filled(x int, y int) bool {
	return C.qrcodegen_getModule(&u8(qr.encode_text.data), x, y)
}

struct Options {
	size   int
	border int
	path   string
	logo   string
}

fn (qr Qrcode) print(opt Options) {
	length := qr.size + opt.border
	mut content := strings.new_builder(length * length)
	for y in -opt.border .. length {
		for x in -opt.border .. length {
			content.write_string(if qr.is_filled(x, y) { '██' } else { '  ' })
		}
		content.write_string('\n')
	}
	println(content)
}

fn (mut qr Qrcode) compute_size(opt Options) (int, int) {
	min_size := opt.size - opt.border * 2

	mut dot_size := int(math.floor(min_size / f32(qr.size)))

	if dot_size % 2 != 0 {
		dot_size++
	}

	padding := int(math.floor((opt.size - qr.size * dot_size) / 2))

	if opt.logo != '' {
		logo := load_image_from_file(opt.logo)
		new_height := opt.size * f32(0.2)
		new_width := logo.width * (new_height / logo.height)
		x := int(padding + (qr.size * dot_size - new_width) / 2)
		y := int(padding + (qr.size * dot_size - new_height) / 2)

		qr.Logo = Logo{
			has_logo: true
			logo: logo
			width: int(new_width)
			height: int(new_height)
			x: x
			y: y
			start_x: int(math.floor((x - padding) / f32(dot_size)))
			end_x: int(math.floor((new_width + x - padding) / f32(dot_size)))
			start_y: int(math.floor((y - padding) / f32(dot_size)))
			end_y: int(math.floor((new_height + y - padding) / f32(dot_size)))
		}
	}

	return dot_size, padding
}

fn (mut qr Qrcode) to_image(opt Options) {
	dot_size, padding := qr.compute_size(opt)

	mut img := new_image(opt.size)

	for x in 0 .. qr.size {
		for y in 0 .. qr.size {
			if !qr.is_filled(x, y) || qr.is_image_background(x, y) {
				continue
			}
			img.set_pixel(x, y, padding, dot_size)
		}
	}

	if qr.has_logo {
		qr.logo.resize(qr.width, qr.height)
		img.fill_image(qr.x, qr.y, qr.logo)
	}

	img.save_image_as(opt.path)
}

fn (mut qr Qrcode) to_svg(opt Options) string {
	dot_size, padding := qr.compute_size(opt)

	mut clippath := new_element('clipPath')
	clippath.set_attribute('id', 'clip-path-dot-color')

	for x in 0 .. qr.size {
		for y in 0 .. qr.size {
			if !qr.is_filled(x, y) || qr.is_image_background(x, y) {
				continue
			}

			pos_x := padding + x * dot_size
			pos_y := padding + y * dot_size

			filter := fn [x, y, qr] (x_offset int, y_offset int) bool {
				return match true {
					(x + x_offset < 0) { false }
					(y + y_offset < 0) { false }
					(x + x_offset >= qr.size) { false }
					(y + y_offset >= qr.size) { false }
					qr.is_image_background(x + x_offset, y + y_offset) { false }
					else { qr.is_filled(x + x_offset, y + y_offset) }
				}
			}

			dot := match qr.style {
				.dot {
					dot_element(pos_x, pos_y, dot_size)
				}
				.round {
					round_element(pos_x, pos_y, dot_size, filter)
				}
				else {
					square_element(pos_x, pos_y, dot_size)
				}
			}

			clippath.append_child(dot)
		}
	}

	mut defs := new_element('defs')
	defs.append_child(clippath)

	color := rect_color(
		name: 'dot-color'
		size: opt.size
	)

	mut svg := new_element('svg')
	svg.set_attribute('width', opt.size.str())
	svg.set_attribute('height', opt.size.str())
	svg.set_attribute('xmlns', 'http://www.w3.org/2000/svg')
	svg.set_attribute('xmlns:xlink', 'http://www.w3.org/1999/xlink')
	svg.append_child(defs)
	svg.append_child(color)

	if qr.has_logo {
		mut img := new_element('image')
		img.set_attribute('href', qr.logo.to_base64())
		img.set_attribute('x', qr.x.str())
		img.set_attribute('y', qr.y.str())
		img.set_attribute('width', '${qr.width}px')
		img.set_attribute('height', '${qr.height}px')
		svg.append_child(img)
	}

	return svg.str()
}

fn main() {
  mut config := read_config()

	mut qrcode := new_qrcode(config.content, config.ecl, config.style) or {
    panic('failed to create qrcode')
  }

	config.size = if config.size > 0 { config.size } else { qrcode.size * 10 + 10 }

	if config.size != 0 && qrcode.size > config.size {
		panic('size argument too small, required min size for data passed is: $qrcode.size')
	}

	if config.is_svg {
		println(qrcode.to_svg(size: config.size, border: 0, logo: config.logo))
	} else if config.output != '' {
		qrcode.to_image(size: config.size, path: config.output, logo: config.logo)
	} else {
		qrcode.print(border: 0)
	}
}
