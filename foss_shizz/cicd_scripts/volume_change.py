#!/usr/bin/env python3

import sys
import re
import boto3
from time import sleep
import datetime

current_date = datetime.datetime.now()
currdate = current_date.strftime("%Y-%m-%d")
currdate_split = currdate.split('-')

roleArnList = ['arn:aws:iam::<<account_id>>:role/role-name', 'arn:aws:iam::<<account_id>>:role/role-name', 'arn:aws:iam::<<account_id>>:role/role-name']
instance_id= 'none'
volume_type='io1'
volume_size=16384
IOPS=16000


volume_dict = {}
volume_list = ["vol-1"
,"vol-2"
,"vol-3"
,"vol-4"
,"vol-5"
,"vol-6"
,"vol-7"
,"vol-8"
,"vol-9"]


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
    describe_volumes = False
    hostname = "None"
    #csvoutput = open('./' + aN + '_Volume_Change.csv', 'a')
    #csvoutput.write('Account ID,VolumeId,Volume Was,Volume State,Instance ID,Server Name,Changed,Changed To\n')
    print('Account ID,VolumeId,Volume Was,Volume State,Instance ID,Server Name,Changed,Changed To\n')
    for vl in volume_list:
        describe_volumes = ec2.describe_volumes(VolumeIds=[vl])
        for dvv in describe_volumes['Volumes']:
            volume_type_origin = dvv['VolumeType']
            state = dvv['State']
            changed = "Yes"
            if state.lower() == "in-use":
                InstanceIds = dvv['Attachments'][0]['InstanceId']
                describe_tags = ec2.describe_tags(Filters = [{'Name': 'resource-id', 'Values': [InstanceIds]}])
                for dt in describe_tags['Tags']:
                    keyname = dt['Key']
                    if keyname == "Name":
                        hostname = dt['Value']
            else:
                changed = "No"
                try:
                    InstanceIds = dvv['Attachments'][0]['InstanceId']
                except:
                    InstanceIds = "None"
                    pass
            volume_dict.update({vl:InstanceIds})
        if state.lower() != "error" and state.lower() != 'deleting' and state.lower() != 'deleted':
            #modify_volume = ec2.modify_volume(VolumeId=vl, Size=volume_size)
            count = count + 1
            #print(aN + "-" + AccountID + "," + vl + "," + volume_type_origin + "," + state + "," + InstanceIds + "," + hostname + "," + changed + "," + volume_type + "\n")
            #csvoutput.write(aN + "-" + AccountID + "," + vl + "," + volume_type_origin + "," + state + "," + InstanceIds + "," + hostname + "," + changed + "," + volume_type + "\n")

print('The following ' + str(count) + ' drives have been modified.')

fileout = open("voloutput", 'a')
for vd in volume_dict:
    iid = volume_dict[vd]
    vid = vd
    print(vid + " on " + iid)
    fileout.write(vid + " on " + iid + "\n")
fileout.close()
