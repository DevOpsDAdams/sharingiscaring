#!/bin/env python3

import sys
import boto3
import datetime
import re

localtime = datetime.datetime.now()
loctime = localtime.strftime("%H%M")
resumetime = localtime.replace(hour=16, minute=0, second=0, microsecond=0)
pausetime = localtime.replace(hour=7, minute=0, second=0, microsecond=0)
restime = resumetime.strftime("%H%M")
ptime = pausetime.strftime("%H%M")
ptime = int(ptime)
restime = int(restime)
loctime = int(loctime)
sts = boto3.client('sts')
ssm = boto3.client('ssm')
ecs_recommended_path = '/aws/service/ecs/optimized-ami/amazon-linux-2/recommended'
our_ami = '/ci/ecs/ami/latest'
ecs_dict = ssm.get_parameter(Name=ecs_recommended_path, WithDecryption=False)
try:
    par_ami = ssm.get_parameter(Name=our_ami, WithDecryption=False)
except:
    par_ami = "None"
    pass
ecs_dict_value = ecs_dict['Parameter']['Value']
try:
    par_ami_id = par_ami['Parameter']['Value']
except:
    par_ami_id = "None"
edvsplit = ecs_dict_value.split(',')
for edvs in edvsplit:
    if "id" in edvs and "ami-" in edvs:
        image_id_ref=edvs
idrefsplit=image_id_ref.split(":")
image_id = idrefsplit[1]
recommended_image_id = image_id.strip('"')


if par_ami_id == "None":
    print("No AMI ID stored for latest ECS in local SSM. Writing value.")
    ssm.put_parameter(Name=our_ami, Value=recommended_image_id, Type="String", Overwrite=False)
    sys.exit(0)
elif par_ami_id != recommended_image_id:
    print("AMI ID in local SSM is out of date. Updating.")
    ssm.put_parameter(Name=our_ami, Value=recommended_image_id, Type="String", Overwrite=True)
    sys.exit(0)
else:
    print("Everything looks good. Exiting")
    sys.exit(0)
