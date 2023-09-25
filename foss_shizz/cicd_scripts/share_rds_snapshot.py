#!/usr/bin/env python3

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
localtime = datetime.datetime.now()
locdate = localtime.strftime("%d-%m-%y")
sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
AccountInfo = sts.get_caller_identity()
print(AccountInfo)
proddBIdentifier = '<<Identifier>>'
ProdSnapshotTarget = 'automatedsnapshotprd'
DevTarget = "rds-ora-" + proddBIdentifier + "-unencrypted-" + locdate
AcctIds = ['<<acct_id_1>>', '<<acct_id_2>>']
KMSKeyId = 'arn:aws:kms:us-east-1:<<account_id>>:key/<<key_id>>'
NPKMSKeyId = 'arn:aws:kms:us-east-1:<<account_id>>:key/<<key_id>>'
SnapshotIdentifier = "rds-ora-" + proddBIdentifier + "-encrypted-" + locdate
DevDBInstance = "InstanceIdentifier"
DevDBInstanceCopy = DevDBInstance + "-destroy"
tags = {
    'Key': 'Automation',
    'Value': 'Ansible',
    'Key': 'account-id',
    'Value': '11111111'
}
print("Entering Production Environment")

################################################################################################################################################################################
###################################################################### Prod Work Part 1 ########################################################################################
################################################################################################################################################################################

