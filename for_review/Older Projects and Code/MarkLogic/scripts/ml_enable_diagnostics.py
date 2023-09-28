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
agw_name="{0}-{1}-{2}-001".format(agw_prefix, application_name, env_short)
lb_name="{0}-{1}-{2}-001".format(lb_prefix, app_name_short.lower(), env_short)
vm_prefix="{0}{1}{2}{3}{4}".format(placement_code, location_code, env_code, os_code, app_name_short)
#############################################################################################################################################################################################################################################################################################################################

# Additional Variables

#############################################################################################################################################################################################################################################################################################################################
diag_nc="diagpolicy"
retention=14

#############################################################################################################################################################################################################################################################################################################################

# Let's Go To Work!

# To the right! Take it back now yall!

# Find the Storage Account use for Diagnostics and store this as a Global
# Variable

#############################################################################################################################################################################################################################################################################################################################
diag_sa_find=subprocess.Popen('az storage account list -g ' + rg_name + ' --query "[].name" --output tsv', shell=True, stdout=subprocess.PIPE)
for dsf in diag_sa_find.stdout:
    dsf=dsf.decode().rstrip()
    if "diag" in str(dsf):
        diag_sa=dsf


os.system('az account set -s ' + subscription) # Set the active subscription



#############################################################################################################################################################################################################################################################################################################################

# The app gateway has a simple AllMetrics Metric and a series of logs.

#############################################################################################################################################################################################################################################################################################################################


def app_gateway():
    agw_diag_name="{0}-{1}{2}-{3}-001".format(agw_prefix, app_name_short.lower(), env_short, diag_nc)     # Set Application Gateway Diagnostics
    agw_logs=[]
    agw_metrics='[{"category": "AllMetrics", "enabled": "true", "retentionPolicy": {"enabled":"true", "days":14}}]'     # The Only Option for Metrics. Can be pulled in with a simple "forced" JSON of "AllMetrics".
    agw_info=subprocess.Popen('az network application-gateway show -n ' + agw_name + ' -g ' + rg_name + ' --query "id" --output tsv', shell=True, stdout=subprocess.PIPE)     # Get the ID of the App Gateway
    for agi in agw_info.stdout:
        agi=agi.decode().rstrip()
        agw_id=agi # This is the ID for the App Gateway
    agw_log_categories=subprocess.Popen('az monitor diagnostic-settings categories list --resource ' + agw_id + ' --query "value | [?contains(categoryType, \`Logs\`)].name" --output tsv', shell=True, stdout=subprocess.PIPE) # Get the Logging Categories for the App Gatway
    for alc in agw_log_categories.stdout:
        alc=alc.decode().rstrip()
        agw_logs.append({"category": alc, "enabled": "true","retentionPolicy": {"enabled": "true","days": retention}}) # The pseudo JSON line built to handle our assignment of Diagnostic Settings
    agw_cat_json=json.dumps(agw_logs, indent=4) # Format the output into proper JSON
    os.system("az monitor diagnostic-settings create --resource " + agw_id + ' -n ' + agw_diag_name + ' --storage-account ' + diag_sa + ' --logs \'' + agw_cat_json + '\' --metrics \'' + agw_metrics + '\'')  # Apply the JSON and Create the Diagnostic Policy for the App Gateway

def virtual_machines():
    index=0
    count=0
    hyb_dict={}
    utl_dict={}
    vm_metrics='[{"category": "AllMetrics", "enabled": "true", "retentionPolicy": {"enabled":"true", "days":14}}]'
    for hi in hyb_info:
        count=count + 1
        unique_name=hyb_info[index]['unique_name']
        vm_name=vm_prefix + unique_name + '0' + str(count)
        hyb_finder=subprocess.Popen('az vm list -g ' + rg_name + ' --query "[?contains(name, \`' + vm_name +'\`)].id" --output tsv', shell=True, stdout=subprocess.PIPE)
        for hf in hyb_finder.stdout:
            hf=hf.decode().rstrip()
            hyb_dict[vm_name]=hf
    count=0
    for ui in utl_info:
        count=count + 1
        unique_name=utl_info[index]['unique_name']
        vm_name=vm_prefix + unique_name + '0' + str(count)
        utl_finder=subprocess.Popen('az vm list -g ' + rg_name + ' --query "[?contains(name, \`' + vm_name +'\`)].id" --output tsv', shell=True, stdout=subprocess.PIPE)
        for uf in utl_finder.stdout:
            uf=uf.decode().rstrip()
            utl_dict[vm_name]=uf
    count=0
    for hd in hyb_dict:
        count=count + 1
        unique_name=hyb_info[index]['unique_name']
        vm_diag_name="{0}-{1}{2}-{3}-00{4}".format(unique_name.lower(), app_name_short.lower(), env_short, diag_nc, count)
        name=hd
        id=hyb_dict[hd]
        os.system("az monitor diagnostic-settings create --resource " + id + ' -n ' + vm_diag_name + ' --storage-account ' + diag_sa + ' --metrics \'' + vm_metrics + '\'')
        print("\n")
    count=0
    print("\n\n")
    for ud in utl_dict:
        count=count + 1
        unique_name=utl_info[index]['unique_name']
        vm_diag_name="{0}-{1}{2}-{3}-00{4}".format(unique_name.lower(), app_name_short.lower(), env_short, diag_nc, count)
        name=ud
        id=utl_dict[ud]
        os.system("az monitor diagnostic-settings create --resource " + id + ' -n ' + vm_diag_name + ' --storage-account ' + diag_sa + ' --metrics \'' + vm_metrics + '\'')
        print("\n")

