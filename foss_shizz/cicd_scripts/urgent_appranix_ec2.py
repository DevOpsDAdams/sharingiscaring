#!/usr/bin/env python3

import os
import sys
import re
import boto3
import subprocess
import time
import datetime
from termcolor import colored, cprint

current_date = datetime.datetime.now()
currdate = current_date.strftime("%Y-%m-%d")
currdate_split = currdate.split('-')

roleArnList = ['arn:aws:iam::<<account_id>>:role/Role-Name', 'arn:aws:iam::<<account_id>>:role/Role-Name', 'arn:aws:iam::<<account_id>>:role/Role-Name']


instance_list = [
"i-1",
"i-2",
"i-3",
"i-4",
"i-5",
"i-6",
"i-7",
"i-8",
"i-9"
]

count = 0
for rA in roleArnList:
    roleArn = rA
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
    rds = boto3.client('rds', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    elb = boto3.client('elbv2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    AccountInfo = sts.get_caller_identity()
    AccountID = AccountInfo['Account']
    tsvout = open(aN.upper() + '_Appranix_EC2_Volume_Info.tsv', 'a')
    tsvout.write('HostName\tInstance ID\tInstance Type\tVolume ID\tVolume Mount Point\tVolume Type\tVolume Size\tEncryption\n')
    for il in instance_list:
        describe_instances = ec2.describe_instances(Filters=[{"Name": "instance-id", "Values": [il]}])
        for di in describe_instances['Reservations']:
            for dii in di['Instances']:
                instance_tags = dii['Tags']
                for it in instance_tags:
                    itags = it.values()
                    if "Name" in itags and "AppName" not in itags:
                        itagstr = str(itags)
                        split_itagstr = itagstr.split(',')
                        hostname = split_itagstr[1].strip('[\]\)\']')
                        print(il)
                instance_type = dii['InstanceType']
                volumeinfo = dii['BlockDeviceMappings']
                for vi in volumeinfo:
                    volume_name = vi['DeviceName']
                    volume_id = vi['Ebs']['VolumeId']
                    describe_volumes = ec2.describe_volumes(VolumeIds=[volume_id])
                    for dv in describe_volumes['Volumes']:
                        volume_size = dv['Size']
                        if volume_size > 1024:
                            volume_size = volume_size / 1000
                            volume_size = str(volume_size) + " TB"
                        else:
                            volume_size = str(volume_size) + " GB"
                        volume_type = dv['VolumeType']
                        encryption = dv['Encrypted']
                        encryption = str(encryption)
                        print(hostname + "\t" + il + "\t" + instance_type + "\t" + volume_id + "\t" + volume_name + "\t" + volume_type + "\t" +  volume_size + "\t" + encryption + "\n")
                        tsvout.write(hostname + "\t" + il + "\t" + instance_type + "\t" + volume_id + "\t" + volume_name + "\t" + volume_type + "\t" +  volume_size + "\t" + encryption + "\n")
tsvout.close()
