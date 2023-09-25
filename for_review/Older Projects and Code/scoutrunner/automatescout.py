#!/bin/env python3

import sys
import re

envs = {
    "DEV": 0123456789,
    "POC": 0123456789,
    "QA": 0123456789,
    "CORP": 0123456789,
    "STAGING": 0123456789,
    "SECURITY": 0123456789,
    "HUB": 0123456789,
    "PROD": 0123456789
}

for e in envs:
    print('ansible-playbook scoutrunner.yml -vvv --extra-vars "env=' + e + ' scout_id=' + str(envs[e]) + '"')
