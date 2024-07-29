#!/usr/bin/env python3

import sys
import subprocess

power_lut = "../mods/vehicles/dadams_drift_demo_camaro/data/power.lut" # Path to the power Look Up Table file
pl_bank={}
pl=open(power_lut, 'r') # Read data from the Look Up Table file

pl_lines = pl.readlines() # Read all lines from the Look Up Table file

for pll in pl_lines:
    pll=pll.strip()
    pll = pll.replace('|', ':')
    pl_bank[pll.split(':')[0]] = pll.split(':')[1] # Create a dictionary with the data from the Look Up Table file

for plb in pl_bank:
    fwhp
