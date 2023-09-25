#!/usr/bin/env python3

import os
import sys
import re
from typing import Union
import boto3
import subprocess
import time
import datetime



sts = boto3.client('sts')
s3 = boto3.client('s3')
curr_account = sts.get_caller_identity()
AccountID=curr_account['Account']
list_buckets = s3.list_buckets(Owner = AccountID)
master_bucket_list=[]
bucket_objects=[]
unencrypted_buckets = []

#list_buckets = ["bucket-poc"]

def build_master_bucket_list():
    for lb in list_buckets['Buckets']:
        bucket_name = lb['Name']
        print("Building Master Bucket List")
        print("Adding Bucket: " + bucket_name)
        master_bucket_list.append(bucket_name)

def check_bucket_encryption():
    for mbl in master_bucket_list:
        bucket_name = mbl
        print("Checking " + bucket_name + "'s encryption status.")
        try:
            bucket_encryption = s3.get_bucket_encryption(Bucket=bucket_name)
        except:
            unencrypted_buckets.append(bucket_name)
        os.system('clear')

def enable_versioning():
    for mbl in master_bucket_list:
        bucket_name = mbl
        ver_status = "Disabled"
        get_versioning = s3.get_bucket_versioning(Bucket=bucket_name)
        try:
            ver_status = get_versioning['Status']
        except:
            pass
        if ver_status == "Enabled":
            print("Versioning Enabled... Moving on.")
            pass
        else:
            print("Enabling Versioning for " + bucket_name)
            enable_versioning = s3.put_bucket_versioning(Bucket=bucket_name, VersioningConfiguration={
                'Status': 'Enabled'},
            )
        new_version_status = s3.get_bucket_versioning(Bucket=bucket_name)
        try:
            new_status = new_version_status['Status']
        except:
            new_status = "Disabled"
        if new_status == "Enabled":
            print("Versioning now " + new_status + " for " + bucket_name)
            pass
        else:
            print("ERROR: Unable to enable versioning")
            list_buckets.remove(bucket_name)


def encrypt_buckets():
    if len(unencrypted_buckets) < 1:
        print("All buckets are encrypted. Moving on to objects.")
        return
    for ub in unencrypted_buckets:
        print("Setting encryption for " + ub)
        encryption_on = set_encryption = s3.put_bucket_encryption(Bucket=ub, ServerSideEncryptionConfiguration={
            'Rules': [
                {
                    'ApplyServerSideEncryptionByDefault': {
                        'SSEAlgorithm': 'AES256'
                    }
                }
            ]
        })
        print("Encryption now enabled for " + ub)

def encrypt_objects():
    for mbl in master_bucket_list:
        bucket_name = mbl
        list_objects = s3.list_objects_v2(Bucket=bucket_name)
        try:
            for lo in list_objects["Contents"]:
                object=lo['Key']
                bucket_objects.append(object)
            for bo in bucket_objects:
                print("Checking encryption status for " + bo)
                head = s3.head_object(Bucket=bucket_name, Key=bo)
                if 'ServerSideEncryption' in head:
                    print("Object " + bo + " is already encrypted. Moving on.")
                else:
                    try:
                        print("Encrypting Objects in  " + bucket_name)
                        print("Attempting to copy object " + bucket_name + "/" + bo)
                        copy_object = s3.copy_object(Bucket=bucket_name, Key=bo, CopySource={ 'Bucket': bucket_name, 'Key': bo }, ServerSideEncryption="AES256")
                        print(bucket_name + "/" + bo + " copied for versioning.")
                    except:
                        print("Unable to copy object " + bucket_name + "/" + bo)
        except:
            print("No Objects in " + mbl)
            pass

build_master_bucket_list()
check_bucket_encryption()
enable_versioning()
encrypt_buckets()
encrypt_objects()
print("All done!")
sys.exit(0)
