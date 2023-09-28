#!/usr/bin/python3

import os
from sqlite3 import enable_shared_cache
import sys
import subprocess
import json
import datetime
import pprint


#############################################################################################################################################################################################################################################################################################################################

# Some prework and variable pre-assignments.

#############################################################################################################################################################################################################################################################################################################################
current_date=datetime.datetime.now()
currdate=current_date.strftime("%Y-%m-%d")
currdate_split=currdate.split('-')
tfvars=sys.argv[1]

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
subscription=top['common_info']['active_subscription']
location=top['common_info']['location']
location_code=top['common_info']['location_code']
placement_code=top['common_info']['placement_code']
os_code=top['common_info']['os_code']
application_name=top['common_info']['application_name']
app_name_short=top['common_info']['app_name_short']
env_short=top['common_info']['env_short']
env_code=top['common_info']['env_code']
tenant=top['common_info']['tenant']
environment=top['common_info']['environment']
rg_prefix=top['common_info']['rg_prefix']
agw_prefix=top['app_gateway_info']['prefix']
hyb_info=top['hyb_info']
utl_info=top['utl_info']
load_balancer=top['load_balancer']
lb_prefix=load_balancer['prefix']


#############################################################################################################################################################################################################################################################################################################################
# Active Resource Name Variables
rg_name="{0}-{1}-{2}-{3}-001".format(tenant, rg_prefix, application_name, environment)

#############################################################################################################################################################################################################################################################################################################################

os.system('az account set -s ' + subscription) # Set the active subscription

def storage_accounts():
    index=0
    count=0
    storage_names={}
    saf=False
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
    if "diag" not in storage_name:
        print(storage_name)

storage_accounts()
json_file.close()
