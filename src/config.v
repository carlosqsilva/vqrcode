module main

import flag
import os

struct Config {
  ecl      int
  is_svg   bool
  output   string
  logo     string
  style    QrcodeStyle
  finder   QrcodeStyle
  content  string
  padding  int
  pub mut:
  size     int
}

fn read_config() &Config {
  mut fp := flag.new_flag_parser(os.args)
	fp.description('Qrcode generator')
	fp.skip_executable()

	mut ecl := fp.int('ecl', `e`, 0, 'error correction level 0...3')
	is_svg := fp.bool('svg', 0, false, 'output in svg format')
	output := fp.string('output', `o`, '', 'output to png')
	logo := fp.string('logo', `l`, '', 'custom logo')
	style := fp.string('style', `s`, 'round', '"round", "pointed", "square", "sharp", "circle" or "dot"')
	finder := fp.string('finder', `f`, '', '"round", "pointed", "square", "sharp", "octagon", "circle" or "dot"')
  padding := fp.int('padding', `p`, 20, 'padding around the svg')
	mut size := fp.int('size', 0, 500, 'size in px, only valid for image output')

  rest := fp.finalize() or { [] }

  content := if rest.len > 0 { rest[0] } else { os.get_lines_joined() }

  if content.str == 0 {
		eprintln('No text was passed')
    exit(1)
	}

  if ecl !in [0, 1, 2, 3] {
		eprintln('Invalid error correction level, valid values:
          LOW      = 0
          MEDIUM   = 1
          QUARTILE = 2
          HIGH     = 3')
    exit(1)
	}

  // Increase error correction level if logo is present
	if logo.str != 0 && ecl < 2 {
		ecl = 3
	}

  qrcode_style := match style {
		'dot' { QrcodeStyle.dot }
		'round' { QrcodeStyle.round }
		'pointed' { QrcodeStyle.pointed }
    'sharp' { QrcodeStyle.sharp }
		'circle' { QrcodeStyle.circle }
		else { QrcodeStyle.square }
	}

	finder_pattern := match finder {
  	'dot' { QrcodeStyle.dot }
  	'round' { QrcodeStyle.round }
  	'pointed' { QrcodeStyle.pointed }
  	'octagon' { QrcodeStyle.octagon }
    'sharp' { QrcodeStyle.sharp }
  	'circle' { QrcodeStyle.circle }
    else { qrcode_style }
	}

  return &Config{
    ecl: ecl,
    content: content,
    style: qrcode_style,
    finder: finder_pattern,
    is_svg: is_svg,
    output: output,
    logo: logo,
    size: size,
    padding: padding
  }
}
