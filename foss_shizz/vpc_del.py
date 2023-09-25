#!/bin/env python

import boto3
import sys

nodel=[]

vpcdict ={
    "us-east-1": "vpc-id"
}

def vpcdelete():
    x = 0
    for vd in vpcdict:
        setup = boto3.client('ec2', region_name=vd)
        vpcid=vpcdict[vd]
        vpc = setup.describe_security_groups(Filters=[{'Name': 'vpc-id', 'Values': [vpcid,]}])
        descvpc = setup.describe_vpcs(VpcIds=[vpcid,],)
        sgid = vpc['SecurityGroups'][0]['GroupId']
        rt = setup.describe_route_tables()
        rtid = rt['RouteTables'][0]['RouteTableId']
        subnet = setup.describe_subnets(Filters=[{'Name': 'vpc-id', 'Values': [vpcid,]},],)
        igsetup = setup.describe_internet_gateways(Filters=[{'Name': 'attachment.vpc-id', 'Values': [vpcid,]}])
        enisetup = setup.describe_network_interfaces(Filters=[{'Name': 'vpc-id', 'Values': [vpcid]}])
        try:
            for eni in enisetup['NetworkInterfaces']:
                eniID = eni['NetworkInterfaceId']
                eleni = setup.delete_network_interface(NetworkInterfaceId=eniID)
                print deleni
        except:
            print "Cannot Delete ENIs"
            pass
        for dvc in descvpc['Vpcs']:
            cidrid = dvc['CidrBlockAssociationSet']
            assID = cidrid[0]['AssociationId']
            try:
                dtcheni = setup.detach_network_interface(AttachmentId=attchid, Force=True)
                print dtcheni
            except:
                print "Cannot Detatch ENIs"
                pass
        try:
            igid = igsetup['InternetGateways'][0]['InternetGatewayId']
            print "Detatching Internet Gateway"
            dtchigw = setup.detach_internet_gateway(InternetGatewayId=igid, VpcId=vpcid)
            print "Deleting Internet Gateway"
            delig = setup.delete_internet_gateway(InternetGatewayId=igid)
        except:
            print "No Internet Gateway Deletable."
            pass
        try:
            for st in subnet['Subnets']:
                stid = st['SubnetId']
                print "Deleting Subnet " + stid
                stdel = setup.delete_subnet(SubnetId=stid)
                print stdel
        except:
            print "Unable to delete subnets"
            pass
        try:
            print "Deleting VPC " + vpcid
            delvpc = setup.delete_vpc(VpcId=vpcid)
            print "VPC with ID " + vpcid + " Successfully Deleted!"
        except:
            print "Unable to Delete VPC " + vpcid
            pass

vpcdelete()
