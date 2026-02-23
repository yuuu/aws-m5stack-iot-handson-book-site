# Makefile for M5Atom S3 ENV Sensor

SKETCH_DIR = .
PORT ?= /dev/tty.usbmodem101
BAUDRATE = 115200
PROFILE ?= atoms3-lite

# Arduino CLI command
ARDUINO_CLI = arduino-cli

.DEFAULT_GOAL := all

# Build the sketch
build:
	$(ARDUINO_CLI) compile $(SKETCH_DIR) --profile ${PROFILE}

# Upload to the device
upload:
	$(ARDUINO_CLI) upload $(SKETCH_DIR) -p $(PORT) --profile ${PROFILE}

# Open serial monitor
monitor:
	$(ARDUINO_CLI) monitor -p $(PORT) -c baudrate=$(BAUDRATE) --profile ${PROFILE}

# Build and upload
flash: build upload

# Build, upload and monitor
all: flash monitor

# List available ports
list-ports:
	$(ARDUINO_CLI) board list

# Show help
help:
	@echo "Available targets:"
	@echo "  build       - Compile the sketch"
	@echo "  upload      - Upload to the device (PORT=/dev/ttyACM0)"
	@echo "  monitor     - Open serial monitor"
	@echo "  flash       - Build and upload"
	@echo "  all         - Build, upload and monitor"
	@echo "  list-ports  - List available serial ports"
	@echo "  help        - Show this help message"
	@echo ""
	@echo "Usage examples:"
	@echo "  make build"
	@echo "  make upload PORT=/dev/ttyUSB0"
	@echo "  make flash"
	@echo "  make monitor"

.PHONY: build upload monitor flash clean list-ports help
