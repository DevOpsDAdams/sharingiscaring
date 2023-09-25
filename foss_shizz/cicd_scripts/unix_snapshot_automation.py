#!/usr/local/bin/python3

from os import statvfs_result
import sys
import re
import boto3
from time import sleep
import datetime

######################################################################################################################################################
###################################################################### STS INFO ######################################################################
######################################################################################################################################################

roleArn = 'arn:aws:iam::<<account_id>>:role/Role-Name'
sts = boto3.client('sts')
accountName = re.findall('.*-(.*)', roleArn)
for aN in accountName:
    aN = aN
roleSessionName = aN + 'AdminRole'
assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
access_key = assumeRole['Credentials']['AccessKeyId']
secret_key = assumeRole['Credentials']['SecretAccessKey']
session_token = assumeRole['Credentials']['SessionToken']


################################################################################################################################################################################
#################################################################### Variable Definitions ######################################################################################
################################################################################################################################################################################
print("Building Variables")
count = 0
countx = 0
localtime = datetime.datetime.now()
locdate = localtime.strftime("%d-%m-%y")
sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
AccountInfo = sts.get_caller_identity()
snapshotPrefix = '<<some_prefix>>'
sourceInstance = '<<source_instance_id>>' # this can also be done programmatically. This is for testing purposes only
targetInstance = '<<target_instance_id>>' # this can also be done programmatically. This is for testing purposes only
ti_info = ec2.describe_instances(InstanceIds=[targetInstance])
for tii in ti_info['Reservations']:
    dii = tii['Instances'][0]
    availability_Zone = dii['Placement']['AvailabilityZone']
AcctIds = ['<<acct_id_1>>', '<<acct_id_2>>']
KMSKeyId = '<<dest_kms_key_id>>'
NPKMSKeyId = '<<source_kms_key_id>>'
volumesdict = {"vol-1":"/dev/sdb", "vol-2":"/dev/sdc"}
targetvolumes = []
snapshotids = {}
newvolumeids = {}
tags = {
'Key': 'Name',
'Value': 'SnapshotVolumeTag'
}

################################################################################################################################################################################
######################################################################### Discover Volumes In Instance ############################################################
################################################################################################################################################################################
'''
print("Discovering Volumes Within Instance " + sourceInstance)
describe_instances=ec2.describe_instances(InstanceIds=[sourceInstance])
for di in describe_instances['Reservations']:
    dii = di['Instances']
    for volumes in dii[0]['BlockDeviceMappings'][1:]:
        count = count + 1
        volumeid = volumes['Ebs']['VolumeId']
        volume_name = volumes['DeviceName']
        volumesdict.update({volumeid: volume_name})
        tags.update({'Value': 'UnixAutomationSnapshot0' + str(count)})
'''
for vd in volumesdict:
    create_snapshot = ec2.create_snapshot(Description='Automated Snapshot and Volume for Unix Project', VolumeId=vd)
    new_snapshot_id = create_snapshot['SnapshotId']
    snapshotids.update({new_snapshot_id: volumesdict[vd]})

print("Snapshots Created. Waiting for [Completed] Status.")

################################################################################################################################################################################
######################################################################### Wait for the Snapshots To Become Available and Create Volumes ##############################################
################################################################################################################################################################################

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

print("Snapshots Completed. Creating Volume")

################################################################################################################################################################################
######################################################################### Create Volumes From Snapshots ##########################################################
################################################################################################################################################################################

for sid in snapshotids:
    create_volume = ec2.create_volume(AvailabilityZone = availability_Zone, Encrypted=True, SnapshotId=sid)
    newvolumeId = create_volume['VolumeId']
    print("Volume with ID " + newvolumeId + " created from Snapshot " + sid + " with Device Name " + snapshotids[sid])
    newvolumeids.update({newvolumeId: snapshotids[sid]})

print("Volumes Created. Waiting For [Available] Status.")

################################################################################################################################################################################
######################################################################### Wait for the Volumes To Become Available and Stop Instance ##############################################
################################################################################################################################################################################

for nvid in newvolumeids:
    new_describe_volumes = ec2.describe_volumes(VolumeIds=[nvid])
    for ndvv in new_describe_volumes['Volumes']:
        new_volume_state = ndvv['State']
        while new_volume_state.lower() != "available":
            print("Current Volume State for " + nvid + " is [" + new_volume_state + "]. Waiting for volume to enter [Available].")
            sleep(10)
            new_describe_volumes = ec2.describe_volumes(VolumeIds=[nvid])
            for ndvv in new_describe_volumes['Volumes']:
                new_volume_state = ndvv['State']
        print("Volume " + nvid + " is [Available].")

print("Volumes Ready. Stopping Target Instance " + targetInstance)

################################################################################################################################################################################
######################################################################### Stop Instance To Detatch Volumes #######################################################
################################################################################################################################################################################


