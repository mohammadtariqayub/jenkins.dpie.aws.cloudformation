import os
import sys
import json
import uuid
import boto3
from time import time

### Global variables ###
account_id = os.environ['AWSAccountNumber']
StackName = os.environ['StackName']
AWS_REGION = os.environ['Region']
ALBScheme = os.environ['ALBScheme']
ALBAcessLogBucket = os.environ['ALBAcessLogBucket']
VpcId = os.environ['VpcId']
PublicSubnetA = os.environ['PublicSubnetA']
PublicSubnetB = os.environ['PublicSubnetB']
PublicSubnetC = os.environ['PublicSubnetC']
EC2Instance1 = os.environ['EC2Instance1']
EC2Instance2 = os.environ['EC2Instance2']
Application = os.environ['Application']
BusinessOwner = os.environ['BusinessOwner']
BusinessUnit = os.environ['BusinessUnit']
Criticality = os.environ['Criticality']
Environment = os.environ['Environment']
RecID = os.environ['RecID']
SystemOwner = os.environ['SystemOwner']

### reading sydney certificate arn from artifact
path = '/var/lib/jenkins/workspace/Sandpit/CF-SAND/acm-cert-syd/scripts/acm-syd-artifact.txt'
Acm_sys_ARN_artifact = open(path,'r')
Acm_syd_ARN = Acm_sys_ARN_artifact.read()
print(Acm_syd_ARN)

### reading sg1 from artifact
path = '/var/lib/jenkins/workspace/Sandpit/CF-SAND/cloudfront-sg/scripts/sg1-artifact.txt'
sg1_artifact = open(path,'r')
sg1_ID = sg1_artifact.read()
print(sg1_ID)

### reading sg2 from artifact
path = '/var/lib/jenkins/workspace/Sandpit/CF-SAND/cloudfront-sg/scripts/sg2-artifact.txt'
sg2_artifact = open(path,'r')
sg2_ID = sg2_artifact.read()
print(sg2_ID)

