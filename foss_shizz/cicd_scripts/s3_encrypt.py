#!/usr/bin/env python3

import os
import sys
import re
import boto3
import subprocess
import time
import datetime


roleArnList = ['arn:aws:iam::<<account_id_prod>>:role/Role-Name',
'arn:aws:iam::<<account_id_nonprod>>:role/Role-Name',
'arn:aws:iam::<<account_id_workspace>>:role/Role-Name']
region_list = ['us-east-1', 'us-east-2', 'us-west-1', 'us-west-2', 'ap-southeast-1']

for rA in roleArnList:
    roleArn = rA
    print("Operating under Role ARN: " + roleArn)
    roleSessionName = 'AdminRole'
    sts = boto3.client('sts')
    assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