print("Discovering Volumes Within Instance " + targetInstance)
describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
for di in describe_instances['Reservations']:
    dii = di['Instances']
    for volumes in dii[0]['BlockDeviceMappings'][1:]:
        volumeid = volumes['Ebs']['VolumeId']
        volume_name = volumes['DeviceName']
        for vol_name in volumesdict:
            if volume_name == volumesdict[vol_name]:
                print("Found " + volumesdict[vol_name] + ". Detatching.")
                targetvolumes.append(volumeid)
            else:
                pass

stop_instance = ec2.stop_instances(InstanceIds=[targetInstance])
describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
for di in describe_instances['Reservations']:
    dii = di['Instances']
    instance_state = dii[0]['State']['Name']

while instance_state != "stopped":
    print("Waiting for instantce to enter [Stopped] state.")
    sleep(5)
    describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
    for di in describe_instances['Reservations']:
        dii = di['Instances']
        instance_state = dii[0]['State']['Name']
print('Instance Stopped. Detatching Volumes.')


################################################################################################################################################################################
######################################################################### Detatch Volumes ########################################################################
################################################################################################################################################################################

for tv in targetvolumes:
    print("Detaching Volume " + tv)
    detach_volume = ec2.detach_volume(VolumeId=tv)
    describe_volumes = ec2.describe_volumes(VolumeIds=[tv])
    for dvv in describe_volumes['Volumes']:
        volume_state = dvv['State']
        while volume_state.lower() != "available":
            print("Awaiting State to Enter Available.")
            sleep(10)
            describe_volumes = ec2.describe_volumes(VolumeIds=[tv])
            for dvv in describe_volumes['Volumes']:
                volume_state = dvv['State']
    print("Volume with ID " + tv + " detached.")
print("All Volumes Detached. Creating Snapshots from Detached Volumes.")

################################################################################################################################################################################
######################################################################### Create Snapshots From Old Volumes ########################################################################
################################################################################################################################################################################

for tv in targetvolumes:
    create_snapshot = ec2.create_snapshot(Description='Snapshot of Detatched ' + targetInstance + '. Delete After 7 Days.', VolumeId=tv)
    snapshot_id = create_snapshot['SnapshotId']
    describe_snapshots = ec2.describe_snapshots(SnapshotIds=[snapshot_id])
    for dss in describe_snapshots['Snapshots']:
        state = dss['State']
        while state.lower() != "completed":
            print("Awaiting Snapshot To Complete")
            sleep(10)
            describe_snapshots = ec2.describe_snapshots(SnapshotIds=[snapshot_id])
            for dss in describe_snapshots['Snapshots']:
                state = dss['State']
        print("Snapshot Complete. Checking Next Snapshot.")

print("Snapshots Completed. Attaching New Volumes.")

################################################################################################################################################################################
######################################################################### Attach Volumes Created From Source Machine Snapshots #################################################
################################################################################################################################################################################

for nvid in newvolumeids:
    attach_volume = ec2.attach_volume(Device=newvolumeids[nvid], InstanceId=targetInstance, VolumeId=nvid)
    describe_volumes = ec2.describe_volumes(VolumeIds=[nvid])
    for dvv in describe_volumes['Volumes']:
        volume_state = dvv['State']
        while volume_state.lower() != "in-use":
            print("Awaiting State to Enter In Use.")
            sleep(10)
            describe_volumes = ec2.describe_volumes(VolumeIds=[nvid])
            for dvv in describe_volumes['Volumes']:
                volume_state = dvv['State']
    print("Volume with ID " + nvid + " is now attached to " + targetInstance + ".")
print("All Volumes Now Attached. Starting Instance.")

################################################################################################################################################################################
######################################################################### Start Target Instance ########################################################################
################################################################################################################################################################################

start_instance = ec2.start_instances(InstanceIds=[targetInstance])
describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
for di in describe_instances['Reservations']:
    dii = di['Instances']
    instance_state = dii[0]['State']['Name']

while instance_state != "running":
    print("Waiting for instantce to enter [Running] state.")
    sleep(5)
    describe_instances=ec2.describe_instances(InstanceIds=[targetInstance])
    for di in describe_instances['Reservations']:
        dii = di['Instances']
        instance_state = dii[0]['State']['Name']
print('Instance Up and Running. Cleaning up Snapshots from Source Instance ' + sourceInstance)

################################################################################################################################################################################
######################################################################### Cleanup Snapshots ########################################################################
################################################################################################################################################################################

for sid in snapshotids:
    print("Cleaning up Snapshot with ID " + sid)
    snapshot_delete = ec2.delete_snapshot(SnapshotId=sid)
    print("Snapshot Deleted. Removing Next Snapshot.")
print("All Snapshots from Source Machine Removed. Cleaning up Old Volumes")

################################################################################################################################################################################
######################################################################### Cleanup Old Target Volumes ########################################################################
################################################################################################################################################################################

for tv in targetvolumes:
    print("Cleaning Up Volume with Name " + tv)
    delete_volume = ec2.delete_volume(VolumeId=tv)
    print("Volume " + tv + " Deleted.")
print("All Detatched Volumes Deleted. Exiting")
