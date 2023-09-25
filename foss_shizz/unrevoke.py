#!/usr/local/bin/env python3


import subprocess
import os
import sys
import platform

user = 'my.username'
sudoer_entry = user + "  ALL=(ALL) NOPASSWD: ALL"
admin_group = "admin"
grouplist = []
filename = "/etc/sudoers"

# Check if running as root
def checks_and_balances(user, operating_system):
    whoami = os.environ.get(user)
    if whoami != "root":
        print("You must run this script as root. Exiting.")
        sys.exit(1)
    os_check = platform.system()
    if os_check != operating_system:
        print("This script currently only to be used on MacOS systems. Exiting.")
        sys.exit(1)
    group_stuff()


def group_stuff():
    groups = subprocess.Popen('for x in $(groups ' + user + '); do echo $x; done', shell=True, stdout=subprocess.PIPE)
    for g in groups.stdout:
        g = g.decode()
        g = g.rstrip()
        grouplist.append(g)
    if admin_group not in grouplist:
        print("Updating admin permissions")
        os.system("dscl . -append /Groups/" + admin_group + " GroupMembership " + user)
    else:
        print(user + " is already a member of " + admin_group)
    sudoer_stuff()

def sudoer_stuff():
    sudo_flag = False
    with open(filename, 'r') as sudoers_file:
        sudoer = sudoers_file.readlines()
        for entry in sudoer:
            if entry.find(sudoer_entry) != -1:
                sudo_flag=True
    sudoers_file.close()
    print(sudo_flag)
    if sudo_flag == False:
        sudo_file = open(filename, 'a')
        sudo_file.write(sudoer_entry)
        sudo_file.close()
    elif sudo_flag == True:
        print("No need to update sudoers file. User already assigned sudo.")
    else:
        print("Weird. This isn't supposed to happen.")
        sys.exit(1)

checks_and_balances('USER', 'Darwin')
