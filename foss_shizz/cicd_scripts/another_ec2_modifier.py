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

helper = '''Usage: another_ec2_modifier.py <<instance_id>> <<instance_size>>

Note:
     For multiple instances, separate instance IDs with a comma and wrap quotes around string. See Examples below.

Examples:

Individual Instance Resize: another_ec2_modifier.py i-abc123xyz987def c5.xlarge
Multiple Instances Resize: another_ec2_modifier.py "i-0e6d177d68e833792, i-060905282cab22435" c5.xlarge

'''

################################################################################################################################################################################
#################################################################### Arguement Check ###########################################################################################
################################################################################################################################################################################

try:
    selection = sys.argv[1]
except:
    print("This script requires at least one argument. None Given.")
    print(helper)
    sys.exit(1)


################################################################################################################################################################################
#################################################################### Variable Definitions ######################################################################################
################################################################################################################################################################################
instance_size = sys.argv[2] # "c5.2xlarge"
instance_ids = sys.argv[1] # ["i-0e6d177d68e833792","i-060905282cab22435"]
instances = []
volumesdict = {}
snapshotids = {}

if "i-" not in instance_ids:
    print("First argument must be an valid Instance ID. Exiting.")
    print(sys.argv[1])
    sys.exit(1)


instance_list = instance_ids.split(',')
for il in instance_list:
    il = il.strip()
    instances.append(il)
    print(il)

print("Building Variables")



current_date = datetime.datetime.now()
currdate = current_date.strftime("%Y-%m-%d")
currdate_split = currdate.split('-')
count = 0

ec2 = boto3.client('ec2')
sts = boto3.client('sts')
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
