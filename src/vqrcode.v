module main

import os
import flag
import math
import strings
import src.element
import src.image
import src.draw

#include "@VMODROOT/thirdparty/qrcodegen.c"

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

const (
	version_min    = 1
	version_max    = 40
	buffer_len_max = buffer_for_version(version_max)
)

enum QrcodeStyle {
	dot
	round
	square
}

struct Qrcode {
	encode_text []u8
	size        int
	style       QrcodeStyle = .dot
}

fn new_qrcode(text string, ecl int, style QrcodeStyle) ?Qrcode {
	mut qrcode := []u8{len: buffer_len_max}
	mut temp_buffer := []u8{len: buffer_len_max}

	mask_level := int(QRCodeMask.auto)

	ok := C.qrcodegen_encodeText(&char(text.str), &u8(temp_buffer.data), &u8(qrcode.data),
		ecl, version_min, version_max, mask_level, true)

	if ok {
		return Qrcode{
			encode_text: qrcode
			size: C.qrcodegen_getSize(&u8(qrcode.data))
			style: style
		}
	}

	return none
}

fn (qr Qrcode) get_size() int {
	return C.qrcodegen_getSize(&u8(qr.encode_text.data))
}

fn (qr Qrcode) is_filled(x int, y int) bool {
	return C.qrcodegen_getModule(&u8(qr.encode_text.data), x, y)
}

fn (qr Qrcode) print(border int) {
	length := qr.size + border
	mut content := strings.new_builder(length * length)
	for y in -border .. length {
		for x in -border .. length {
			content.write_string(if qr.is_filled(x, y) { '██' } else { '  ' })
		}
		content.write_string('\n')
	}
	println(content)
}

fn (qr Qrcode) compute_size(size int, border int) (int, int) {
	min_size := size - border * 2
	mut dot_size := int(math.floor(min_size / f32(qr.size)))

	if dot_size % 2 != 0 {
		dot_size++
	}

	padding := int(math.floor((size - qr.size * dot_size) / 2))

	return dot_size, padding
}

fn (qr Qrcode) to_image(size int, path string) {
	dot_size, padding := qr.compute_size(size, 0)

	mut img := image.new_image(size)

	for x in 0 .. qr.size {
		for y in 0 .. qr.size {
			if !qr.is_filled(x, y) {
				continue
			}
			img.set_pixel(x, y, padding, dot_size, true)
		}
	}

	img.save_image_as(path)
}

fn (qr Qrcode) to_svg(size int, border int) string {
	dot_size, padding := qr.compute_size(size, border)

	mut clippath := element.new_element('clipPath')
	clippath.set_attribute('id', 'clip-path-dot-color')

	for x in 0 .. qr.size {
		for y in 0 .. qr.size {
			if !qr.is_filled(x, y) {
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
					else { qr.is_filled(x + x_offset, y + y_offset) }
				}
			}

			dot := match qr.style {
				.dot {
					draw.dot(pos_x, pos_y, dot_size)
				}
				.round {
					draw.round(pos_x, pos_y, dot_size, filter)
				}
				else {
					draw.square(pos_x, pos_y, dot_size)
				}
			}

			clippath.append_child(dot)
		}
	}

	mut defs := element.new_element('defs')
	defs.append_child(clippath)

	color := draw.rect_color(draw.Color{
		name: 'dot-color'
		x: padding
		y: padding
		height: qr.size * dot_size
		width: qr.size * dot_size
	})

	mut svg := element.new_element('svg')
	svg.set_attribute('width', size.str())
	svg.set_attribute('height', size.str())
	svg.set_attribute('xmlns', 'http://www.w3.org/2000/svg')
	svg.set_attribute('xmlns:xlink', 'http://www.w3.org/1999/xlink')
	svg.append_child(defs)
	svg.append_child(color)

	return svg.str()
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.description('Qrcode generator')
	fp.skip_executable()

	ecl := fp.int('ecl', `e`, 0, 'error correction level 0...3')
	is_svg := fp.bool('svg', `s`, false, 'output in svg format')
	image := fp.string('img', 0, '', 'output to png')
	style := fp.string('style', 0, 'round', '"round", "square" or "dot"')
	size := fp.int('size', 0, 300, 'size in px')

	rest := fp.finalize() or { [] }

	if rest.len == 0 {
		panic('No text was passed')
	}

	if ecl !in [0, 1, 2, 3] {
		panic('Invalid error correction level
          LOW      = 0
          MEDIUM   = 1
          QUARTILE = 2
          HIGH     = 3')
	}

	qrcode_style := match style {
		'round' { QrcodeStyle.round }
		'dot' { QrcodeStyle.dot }
		else { QrcodeStyle.square }
	}

	mut qrcode := new_qrcode(rest[0], ecl, qrcode_style) or { panic('failed to create qrcode') }

	if qrcode.size > size {
		panic('size argument too small, svg required min size: $qrcode.size')
	}

	if is_svg {
		println(qrcode.to_svg(size, 0))
	} else if image != '' {
		qrcode.to_image(size, image)
	} else {
		qrcode.print(0)
	}
}
