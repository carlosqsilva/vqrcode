# vqrcode

CLI for creating QR codes

## Examples

<p float="left">
<img style="display:inline-block" width="240" src="https://github.com/user-attachments/assets/8e6585db-9cec-4b2c-b9fc-8a86c7d7622a" />
<img style="display:inline-block" width="240" src="https://github.com/user-attachments/assets/f51470ef-9e46-4450-9b1e-969286154acc" />
<img style="display:inline-block" width="240" src="https://github.com/user-attachments/assets/6cd69ca3-8558-46e2-8c59-621b6d952073" />
<img style="display:inline-block" width="240" src="https://github.com/user-attachments/assets/eb84cdb5-988a-457c-bb5c-1325306b9cec" />
<img style="display:inline-block" width="240" src="https://github.com/user-attachments/assets/8df884fe-2cb4-4852-9cf8-6afb837acccc" />
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
just build
```

# or

```bash
v -cc gcc \
-cflags "$(pkg-config --cflags librsvg-2.0 cairo)" \
-ldflags "$(pkg-config --libs librsvg-2.0 cairo)" \
-prod vqrcode.v
```

After that you will get a ready-made binary file in the root directory of the project.
