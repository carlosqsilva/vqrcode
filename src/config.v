module main

import flag
import os

struct Config {
  ecl      int
  is_svg   bool
  output   string
  logo     string
  style    QrcodeStyle
  content  string
  pub mut:
  size     int
}

fn read_config() &Config {
  mut fp := flag.new_flag_parser(os.args)
	fp.description('Qrcode generator')
	fp.skip_executable()

	mut ecl := fp.int('ecl', `e`, 0, 'error correction level 0...3')
	is_svg := fp.bool('svg', `s`, false, 'output in svg format')
	output := fp.string('output', `o`, '', 'output to png')
	logo := fp.string('logo', `l`, '', 'custom logo')
	style := fp.string('style', 0, 'round', '"round", "square" or "dot"')
	mut size := fp.int('size', 0, 0, 'size in px')

  rest := fp.finalize() or { [] }

  content := if rest.len > 0 { rest[0] } else { os.get_lines_joined() }

  if content.str == 0 {
		eprintln('No text was passed')
    exit(1)
	}

  if ecl !in [0, 1, 2, 3] {
		eprintln('Invalid error correction level
          LOW      = 0
          MEDIUM   = 1
          QUARTILE = 2
          HIGH     = 3')
    exit(1)
	}

  // Increase error correction level if logo is present
	if logo.str != 0 && ecl < 2 {
		ecl = 2
	}

  qrcode_style := match style {
		'round' { QrcodeStyle.round }
		'dot' { QrcodeStyle.dot }
		else { QrcodeStyle.square }
	}

  return &Config{
    ecl: ecl,
    content: content,
    style: qrcode_style,
    is_svg: is_svg,
    output: output,
    logo: logo,
    size: size
  }
}
