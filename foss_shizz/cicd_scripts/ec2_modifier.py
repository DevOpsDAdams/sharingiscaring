#!/usr/bin/env python3

import os
import sys
import re
import boto3
import subprocess
import time
from time import sleep
import datetime
import argparse

from botocore.vendored.six import StringIO



################################################################################################################################################################################
#################################################################### Variable Definitions ######################################################################################
################################################################################################################################################################################
print("Building Variables")

instance_size = sys.argv[1] # "c5.2xlarge"
instance_ids = sys.argv[2] # ["i-0e6d177d68e833792","i-060905282cab22435"]
instances = []
volumesdict = {}
snapshotids = {}
'''
parser = argparse.ArgumentParser(description='Accept Values for Instance Type/Size and Insance IDs.')
parser.add_argument('-s', action='store', dest='simple_value',
                    help='Store a simple value')
parser.add_argument('--sum', dest='accumulate', action='store_const',
                    const=sum, default=max,
                    help='sum the integers
'''
instance_list = instance_ids.split(',')
for il in instance_list:
    instances.append(il)
    print(il)

print(instance_list)

current_date = datetime.datetime.now()
currdate = current_date.strftime("%Y-%m-%d")
currdate_split = currdate.split('-')
try:
    selection = sys.argv[1]
except:
    print("No Selection Given. Exiting.")
    sys.exit(0)
roleArnDict = {'POC': 'arn:aws:iam::<<account_id_poc>>:role/Role-Name',
'Dev': 'arn:aws:iam::<<account_id_dev>>:role/Role-Name',
'Prod': 'arn:aws:iam::<<account_id_prod>>:role/Role-Name'}
region_list = ['us-east-1', 'us-east-2', 'us-west-1', 'ap-southeast-1']
if selection == 'POC':
    role = roleArnDict['POC']
elif selection == 'Dev':
    role = roleArnDict['Dev']
elif selection == 'Prod':
    role = roleArnDict['Prod']
elif selection == 'Workspaces':
    role = roleArnDict['Workspaces']
else:
    print("Invalid Selection Given. Defaulting to POC.")
    role = roleArnDict['POC']
roleArnList = [role]
count = 0

for rA in roleArnList:
    roleArn = rA
    print("Operating under Role ARN: " + roleArn)
    roleSessionName = 'AdminRole'
    sts = boto3.client('sts')
    assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
    access_key = assumeRole['Credentials']['AccessKeyId']
    secret_key = assumeRole['Credentials']['SecretAccessKey']
    session_token = assumeRole['Credentials']['SessionToken']
    accountName = re.findall('.*-(.*)', roleArn)
    for aN in accountName:
        aN = aN
        ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
        sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
        AccountInfo = sts.get_caller_identity()
        AccountID = AccountInfo['Account']

################################################################################################################################################################################
#################################################################### Stop Instances ######################################################################################
################################################################################################################################################################################

for targetInstance in instances:
    print("Stopping Instance " + targetInstance)
    stop_instance = ec2.stop_instances(InstanceIds=[targetInstance])
    describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
    for di in describe_instances['Reservations']:
        dii = di['Instances']
        instance_state = dii[0]['State']['Name']
    while instance_state != "stopped":
        print("Waiting for Instance " + targetInstance + " to enter [Stopped] state.")
        sleep(5)
        describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
        for di in describe_instances['Reservations']:
            dii = di['Instances']
            instance_state = dii[0]['State']['Name']
'''
print('Instances Stopped. Taking Snapshots from Instances.')

###############################################################################################################################################################################
################################################################### Create Snapshots from Volumes ############################################################################
###############################################################################################################################################################################
for targetInstance in instances:
    print("Discovering Volumes Within Instance " + targetInstance)
    describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
    for di in describe_instances['Reservations']:
        dii = di['Instances']
        for volumes in dii[0]['BlockDeviceMappings']:
            count = count + 1
            volumeid = volumes['Ebs']['VolumeId']
            volume_name = volumes['DeviceName']
            volumesdict.update({volumeid: volume_name})
            print("Taking Snapshots of Volumes in Instance " + targetInstance)
            create_snapshot = ec2.create_snapshot(Description=targetInstance + '-' + volume_name, VolumeId=volumeid)
            new_snapshot_id = create_snapshot['SnapshotId']
            snapshotids.update({new_snapshot_id: volume_name})

print("Snapshots Created. Waiting for [Completed] Status.")

for sid in snapshotids:
    describe_snapshots = ec2.describe_snapshots(SnapshotIds=[sid])
    for dss in describe_snapshots['Snapshots']:
        state = dss['State']
        while state.lower() != "completed":
            print("Status for " + sid + " is [" + state + "]. Awaiting Snapshot To Complete.")
            sleep(10)
            describe_snapshots = ec2.describe_snapshots(SnapshotIds=[sid])
            for dss in describe_snapshots['Snapshots']:
                state = dss['State']
    print("Snapshot Complete. Checking Next Snapshot.")

print("Snapshots Completed. Resizing Instances")


###############################################################################################################################################################################
################################################################### Resize Instances ######################################################################################
###############################################################################################################################################################################
'''
for targetInstance in instances:
    print("Resizing Instance " + targetInstance)
    modify_instance = ec2.modify_instance_attribute(InstanceId=targetInstance, Attribute='instanceType', Value=instance_size)
    describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
    for di in describe_instances['Reservations']:
        dii = di['Instances']
        instance_state = dii[0]['State']['Name']
        print(instance_state)
    while instance_state != "stopped":
        print("Waiting for instance " + targetInstance + " to enter [Stopped] state.")
        sleep(5)
        describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
        for di in describe_instances['Reservations']:
            dii = di['Instances']
            instance_state = dii[0]['State']['Name']
    print("Instances Ready to Start. Starting Instances.")

################################################################################################################################################################################
#################################################################### Start Instances ######################################################################################
################################################################################################################################################################################

for targetInstance in instances:
    start_instance = ec2.start_instances(InstanceIds=[targetInstance])
    describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
    for di in describe_instances['Reservations']:
        dii = di['Instances']
        instance_state = dii[0]['State']['Name']
    while instance_state != "running":
        print("Waiting for instance " + targetInstance + " to enter [Running] state.")
        sleep(5)
        describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
        for di in describe_instances['Reservations']:
            dii = di['Instances']
            instance_state = dii[0]['State']['Name']

print('Instance Up and Running. Sending Notifications and Exiting.')
