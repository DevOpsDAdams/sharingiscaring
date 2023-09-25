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
    userList = []
    userPolicies = []
    roleList = []
    rolePolicies = []
    Policies = []
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
    iam = boto3.client('iam', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    sts = boto3.client('sts', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token)
    AccountInfo = sts.get_caller_identity()
    AccountID = AccountInfo['Account']
    list_users = iam.list_users()
    for luu in list_users['Users']:
        user_names = luu['UserName']
        userList.append(user_names)
    for uL in userList:
        list_user_policies = iam.list_user_policies(UserName=uL)

        for lupp in list_user_policies['PolicyNames']:
            print(uL)
            print(lupp)
            get_user_policies = iam.get_user_policy(UserName=uL, PolicyName=lupp)
            print(get_user_policies['PolicyDocument'])
