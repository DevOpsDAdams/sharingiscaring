#!/usr/bin/env python3

import sys
import os
import re
import boto3
from time import sleep
import datetime

current_date = datetime.datetime.now()
currdate = current_date.strftime("%Y-%m-%d")
currdate_split = currdate.split('-')

roleArnList = ['arn:aws:iam::<<account_id_prod>>:role/Role-Name',
'arn:aws:iam::<<account_id_nonprod>>:role/Role-Name',
'arn:aws:iam::<<account_id_workspace>>:role/Role-Name']
volume_type='gp2'
volume_size=20
IOPS=16000


prodkey = 'arn:aws:kms:us-east-1:<<account_id>>:key/<<key_id>>'
devkey = ''
workspaceskey = ''
volume_dict = {}
hostname_list = []

volume_list = ["vol-0183b292469f7c36d"
,"vol-01950fdada7c93d01"
,"vol-049ae5c213165e8ec"
,"vol-068927c1d1910a89b"
,"vol-0854f8b972e7f3693"
,"vol-08cd2dc5f91a6f242"
,"vol-09ae8deae59fb1bf2"
,"vol-0bcf8ccbba7954b34"
,"vol-0d0a8939e8ff8120d"
,"vol-0fe7a8beb4c37b2de"]

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
    instance_ids = []
    count = 0
    countx = 0
    for vl in volume_list:
        try:
            describe_volumes = ec2.describe_volumes_modifications(VolumeIds=[vl])
            for dvv in describe_volumes['VolumesModifications']:
                progress = dvv['Progress']
            if progress < 99:
                print("Current Status is " + str(progress))
            else:
                print("Disk Optimization Complete. Tallying!")
                count = count + 1
        except:
            count = count + 1

print(count)
if count >= 10:
    print("All Drives Complete. Sending Email")
    os.system("ansible-playbook disk_process_start.yml")
else:
    print("Exiting. No Action Needed.")
