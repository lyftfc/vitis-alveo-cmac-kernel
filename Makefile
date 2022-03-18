
BOARD ?= au50
PORT ?= 0

BOARD_PORT := $(BOARD)_$(PORT)
BUILD_DIR := build/$(BOARD_PORT)
IP_DIR := $(BUILD_DIR)/vivado_ip
BPS_WRAPPER := $(BUILD_DIR)/cmac_$(BOARD_PORT).v
KRNL_XML := $(BUILD_DIR)/kernel_$(BOARD_PORT).xml
XO_FILE := $(BUILD_DIR)/cmac_$(BOARD_PORT).xo

all: $(XO_FILE)

$(XO_FILE): $(BPS_WRAPPER)
	vivado -mode batch -source scripts/cmac_xopack.tcl -tclargs $(BOARD) $(PORT)

$(BPS_WRAPPER):
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(IP_DIR)
	@cp src/cmac_wrapper.v $(BPS_WRAPPER)
	@cp src/kernel.xml $(KRNL_XML)
	@sed -i 's/cmac_wrapper_TEMPLATE/cmac_$(BOARD_PORT)/g' $(BPS_WRAPPER)
	@sed -i 's/cmac_usplus_ID/cmac_usplus_$(PORT)/' $(BPS_WRAPPER)
	@sed -i 's/cmac_kernel_TEMPLATE/cmac_$(BOARD_PORT)/g' $(KRNL_XML)

clean:
	@rm -rf .Xil *.jou *.log

distclean: clean
	@rm -rf build/

.PHONY: all clean distclean
