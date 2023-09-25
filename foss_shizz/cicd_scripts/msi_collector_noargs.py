#!/usr/local/bin/python3

import json
import subprocess
import datetime
from datetime import date
import argparse
import boto3
import botocore
import sys
import pprint

pp = pprint.PrettyPrinter()
parser = argparse.ArgumentParser()
################################################################################################################################################################################
#################################################################### Variable Definitions ######################################################################################
################################################################################################################################################################################

#List of Regions To Use for Iteration
region_list = ['us-east-1', 'us-east-2', 'us-west-1', 'ap-southeast-1']


resource_id = sys.argv[1]
resource = resource_id
attribute = sys.argv[2]
try:
    if sys.argv[3].lower() in region_list:
        region = sys.argv[3]
except:
    region = "us-east-1"
try:
    if sys.argv[2].lower() == "describe":
        describe = True
except:
    describe = False


# Initial Validation to Check if Required Arguments were Indeed Passed In. Exit if they arent.
if not resource_id:
    print("No valid option for argument [RESOURCE ID] given.")
    sys.exit(0)
if not attribute and describe == False:
    print('No valid option for argument [ATTRIBUTE] given.')
    sys.exit(0)

# Prebuilt Dictionary of Valid Resource Types
resource_dict = {
    "i": "ec2",
    "vpc": "vpc",
    "db": "rds",
    "rds": "rds",
    "elasticloadbalancer": "elb"
}

#Pre Assigned Variables and Lists
ec2_attribute_list = ['instanceType','kernel','ramdisk','userData','disableApiTermination','instanceInitiatedShutdownBehavior','rootDeviceName','blockDeviceMapping','productCodes','sourceDestCheck','groupSet','ebsOptimized','sriovNetSupport','enaSupport','enclaveOptions']
tag_list = []

# STS Stuff For Testing
roleArnList = ['arn:aws:iam::<<account_id_prod>>:role/Role-Name',
'arn:aws:iam::<<account_id_nonprod>>:role/Role-Name',
'arn:aws:iam::<<account_id_workspace>>:role/Role-Name']
roleSessionName = 'AdminRole'
sts = boto3.client('sts')
assumeRole = sts.assume_role(RoleArn=roleArn, RoleSessionName=roleSessionName)
access_key = assumeRole['Credentials']['AccessKeyId']
secret_key = assumeRole['Credentials']['SecretAccessKey']
session_token = assumeRole['Credentials']['SessionToken']



# Initial Validation of Resource ID Type
if "-" not in resource and "aws:" not in resource:
    print("No Resouce ID Provided. Exiting")
    sys.exit(0)

# Assign and Execute Based Upon Resource ID
if "-" in resource and "aws" not in resource:
    resplit = resource.split('-')
    if resplit[0] in resource_dict:
        resource_type = resource_dict[resplit[0]]
    if resplit[0] not in resource_dict:
        print("Non-Iterable Resource ID. Please use ARN instead.")
        sys.exit(0)

# Assign and Execute Based Upon AWS ARN
if "arn:aws:" in resource:
    resplit = resource.split(":")
    if resplit[2] in resource_dict:
        resource_type = resource_dict[resplit[2]]
    if resplit[2] not in resource_dict:
        print("Non-Iterable Resource ID. Please use ARN instead.")


################################################################################################################################################################################
#################################################################### Begin Execution Code ######################################################################################
################################################################################################################################################################################

def start(event, context):
    if resource_type == "ec2" and describe != True:
        print("Resource Type is EC2.")
        ec2_gather()
    if resource_type == "vpc":
        print("Resource Type is VPC.")
        vpc_gather()
    if resource_type == "rds":
        print("Resource Type is RDS.")
        rds_gather()
    if resource_type == "elb":
        print("Resource Type is Elastic Load Balancer.")
        elb_gather()
    if resource_type == "ec2" and describe != False:
        print("Describing Instance " + resource + ".")
        ec2_describe()


def ec2_gather():
    ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token, region_name=region)
    # Check for Instance ID Validity
    if "arn:aws:" not in resource:
        resource == resource
    if "arn:aws:" in resource:
        print("Invalid Instance ID given. Exiting.")
        sys.exit(0)
    # Check for Attribute Validity
    if attribute not in ec2_attribute_list:
        print("Invalid Attribute Given. Please provide one of the following valid options:")
        for eal in ec2_attribute_list:
            print("  " + eal)
        sys.exit(0)
    # Check for Instance Validity via tag.
    describe_tags = ec2.describe_tags(Filters = [{'Name': 'resource-id', 'Values': [resource]}])
    for dtt in describe_tags['Tags']:
        tagkey = dtt['Key']
        tag_list.append(tagkey)
    if 'MSIRansomware' not in tag_list:
        print("Instance is Not Tagged with MSIRansomware. Please check the instance and try again.")
        sys.exit(0)
    # Execute code.
    print("Gathering EC2 Attributes.")
    gather_attributes = ec2.describe_instance_attribute(InstanceId=resource, Attribute=attribute)
    pp.pprint(gather_attributes)
    return gather_attributes

def ec2_describe():
    ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token, region_name=region)
    describe_instances=ec2.describe_instances(InstanceIds=[resource])
    for di in describe_instances['Reservations']:
        dii = di['Instances']
        pp.pprint(dii)

def vpc_gather():
    print("Gathering VPC Attributes.")
    ec2 = boto3.client('ec2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token, region_name=region)





def rds_gather():
    print("Gathering RDS Attributes.")
    rds = boto3.client('rds', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token, region_name=region)





def elb_gather():
    print("Gathering Elastic Load Balancer Attributes.")
    elb = boto3.client('elbv2', aws_access_key_id=access_key, aws_secret_access_key=secret_key, aws_session_token=session_token, region_name=region)

start(resource, attribute)