def vm_nics():
    nic_ids=[]
    nic_metrics='[{"category": "AllMetrics", "enabled": "true", "retentionPolicy": {"enabled":"true", "days":14}}]'
    nic_info=subprocess.Popen('az network nic list -g ' + rg_name + ' --query "[].id" --output tsv', shell=True, stdout=subprocess.PIPE)
    for ni in nic_info.stdout:
        count=1
        ni = ni.decode().rstrip()
        ids = ni
        nic_ids.append(ids)
        nic_name_info=subprocess.Popen('az network nic show --ids ' + ids + ' --query "name" --output tsv | sed -e "s/-.*//g"', shell=True, stdout=subprocess.PIPE)
        for nni in nic_name_info.stdout:
            nni = nni.decode().rstrip()
            vm_name = nni
            nic_diag_name="{0}-{1}{2}-{3}-00{4}".format(vm_name.lower(), app_name_short.lower(), env_short, diag_nc, count)
            os.system("az monitor diagnostic-settings create --resource " + ids + ' -n ' + nic_diag_name + ' --storage-account ' + diag_sa + ' --metrics \'' + nic_metrics + '\'')
            count = count+1

def storage_accounts():
    index=0
    count=0
    storage_ids=[]
    container_ids=[]
    sa_metrics='[{"category": "AllMetrics", "enabled": "true", "retentionPolicy": {"enabled":"true", "days":14}}]'
    sa_find=subprocess.Popen('az storage account list --resource-group ' + rg_name + ' --query "[].id" --output tsv', shell=True, stdout=subprocess.PIPE)
    for saf in sa_find.stdout:
        saf = saf.decode().rstrip()
        storage_ids.append(saf)
    for si in storage_ids:
        count = count + 1
        id = si
        storage_diag_name="{0}-{1}{2}-{3}-00{4}".format("st", app_name_short.lower(), env_short, diag_nc, count)
        os.system("az monitor diagnostic-settings create --resource " + id + ' -n ' + storage_diag_name + ' --storage-account ' + diag_sa + ' --metrics \'' + sa_metrics + '\'')

def key_vaults():
    index=0
    count=0
    kv_ids=[]
    kv_metrics='[{"category": "AllMetrics", "enabled": "true", "retentionPolicy": {"enabled":"true", "days":14}}]'
    kv_find=subprocess.Popen('az keyvault list --resource-group ' + rg_name + ' --query "[].id" --output tsv', shell=True, stdout=subprocess.PIPE)
    for kvf in kv_find.stdout:
        kvf = kvf.decode().rstrip()
        kv_ids.append(kvf)
    for kvi in kv_ids:
        count = count + 1
        id = kvi
        print(id)
        kv_diag_name="{0}-{1}{2}-{3}-00{4}".format("kv", app_name_short.lower(), env_short, diag_nc, count)
        os.system("az monitor diagnostic-settings create --resource " + id + ' -n ' + kv_diag_name + ' --storage-account ' + diag_sa + ' --metrics \'' + kv_metrics + '\'')

def load_balancer():
    lb_diag_name="{0}-{1}{2}-{3}-001".format("lb", app_name_short.lower(), env_short, diag_nc)     # Set Load Balancer Diagnostics Name
    lb_metrics='[{"category": "AllMetrics", "enabled": "true", "retentionPolicy": {"enabled":"true", "days":14}}]'     # The Only Option for Metrics. Can be pulled in with a simple "forced" JSON of "AllMetrics".
    lb_info=subprocess.Popen('az network lb show -n ' + lb_name + ' -g ' + rg_name + ' --query "id" --output tsv', shell=True, stdout=subprocess.PIPE)     # Get the ID of the Load Balancer
    for lbi in lb_info.stdout:
        lbi=lbi.decode().rstrip()
        lb_id=lbi # This is the ID for the Load Balancer
    os.system("az monitor diagnostic-settings create --resource " + lb_id + ' -n ' + lb_diag_name + ' --storage-account ' + diag_sa + '  --metrics \'' + lb_metrics + '\'')

#############################################################################################################################################################################################################################################################################################################################

# Let's start the fire . . .that just so happend to already be burnin since the
# world was turnin.

#############################################################################################################################################################################################################################################################################################################################
app_gateway()
load_balancer()
virtual_machines()
vm_nics()
storage_accounts()
key_vaults()


json_file.close()
