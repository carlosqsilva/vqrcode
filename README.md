# vqrcode
CLI for creating QR codes

### Examples

<p float="left">
<img style="display:inline-block" width="240" src="https://user-images.githubusercontent.com/19891059/182940291-d46021ab-1528-4790-9aca-52d6f27e3882.svg" />
<img style="display:inline-block" width="240" src="https://user-images.githubusercontent.com/19891059/182940537-cb8403cf-81da-4db3-92dd-928ae7bd7973.svg" />
<img style="display:inline-block" width="240" src="https://user-images.githubusercontent.com/19891059/182940760-9420be6e-eddf-4cf6-8371-57fc6940b3c6.svg" />
</p>

### Usage

 ```bash
 vqrcode 'Testing'                     # print qrcode as ascii to console
 vqrcode 'Testing' --svg               # print qrcode in svg 
 vqrcode 'Testing' --svg > qrcode.svg  # output qrcode to file
 vqrcode 'Testing' --svg | pbcopy      # output qrcode to clipboard
 ```
flags:
```
 --ecl     | Error correction level 0...3
 --style   | "round", "square" or "dot" (only valid with svg flag)
 --size    | Size in pixels (only valid with svg flag)
 --svg     | Output in svg
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
