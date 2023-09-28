#!/usr/bin/env python3

import os
import sys
import subprocess
import datetime
import json


################################################################################
# Some prework and variable assignments.
current_date = datetime.datetime.now()
currdate = current_date.strftime("%Y-%m-%d")
currdate_split = currdate.split('-')
secret_key = False
secret_value = False
vault_name = False
user = False
sc = False
pass_map = {}

# Check if PWGEN is installed.
# If PWGEN is installed, continue into the Password portion
# If PWGEN is NOT installed, check the OSTYPE and install PWGEN accordingly
statcheck=subprocess.Popen('which pwgen 2>/dev/null', shell=True, stdout=subprocess.PIPE)
for sc in statcheck.stdout:
    sc = sc.decode().rstrip()
if sc:
    pass
else:
    unamecheck=subprocess.Popen('uname -a', shell=True, stdout=subprocess.PIPE)
    for uc in unamecheck.stdout:
        uc = uc.decode().rstrip()
    if ".el" in uc:
        print("sudo yum install pwgen -y 2>1>/dev/null")
    elif "Ubuntu" in uc:
        print("sudo apt install pwgen -y 2>1>/dev/null")
    elif "Darwin" in uc:
        print('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh) 2>1>/dev/null"; brew install pwgen 2>1>/dev/null' )

# Check to see if a secret key is passed. If not, set the variable as False
try:
    vault_name = sys.argv[1]
except:
    print("You must enter a Key Vault Name. Exiting.")
    sys.exit(1)

# Check to see if a secret key is passed. If not, set the variable as False
try:
    secret_key = sys.argv[2]
except:
    print("You must enter a secret key. Exiting.")
    sys.exit(1)




# Retrieve the secret value if it exists
secret=subprocess.Popen('az keyvault secret show -n ' + secret_key + ' --vault-name ' + vault_name + ' --query "value" --output tsv 2>/dev/null', shell=True, stdout=subprocess.PIPE)
secret_value = secret.communicate()[0].decode().rstrip()


# If the secret value exists, print it out for use in Terraform. Else, generate
# a new password and print that out instead.



if secret_key and secret_value:
    pass_map["Password"]=secret_value
    pm = json.dumps(pass_map)
    print(pm)
    # a = open('./admintext', 'rw+')
    # a.write(secret_value)
    # a.close()
    sys.exit(0)
else:
    newpass=subprocess.Popen('pwgen -nsyv 16 1 -r \\\'!', shell=True, stdout=subprocess.PIPE) # Defaults are pwgen -nsyv 16 1
    for np in newpass.stdout:
        np = np.decode().rstrip()
        pass_map["Password"]=np
        pm = json.dumps(pass_map)
        print(pm)