rds = boto3.client('rds', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
try:
    print("Deleting old RDS Snapshot Copy")
    delete_snapshot = rds.delete_db_snapshot(DBSnapshotIdentifier=SnapshotIdentifier)
    print("Deleted")
except:
    pass
print("Creating Manual Snapshot of the Instance with Identifier " + proddBIdentifier)
create_snapshot = rds.create_db_snapshot(DBSnapshotIdentifier = ProdSnapshotTarget, DBInstanceIdentifier = proddBIdentifier, Tags = [tags])
print("The Snapshot Identifier for " + aN + " is " + ProdSnapshotTarget)
describe_snapshot = rds.describe_db_snapshots(DBSnapshotIdentifier=ProdSnapshotTarget)

for ds in describe_snapshot['DBSnapshots']:
    status = ds['Status']

while status != "available":
    print("Waiting for snapshot to enter [Available] state")
    describe_snapshot = rds.describe_db_snapshots(DBSnapshotIdentifier=ProdSnapshotTarget)
    for ds in describe_snapshot['DBSnapshots']:
        status = ds['Status']
    sleep(5)

print("Snapshot Now Available")
print("Copying Snapshot with new KMS Key for Sharing")
copy_snapshot = rds.copy_db_snapshot(SourceDBSnapshotIdentifier=ProdSnapshotTarget, TargetDBSnapshotIdentifier=SnapshotIdentifier, KmsKeyId=KMSKeyId, Tags=[tags])
print(copy_snapshot)
describe_copy_snapshot = rds.describe_db_snapshots(DBSnapshotIdentifier=SnapshotIdentifier)
print(describe_copy_snapshot)

for dcs in describe_copy_snapshot['DBSnapshots']:
    status = dcs['Status']
    snapshot_arn = dcs['DBSnapshotArn']

while status != "available":
    print("Waiting for Copied Snapshot to enter [Available] state")
    describe_copy_snapshot = rds.describe_db_snapshots(DBSnapshotIdentifier=SnapshotIdentifier)
    for dcs in describe_copy_snapshot['DBSnapshots']:
        status = dcs['Status']
        snapshot_arn = dcs['DBSnapshotArn']
    sleep(5)
print("Snapshot ARN is " + snapshot_arn)
print("Copied Snapshot Now Available. Deleting originally created Manual Snapshot.")
delete_snapshot = rds.delete_db_snapshot(DBSnapshotIdentifier=ProdSnapshotTarget)
print("Snapshot Deleted")
sleep(.5)
print("Sharing Copied Snapshot")
share_snapshot = rds.modify_db_snapshot_attribute(DBSnapshotIdentifier=SnapshotIdentifier, AttributeName='restore', ValuesToAdd=AcctIds)
print("Snapshot Shared. Switching to Dev Environment.")
####################################################################################################################################################################################
######################################################################### Dev Work #################################################################################################
####################################################################################################################################################################################
roleArn = 'arn:aws:iam::<<account_id>>:role/Role-Name'
accountName = re.findall('.*-(.*)', roleArn)
for aN in accountName:
    aN = aN
roleSessionName = aN + 'AdminRole'
sts = boto3.client('sts')
assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
access_key = assumeRole['Credentials']['AccessKeyId']
secret_key = assumeRole['Credentials']['SecretAccessKey']
session_token = assumeRole['Credentials']['SessionToken']
sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
AccountInfo = sts.get_caller_identity()
print(AccountInfo)
rds = boto3.client('rds', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
try:
    print("Deleting old RDS Snapshot Copy")
    delete_snapshot = rds.delete_db_snapshot(DBSnapshotIdentifier=DevTarget)
    print("Deleted")
except:
    pass
dev_copy_snapshot = rds.copy_db_snapshot(SourceDBSnapshotIdentifier=snapshot_arn, TargetDBSnapshotIdentifier=DevTarget, KmsKeyId = NPKMSKeyId, Tags=[tags])
describe_dev_copy_snapshot = rds.describe_db_snapshots(DBSnapshotIdentifier=DevTarget)
print(describe_dev_copy_snapshot)

for ddcs in describe_dev_copy_snapshot['DBSnapshots']:
    status = ddcs['Status']
    print("Status is " + status)

while status != "available":
    print("Waiting for Copied Snapshot to enter [Available] state")
    describe_dev_copy_snapshot = rds.describe_db_snapshots(DBSnapshotIdentifier=DevTarget)
    for ddcs in describe_dev_copy_snapshot['DBSnapshots']:
        status = ddcs['Status']
        print("Status is " + status)
    sleep(5)

print("Modifying DB Snapshot to allow visibility")

mod_snapshot = rds.modify_db_snapshot_attribute(DBSnapshotIdentifier=DevTarget, AttributeName='restore', ValuesToAdd=AcctIds)

print("Unencrypted Snapshot Created. Deleting Manual Snapshot in Production.")
print("Switching to Production Environment")
#########################################################################################################################################################################################
######################################################################### Back To Prod  #################################################################################################
#########################################################################################################################################################################################
roleArn = 'arn:aws:iam::<<account_id>>:role/Role-Name'
accountName = re.findall('.*-(.*)', roleArn)
for aN in accountName:
    aN = aN
roleSessionName = aN + 'AdminRole'
sts = boto3.client('sts')
assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
access_key = assumeRole['Credentials']['AccessKeyId']
secret_key = assumeRole['Credentials']['SecretAccessKey']
session_token = assumeRole['Credentials']['SessionToken']
sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
AccountInfo = sts.get_caller_identity()
rds = boto3.client('rds', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
print(SnapshotIdentifier)
delete_snapshot = rds.delete_db_snapshot(DBSnapshotIdentifier=SnapshotIdentifier)
print("Switching back to Dev.")

########################################################################################################################################################################################
######################################################################### Back To Dev  #################################################################################################
########################################################################################################################################################################################
roleArn = 'arn:aws:iam::<<account_id>>:role/Role-Name'
accountName = re.findall('.*-(.*)', roleArn)
for aN in accountName:
    aN = aN
roleSessionName = aN + 'AdminRole'
sts = boto3.client('sts')
assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
access_key = assumeRole['Credentials']['AccessKeyId']
secret_key = assumeRole['Credentials']['SecretAccessKey']
session_token = assumeRole['Credentials']['SessionToken']
sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
AccountInfo = sts.get_caller_identity()
print(AccountInfo)
rds = boto3.client('rds', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
modify_db_instance = rds.modify_db_instance(DBInstanceIdentifier=DevDBInstance, ApplyImmediately=True, NewDBInstanceIdentifier=DevDBInstanceCopy)
sleep(180)
describe_db_instance = rds.describe_db_instances(DBInstanceIdentifier=DevDBInstanceCopy)
for ddi in describe_db_instance['DBInstances']:
    db_status = ddi['DBInstanceStatus']

while db_status != "available":
    print("Waiting for Database Instance to enter [Available] state")
    describe_db_instance = rds.describe_db_instances(DBInstanceIdentifier=DevDBInstanceCopy)
    for ddi in describe_db_instance['DBInstances']:
        db_status = ddi['DBInstanceStatus']
    sleep(5)

print("Database Now Available. Creating New Database from Snapshot Restore.")
restore_db_instance = rds.restore_db_instance_from_db_snapshot(DBInstanceIdentifier=DevDBInstance, DBSnapshotIdentifier=DevTarget, PubliclyAccessible=False)

describe_new_db_instance = rds.describe_db_instances(DBInstanceIdentifier=DevDBInstance)
for dndi in describe_db_instance['DBInstances']:
    new_db_status = dndi['DBInstanceStatus']

while new_db_status != "available":
    print("Waiting for Database Instance to enter [Available] state")
    describe_new_db_instance = rds.describe_db_instances(DBInstanceIdentifier=DevDBInstance)
    for dndi in describe_new_db_instance['DBInstances']:
        new_db_status = dndi['DBInstanceStatus']
    sleep(5)

print("New Instance Up and Running. Deleting Previous Instance " + DevDBInstanceCopy)
delete_instance = rds.delete_db_instance(DBInstanceIdentifier=DevDBInstanceCopy, SkipFinalSnapshot=True, DeleteAutomatedBackups=True)
print(DevDBInstanceCopy + " and all associated snapshots deleted")
