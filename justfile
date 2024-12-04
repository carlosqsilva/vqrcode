# Get pkg-config flags
CFLAGS := `pkg-config --cflags librsvg-2.0 cairo`
LDFLAGS := `pkg-config --libs librsvg-2.0 cairo`

# Run the project with optional arguments
run *ARGS:
	v -cflags "{{CFLAGS}}" -ldflags "{{LDFLAGS}}" -cc gcc run . {{ARGS}}

# Build the project
build:
	v -cflags "{{CFLAGS}}" -ldflags "{{LDFLAGS}}" -cc gcc -prod -o vqrcode .

# List available recipes
help:
	@just --list
