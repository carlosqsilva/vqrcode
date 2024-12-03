module main

import math
import strings

#flag -I @VMODROOT/thirdparty
#flag @VMODROOT/thirdparty/qrcodegen.o
#include "qrcodegen.h"

fn C.qrcodegen_encodeText(text &char, tempBuffer &u8, qrcode &u8, ecl int, min int, max int, mask int, boost bool) bool

fn C.qrcodegen_getSize(qrcode &u8) int

fn C.qrcodegen_getModule(qrcode &u8, x int, y int) bool

#include "librsvg/rsvg.h"
#include "cairo.h"

@[typedef]
struct C.RsvgRectangle {
  x f64     // x coordinate
  y f64     // y coordinate
  width f64 // width
  height f64 // height
}

struct C.RsvgHandle {}

fn C.rsvg_handle_new_from_data(
    data &u8,      // equivalent to guint8*
    data_len usize, // equivalent to gsize
    error &&C.GError // equivalent to GError**
) &C.RsvgHandle   // returns RsvgHandle*

fn C.rsvg_handle_set_dpi (handle &C.RsvgHandle, dpi f64)

@[typedef]
struct C.cairo_surface_t {}

fn C.cairo_image_surface_create(
   format int,    // Cairo format enum => always use 0 for CAIRO_FORMAT_ARGB32
   width int,     // surface width
   height int     // surface height
) &C.cairo_surface_t  // pointer to cairo surface

fn C.cairo_surface_write_to_png(
   surface &C.cairo_surface_t,  // pointer to cairo surface
   filename &char               // filename as C string
) int                            // returns status code

@[typedef]
struct C.cairo_t {}

fn C.cairo_create(
   target &C.cairo_surface_t  // pointer to cairo surface
) &C.cairo_t                   // returns pointer to cairo context

fn C.rsvg_handle_render_document(
   handle &C.RsvgHandle,        // RsvgHandle pointer
   cr &C.cairo_t,               // Cairo context pointer
   viewport &C.RsvgRectangle,   // RsvgRectangle pointer for viewport
   error &&C.GError             // GError double pointer
) bool                           // returns gboolean as bool

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

fn buffer_for_version(version int) int {
	return ((version * 4 + 17) * (version * 4 + 17) + 7) / 8 + 1
}

const version_min    = 1
const version_max    = 40
const dot_size       = 10
const	buffer_len_max = buffer_for_version(version_max)

enum QrcodeStyle {
	dot
	round
  sharp
	circle
	square
	pointed
	octagon
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
}

fn new_qrcode(text string, ecl int) ?Qrcode {
	mut qrcode := []u8{len: buffer_len_max}
	mut temp_buffer := []u8{len: buffer_len_max}

	ok := C.qrcodegen_encodeText(&char(text.str), &u8(temp_buffer.data), &u8(qrcode.data),
		ecl, version_min, version_max, int(QRCodeMask.auto), true)

	if ok {
		return Qrcode{
			encode_text: qrcode
			size: C.qrcodegen_getSize(&u8(qrcode.data))
		}
	}

	return none
}

fn (qr Qrcode) is_filled(x int, y int) bool {
	return C.qrcodegen_getModule(&u8(qr.encode_text.data), x, y)
}

