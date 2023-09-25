#!/usr/bin/env python3

import sys
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



instance_list = []


prodkey = 'arn:aws:kms:us-east-1:<<account_id>>:key/<<key_id>>'
devkey = 'arn:aws:kms:us-east-1:<<account_id>>:key/<<key_id>>'
workspaceskey = 'arn:aws:kms:us-east-1:<<account_id>>:key/<<key_id>>' #us-east-1
volume_dict = {}
hostname_list = [
"hostname1", "hostname2", "hostname3"
]

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
    ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)#, region_name="ap-southeast-1")
    sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)#, region_name="ap-southeast-1")
    AccountInfo = sts.get_caller_identity()
    AccountID = AccountInfo['Account']
    instance_ids = []
    count = 0
    countx = 0
    if hostname_list and not instance_list:
        for hostname in hostname_list:
            print(hostname)
            describe_instances = ec2.describe_instances(Filters=[{'Name': 'tag:Name','Values': [hostname,]},],)
            for di in describe_instances['Reservations']:
                for dii in di['Instances']:
                    InstanceIds = dii['InstanceId']
                    print(InstanceIds)
                    instance_list.append(InstanceIds)
    print(instance_list)
