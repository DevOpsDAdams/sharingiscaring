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

region_list = ['us-east-1']#, 'us-east-2', 'us-west-1']
ps_head = "/dadams/test/parameter/"

ami_names = {}
count = 0
countx = 0
sts = boto3.client('sts')
AccountInfo = sts.get_caller_identity()
AccountID = AccountInfo['Account']
for rl in region_list:
    ec2 = boto3.client('ec2', region_name=rl)
    ssm = boto3.client('ssm', region_name=rl)
    print("Entering Region " + rl)
    describe_images = ec2.describe_images(Owners=[AccountID])
    delete = True
    for di in describe_images['Images']:
        image_name = di['Name']
        image_id = di['ImageId']
        try:
            for dit in di['Tags']:
                key = dit['Key']
                value = dit['Value']
                if key == "Name" and value.startswith("NCFL_"):
                    create_date = di['CreationDate']
                    create_date = re.findall('(\S.*)T', create_date)
                    for created in create_date:
                        created = str(created)
                    image_date_split = created.split('-')
                    image_date = datetime.datetime(year=int(image_date_split[0]), month=int(image_date_split[1]), day=int(image_date_split[2]))
                    now_date = datetime.datetime(year=int(currdate_split[0]), month=int(currdate_split[1]), day=int(currdate_split[2]))
                    date_delta = now_date - image_date
                    days_old = date_delta.days
                    if days_old > -1:
                       print("The AMI " + image_name + " with AMI ID " + image_id + " will be deregistered.")
                       ami_names.update({image_name:image_id})
                       #dereg_image = ec2.deregister_image(ImageId=image_id)
                #if key == "DeleteException":
                #    delete = False
        except:
            pass
    print("\n\nRemoving AMI ID Entries from Parameter Store")
    for an in ami_names:
        delete_param = ssm.delete_parameter(Name=ps_head + an)
        print("\t" + ps_head + an + " Removed.")
'''
            if days_old > days and delete == True:
                count = count + 1
                days_old = str(days_old)
                print("Deleting " + image_id + " in " + str(AccountID) + " as it is " + days_old + " days old.")
                dereg_image = ec2.deregister_image(ImageId=image_id)
            elif delete == False:
                countx = countx + 1
            else:
                countx = countx + 1
                pass
        except:
            pass
print(str(count) + " AMIs were Removed.")
print(str(countx) + " AMIs were Skipped.")
'''
