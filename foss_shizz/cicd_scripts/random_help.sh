#!/bin/bash

cmd="/bin/ls"
(crontab -l 2>/dev/null; echo "00 02 * * * ${cmd}") | crontab -
