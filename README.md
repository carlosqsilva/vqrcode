# vqrcode
CLI for creating QR codes

### Examples

<p float="left">
<img style="display:inline-block" width="200" src="https://user-images.githubusercontent.com/19891059/210896313-5d5941e9-6955-4f58-ab16-9114f4114c28.svg" />
<img style="display:inline-block" width="200" src="https://user-images.githubusercontent.com/19891059/210896391-e9da0b80-6e56-4620-8ffe-7f2fddbbe024.svg" />
<img style="display:inline-block" width="200" src="https://user-images.githubusercontent.com/19891059/210896490-e97456f4-51da-4e84-9042-176f84a11f5e.svg" />
</p>

### Usage

 ```bash
 vqrcode 'Testing'                                  # print qrcode as ascii to console
 vqrcode 'Testing' -s                               # print qrcode in svg
 vqrcode 'Testing' -o ./qrcode.png                  # output qrcode to png file (only support png)
 vqrcode 'Testing' -s > qrcode.svg                  # output qrcode to file
 vqrcode 'Testing' -s | pbcopy                      # output qrcode to clipboard
 vqrcode 'Testing' -s -l ./logo.png | pbcopy        # output qrcode with custom logo to clipboard
 vqrcode 'Testing' -l ./logo.png -o ./qrcode.png    # output qrcode with custom logo to file
 ```
flags:
```
 --ecl     -e   | Error correction level 0...3
 --style        | "round", "square" or "dot" (only svg support "round" and "dot" style)
 --logo    -l   | path to image to embed on qrcode
 --size         | Size in pixels
 --svg     -s   | Output in svg
 --output  -o   | Output in png
```

# Installation

## Homebrew

```bash
brew install carlosqsilva/brew/vqrcode
```

## Install from source

#### 0) Install [vlang](https://vlang.io), and add to your `path`
#### 1) clone repo
```bash
git clone https://github.com/carlosqsilva/vqrcode.git
```
#### 2) change dir to `vqrcode`
```bash
cd vqrcode/
```
#### 3) build program
```bash
v -prod vqrcode.v
```
After that you will get a ready-made binary file in the root directory of the project.
