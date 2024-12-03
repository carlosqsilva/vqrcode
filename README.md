# vqrcode

CLI for creating QR codes

## Examples

<p float="left">
<img style="display:inline-block" width="200" src="https://user-images.githubusercontent.com/19891059/210896313-5d5941e9-6955-4f58-ab16-9114f4114c28.svg" />
<img style="display:inline-block" width="200" src="https://user-images.githubusercontent.com/19891059/210896391-e9da0b80-6e56-4620-8ffe-7f2fddbbe024.svg" />
<img style="display:inline-block" width="200" src="https://user-images.githubusercontent.com/19891059/210896490-e97456f4-51da-4e84-9042-176f84a11f5e.svg" />
</p>

### Usage

```bash
pbpaste | vqrcode
pbpaste | vqrcode -o > qrcode.png
pbpaste | vqrcode --svg | pbcopy
pbpaste | vqrcode --svg > qrcode.svg

vqrcode 'hello'                                  # print qrcode as ascii to console
vqrcode 'hello' --svg -s "pointed"               # print qrcode in svg, with "pointed" style
vqrcode 'hello' --svg > qrcode.svg               # output qrcode to file
vqrcode 'hello' -o qrcode.png                    # output qrcode to png file (only support png)
vqrcode 'hello' --svg | pbcopy                   # output qrcode to clipboard
vqrcode 'hello' --svg -l ./logo.png | pbcopy     # output qrcode with custom logo to clipboard
vqrcode 'hello' -l ./logo.png -o ./qrcode.png    # output qrcode with custom logo to file
```

flags:

```sh
 --ecl     -e   | Error correction level 0...3
 --style   -s   | qrcode style, values: "round", "pointed", "sharp", "square", "circle" or "dot"
 --finder  -f   | finder pattern style, values: "round", "pointed", "sharp", "square", "octagon" "circle" or "dot"
 --logo    -l   | path to image to embed on qrcode
 --size         | Size in pixels, valid when the output is image
 --svg          | Output to svg
 --output  -o   | Output to png
```

## Installation

### Homebrew

```bash
brew install carlosqsilva/brew/vqrcode
```

### Install from source

#### 0) Install [vlang](https://vlang.io), and add to your `path`

#### 1) install dependencies,

the following dependencies are required to output in png:

```
brew install librsvg cairo              // MacOs homebrew
apt install librsvg2-dev libcairo2-dev  // linux package manager
```

#### 2) clone repo

```bash
git clone https://github.com/carlosqsilva/vqrcode.git
```

#### 3) change dir to `vqrcode`

```bash
cd vqrcode/
```

#### 4) build program

```bash
v -cc gcc \
-cflags "$(pkg-config --cflags librsvg-2.0 cairo)" \
-ldflags "$(pkg-config --libs librsvg-2.0 cairo)" \
-prod vqrcode.v
```

After that you will get a ready-made binary file in the root directory of the project.
