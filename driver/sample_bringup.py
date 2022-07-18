#!/usr/bin/python3

# %% Preparation
from time import sleep
import pynq
from cmac_pynq import *
# Path to your final XCLBIN container
BS_FILE = "vitis_design_with_cmac.xclbin"

# %% Select device
dev = pynq.Device.devices[0]
print("Device: ", dev.name)

# %% Download bitstream
print("Programming", BS_FILE, "...")
ol = pynq.Overlay(BS_FILE, device=dev)
print("Done.\nKernels:", end='\t')
for k in ol.ip_dict.keys(): print(k, end='\t')
print()

# %% Check CMAC connection
# "cmac" should be inst name given by vitis config "nk="
# The name should also be shown in ip_dict
cmac_inst = ol.cmac
# cmac_reg = ol.cmac.register_map
sleep(0.5)
print("Link detected:", cmac_inst.linkStatus())

# %% Attempt to restart link if not on
if not cmac_inst.linkStatus():
    print("Trying to activate link...")
    cmac_inst.disableTxRx()
    sleep(0.5)
    cmac_inst.enableTxRx()
    sleep(0.5)
    if cmac_inst.linkStatus(): print("Success.")
    else: print("Failed.")

# %% Script clean-up
ol.free()   # Hardware remains running

