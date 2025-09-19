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

echo 'hello' | vqrcode                                  # print qrcode as ascii to console
echo 'hello' | vqrcode --svg -s "pointed"               # print qrcode in svg, with "pointed" style
echo 'hello' | vqrcode --svg > qrcode.svg               # output qrcode to file
echo 'hello' | vqrcode -o qrcode.png                    # output qrcode to png file (only support png)
echo 'hello' | vqrcode --svg | pbcopy                   # output qrcode to clipboard
echo 'hello' | vqrcode --svg -l ./logo.png | pbcopy     # output qrcode with custom logo to clipboard
echo 'hello' | vqrcode -l ./logo.png -o ./qrcode.png    # output qrcode with custom logo to file

vqrcode --sensitive -o secure.png                       # prompt for sensitive input, output to PNG file
vqrcode --sensitive --svg > secure.svg                  # prompt for sensitive input, output to SVG file
vqrcode --sensitive --display-anyway                    # prompt for sensitive input, display QR on screen
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
 --sensitive    | Read input without echo for sensitive data
 --display-anyway | Allow displaying sensitive QR codes on screen
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

For Windows cross-compilation from Linux, install MinGW:

```bash
sudo apt install -y gcc-mingw-w64  # Debian/Ubuntu
```

**Note**: PNG output is not supported when cross-compiling for Windows. Use ASCII or SVG output instead.

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

or

```bash
v -cc gcc \
-cflags "$(pkg-config --cflags librsvg-2.0 cairo)" \
-ldflags "$(pkg-config --libs librsvg-2.0 cairo)" \
-prod vqrcode.v
```

#### Windows Cross-Compilation (from Linux)

To build a Windows executable from Linux:

```bash
just build-windows
```

or

```bash
v -os windows -prod -o vqrcode.exe .
```

After that you will get a ready-made binary file in the root directory of the project.
