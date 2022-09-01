# vqrcode
CLI for creating QR codes

### Examples

<p float="left">
<img style="display:inline-block" width="200" src="https://user-images.githubusercontent.com/19891059/187951397-b1c8d8ae-d4e6-4a44-9103-2302f7a7b83a.svg" />
<img style="display:inline-block" width="200" src="https://user-images.githubusercontent.com/19891059/187952654-ba9a189d-ab12-4165-a028-b459cfb6725e.svg" />
<img style="display:inline-block" width="200" src="https://user-images.githubusercontent.com/19891059/187952782-95764f2f-daa6-48df-9635-1d4bd9341c17.svg" />
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

### Installation

Installation script coming soon!

### Building from source

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
