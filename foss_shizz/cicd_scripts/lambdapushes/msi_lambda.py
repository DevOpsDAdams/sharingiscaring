
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
region = "us-east-1"

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

################################################################################################################################################################################
#################################################################### Begin Execution Code ######################################################################################
################################################################################################################################################################################

def start(event, context):
    global resource
    global attribute

    resource = event['resource']
    attribute = event['attribute']
    if attribute.lower() == "describe":
        describe = "True"
    else:
        describe = "False"
    if "-" not in resource and "aws:" not in resource:
        print("No Resouce ID Provided. Exiting")
        sys.exit(0)
    if "-" in resource and "aws" not in resource: 
        resplit = resource.split('-')
        if resplit[0] in resource_dict:
            resource_type = resource_dict[resplit[0]]
        if resplit[0] not in resource_dict:
            print("Non-Iterable Resource ID. Please use ARN instead.")
            sys.exit(0)
    if "arn:aws:" in resource:
        resplit = resource.split(":")
        if resplit[2] in resource_dict:
            resource_type = resource_dict[resplit[2]]
        if resplit[2] not in resource_dict:
            print("Non-Iterable Resource ID. Please use ARN instead.")
            sys.exit(0)
    if resource_type == "ec2" and describe != "True":
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
    if resource_type == "ec2" and describe != "False":
        print("Describing Instance " + resource + ".")
        return str(ec2_describe())


def ec2_gather():
    ec2 = boto3.client('ec2', region_name=region)
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
    ec2 = boto3.client('ec2', region_name=region)
    describe_instances=ec2.describe_instances(InstanceIds=[resource])
    for di in describe_instances['Reservations']:
        dii = di['Instances']
        pp.pprint(dii)
    return dii

def vpc_gather():
    print("Gathering VPC Attributes.")
    ec2 = boto3.client('ec2', region_name=region)





def rds_gather():
    print("Gathering RDS Attributes.")
    rds = boto3.client('rds', region_name=region)





def elb_gather():
    print("Gathering Elastic Load Balancer Attributes.")
    elb = boto3.client('elbv2', region_name=region)
