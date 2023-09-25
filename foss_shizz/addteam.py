#!/usr/bin/env python3

import os
import sys
import subprocess

# A shitty script I put together to automate adding SysAdmins to Linux Systems
# with specified user IDs . . .because old people think this is important.

unix_team = {
  "Old Dude": "-u 1004 odude",
  "NotYoung Dude": "-u 1006 nydude",
  "Ancient Chick": "-u 1001 achick",
  "Some Grandma": "-u 1002 sgrandma",
  "Grandpa Time": "-u 1003 gtime"
}


print("Adding Unix Team")

for ut in unix_team:
    print("Adding User " + ut)
    os.system('useradd -G admins -c "' + ut + '" ' + unix_team[ut])