fn (qr Qrcode) is_frame(x int, y int) bool {
  frame_size := 7
  if x <= frame_size && y <= frame_size { return true }
  if x <= frame_size && y >= qr.size - frame_size { return true }
  if x >= qr.size - frame_size && y <= frame_size { return true }
  return false
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

fn (mut qr Qrcode) compute_size(conf &Config) int {
  qrsize := qr.size * dot_size

	if conf.logo != '' {
		logo := load_image_from_file(conf.logo)

		height := qrsize * f32(0.2)
		width := logo.width * (height / logo.height)

		x := int((qrsize - width) / 2)
		y := int((qrsize - height) / 2)

		qr.Logo = Logo{
			has_logo: true
			logo: logo
			width: int(width)
			height: int(height)
			x: x
			y: y
			start_x: int(math.floor(x / f32(dot_size)))
			end_x: int(math.floor((width + x) / f32(dot_size)))
			start_y: int(math.floor(y / f32(dot_size)))
			end_y: int(math.floor((height + y) / f32(dot_size)))
		}
	}

	return qrsize + conf.padding * 2
}

fn (mut qr Qrcode) to_svg(conf &Config) string {
	size :=	qr.compute_size(conf)

	filter := fn [qr] (x int, y int, x_offset int, y_offset int) bool {
		return match true {
			(x + x_offset < 0) { false }
			(y + y_offset < 0) { false }
			(x + x_offset >= qr.size) { false }
			(y + y_offset >= qr.size) { false }
			qr.is_image_background(x + x_offset, y + y_offset) { false }
			else { qr.is_filled(x + x_offset, y + y_offset) }
		}
	}

	mut container := new_element('g')
	container.set_attribute('transform', 'translate($conf.padding,$conf.padding)')

	match conf.finder {
	  .circle, .dot {
			container.append_childs(dot_frame(qr.size))
		}
		.pointed {
		  container.append_childs(pointed_frame(qr.size))
		}
    .sharp {
      container.append_childs(sharp_frame(qr.size))
    }
    .octagon {
      container.append_childs(octagon_frame(qr.size))
    }
		.round {
		  container.append_childs(round_frame(qr.size))
		}
		else {}
	}

	skip_frame := match conf.style {
	  .square { false }
		else { true }
	}

	for x in 0 .. qr.size {
		for y in 0 .. qr.size {
			if !qr.is_filled(x, y) || qr.is_image_background(x, y) {
				continue
			}

			if  qr.is_frame(x, y) && skip_frame {
			  continue
			}

			pos_x := x * dot_size
			pos_y := y * dot_size

			element := match conf.style {
				.dot {
				  dot_element(pos_x, pos_y)
				}
				.circle {
				  circle_element(pos_x, pos_y)
				}
				.round {
					round_element(x, y, filter)
				}
				.pointed {
				  pointed_element(x, y, filter)
				}
        .sharp {
          sharp_element(x, y, filter)
        }
				else {
					square_element(pos_x, pos_y)
				}
			}

			container.append_child(element)
		}
	}

	if qr.has_logo {
		mut img := new_element('image')
		img.set_attribute('href', qr.logo.to_base64())
		img.set_attribute('x', qr.x.str())
		img.set_attribute('y', qr.y.str())
		img.set_attribute('width', '${qr.width}px')
		img.set_attribute('height', '${qr.height}px')
		container.append_child(img)
	}

	mut svg := new_element('svg')
	svg.set_attribute('width', size.str())
	svg.set_attribute('height', size.str())
	svg.set_attribute('xmlns', 'http://www.w3.org/2000/svg')
	svg.append_child(container)

	return svg.str()
}

fn (mut qr Qrcode) to_image(conf &Config) {
  svg := qr.to_svg(conf)
  mut handle := C.rsvg_handle_new_from_data(&char(svg.str), svg.len, C.NULL)

  if handle == C.NULL {
    panic("could not create RsvgHandle")
  }

  surface := C.cairo_image_surface_create(0, conf.size, conf.size)
  cx := C.cairo_create(surface)

  viewport := C.RsvgRectangle{
    x: 0.0,
    y: 0.0,
    width: f64(conf.size),
    height: f64(conf.size),
  }

  if !C.rsvg_handle_render_document(handle, cx, &viewport, C.NULL) {
		panic("could not render image")
	}

	if C.cairo_surface_write_to_png(surface, conf.output.str) != 0 {
		panic("could not write output file")
	}
}

fn main() {
  mut config := read_config()

	mut qrcode := new_qrcode(config.content, config.ecl) or {
    panic('failed to create qrcode')
  }

	if config.is_svg {
		println(qrcode.to_svg(config))
	} else if config.output != '' {
		qrcode.to_image(config)
	} else {
		qrcode.print(0)
	}
}
