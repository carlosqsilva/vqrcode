# vqrcode
CLI for creating QR codes

### Examples

<p float="left">
<img style="display:inline-block" width="240" src="https://user-images.githubusercontent.com/19891059/187804333-70f7359b-b5fc-4e87-84c1-b4ab637c94f1.svg" />
<img style="display:inline-block" width="240" src="https://user-images.githubusercontent.com/19891059/187804444-869159fa-feb5-4613-8787-9263e5a51ac8.svg" />
<img style="display:inline-block" width="240" src="https://user-images.githubusercontent.com/19891059/187804518-37ee1924-2673-4824-b9b0-9e4ef45c122e.svg" />
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
