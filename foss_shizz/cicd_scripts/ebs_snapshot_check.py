#!/usr/bin/env python3

import os
import sys
import re
import boto3
import subprocess
import time
import datetime

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
    days = 30
elif selection == 'Dev':
    role = roleArnDict['Dev']
    days = 30
elif selection == 'Prod':
    role = roleArnDict['Prod']
    days = 364
elif selection == 'Workspaces':
    role = roleArnDict['Workspaces']
    days = 30
else:
    print("Invalid Selection Given. Defaulting to POC.")
    role = roleArnDict['POC']
roleArnList = [role]
count = 0
countx = 0
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
    for rl in region_list:
        ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token, region_name=rl)
        sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token, region_name=rl)
        print("Entering Region " + rl)
        AccountInfo = sts.get_caller_identity()
        AccountID = AccountInfo['Account']
        csvout = open(aN.upper() + '_Deleted_Snapshots-' + rl + "_" + str(currdate) + '.csv', 'a')
        csvout.write('Account ID,Snapshot ID,Snapshot Created,Age (In Days),Description\n')
        describe_snapshots = ec2.describe_snapshots(OwnerIds = [AccountID])
        delete = True
        for ds in describe_snapshots['Snapshots']:
            try:
                for dst in ds['Tags']:
                    key = dst['Key']
                    value = dst['Value']
                    if key == "DeleteException":
                        delete = False
            except:
                pass
            starttime = ds['StartTime']
            starttime = starttime.strftime("%Y-%m-%d")
            snapshotId = ds['SnapshotId']
            description = ds['Description']
            owner = ds['OwnerId']
            starttime_split = starttime.split('-')
            try:
                start_date = datetime.datetime(year=int(starttime_split[0]), month=int(starttime_split[1]), day=int(starttime_split[2]))
                now_date = datetime.datetime(year=int(currdate_split[0]), month=int(currdate_split[1]), day=int(currdate_split[2]))
                date_delta = now_date - start_date
                days_old = date_delta.days
                if days_old > days and delete == True:
                    count = count + 1
                    days_old = str(days_old)
                    print("Deleting " + snapshotId + " in " + str(AccountID) + " as it is " + days_old + " days old.")
                    delete_snapshot = ec2.delete_snapshot(SnapshotId=snapshotId)
                    csvout.write(AccountID + "-" + aN + "," + snapshotId + "," + str(starttime) + "," + days_old + "," + description + "\n")
                elif delete == False:
                    countx = countx + 1
                else:
                    countx = countx + 1
                    pass
            except:
                pass
        csvout.close()
print(str(count) + " Snapshots Removed.")
print(str(countx) + " Snapshots were Skipped.")
