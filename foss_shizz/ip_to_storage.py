#!/usr/bin/python3

import os
import sys
import subprocess
import json
import datetime


#############################################################################################################################################################################################################################################################################################################################

# Some prework and variable pre-assignments.

#############################################################################################################################################################################################################################################################################################################################
current_date=datetime.datetime.now()
currdate=current_date.strftime("%Y-%m-%d")
currdate_split=currdate.split('-')
tfvars=sys.argv[1]
rg_name=sys.argv[2]
add_remove=sys.argv[3]
infra_resource_group_name=sys.argv[4]
infra_storage_account_name=sys.argv[5]
ip_address= subprocess.Popen("curl -s icanhazip.com", shell=True, stdout=subprocess.PIPE).stdout.read().decode().rstrip()

#############################################################################################################################################################################################################################################################################################################################

# Load Main JSON File

#############################################################################################################################################################################################################################################################################################################################
json_file=open(tfvars, 'r+')
data=json.load(json_file)

#############################################################################################################################################################################################################################################################################################################################

# Build Variables from JSON

#############################################################################################################################################################################################################################################################################################################################
top=data['json']
tags=top['tags']
subscription=top['common_info']['deployment_subscription']

#############################################################################################################################################################################################################################################################################################################################

os.system('az account set -s ' + subscription) # Set the active subscription

def add_remove_storage_accounts():
    index=0
    count=0
    storage_names={}
    saf=False
    os.system("az storage account network-rule " + add_remove + " --resource-group " + infra_resource_group_name + " --account-name " + infra_storage_account_name + " --ip-address " + str(ip_address))
    sa_find=subprocess.Popen('az storage account list --resource-group ' + rg_name + ' --query "[].name" --output tsv 2>/dev/null', shell=True, stdout=subprocess.PIPE)
    for saf in sa_find.stdout:
        saf = saf.decode().rstrip()
        if saf == False:
            storage_names["Name"]="emptyvoid"
            storage_name=json.dumps(storage_names)
            print(storage_name)
            sys.exit(0)
        storage_names["Name"]=saf
        storage_name=json.dumps(storage_names)
        os.system("az storage account network-rule " + add_remove + " --resource-group " + rg_name + " --account-name " + saf + " --ip-address " + str(ip_address))

add_remove_storage_accounts()
json_file.close()
