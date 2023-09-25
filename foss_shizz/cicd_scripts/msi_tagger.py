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

roleArnList = ['arn:aws:iam::<<account_id_prod>>:role/Role-Name',
'arn:aws:iam::<<account_id_nonprod>>:role/Role-Name',
'arn:aws:iam::<<account_id_workspace>>:role/Role-Name']

instance_list_raw= [

]
appname = None
instance_list = []

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
    rds = boto3.client('rds', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    elb = boto3.client('elbv2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    AccountInfo = sts.get_caller_identity()
    AccountID = AccountInfo['Account']
    #tsvout = open(aN.upper() + '_Appranix_EC2.tsv', 'a')
    #tsvout.write('Account ID\tAppranix Name\tInstance ID\tInstance State\tInstance Type\tVolume Info\tTags\n')
    count = 0
    countx = 0
    for ilr in instance_list_raw:
        describe_tags = ec2.describe_tags(Filters = [{'Name': 'resource-id', 'Values': [ilr]}])
        msi_tags = {}
        for dt in describe_tags['Tags']:
            keyname = dt['Key']
            keyvalue = dt['Value']
            msi_tags.update({keyname:keyvalue})
            if dt['Key'] == "AppName":
                appname = dt['Value']
        if "MSIRansomware" not in msi_tags:
            try:
                create_tag = ec2.create_tags(Resources=[ilr], Tags=[{'Key': 'MSIRansomware','Value': appname},])
                count = count + 1
            except:
                print("Tag Already Applied")
                countx = countx + 1
                pass
        else:
            print(ilr + " already tagged with MSIRansomware: " + msi_tags['MSIRansomware'])
            countx = countx + 1

count = str(count)
countx = str(countx)
print(count + " Instances had MSIRansomware Tag Added")
print(countx + " Instances were Skipped.")
