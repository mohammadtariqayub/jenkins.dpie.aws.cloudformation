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
Application = os.environ['Application']
BusinessOwner = os.environ['BusinessOwner']
Capabilities_ID = ['CAPABILITY_IAM','CAPABILITY_AUTO_EXPAND']

### Local variables
AppAccessLogBucket = BusinessOwner + "-" + Application + "-" + "waf-logs"
ActivateSqlInjectionProtectionParam = 'yes'
ActivateCrossSiteScriptingProtectionParam = 'yes'
ActivateHttpFloodProtectionParam = 'yes - AWS WAF rate based rule'
ActivateScannersProbesProtectionParam = 'yes - AWS Lambda log parser'
ActivateReputationListsProtectionParam = 'yes'
ActivateBadBotProtectionParam = 'yes'
EndpointType = 'CloudFront'
RequestThreshold = '2000'
ErrorThreshold = '50'
WAFBlockPeriod = '240'
ApiGatewayBadBotName = Application + "-" + BusinessOwner

def get_arn(account_id, role_name):
    ''' Returns the ARN we'll use when making requests '''
    arn = "arn:aws:iam::{account_id}:role/{role_name}".format(account_id=account_id,role_name=role_name)

    return arn

def assume_role(arn, role_session_name="AssumedRole"):
    ''' Assume a role using STS Client '''
    # create an STS client object that represents a live connection to the
    # STS service
    sts_client = boto3.client('sts')
    assumed_role_object = sts_client.assume_role(RoleArn=arn,RoleSessionName=role_session_name)

    return assumed_role_object

def create_cfclient(credentials, AWS_REGION):
    ''' Create a CloudFormation Client using the credentials '''
    # Create a client to cloudformation using credentials we get from STS

    cfc = boto3.client('cloudformation',
                    region_name=AWS_REGION,
                    aws_access_key_id = credentials['AccessKeyId'],
                    aws_secret_access_key = credentials['SecretAccessKey'],
                    aws_session_token = credentials['SessionToken'])
    
    return cfc

def create_cfresource(credentials, AWS_REGION):
    ''' Create a CloudFormation resource using the credentials '''
    # Create a resource to cloudformation using credentials we get from STS
    cfr = boto3.resource('cloudformation',
                    region_name=AWS_REGION,
                    aws_access_key_id = credentials['AccessKeyId'],
                    aws_secret_access_key = credentials['SecretAccessKey'],
                    aws_session_token = credentials['SessionToken'])
    
    return cfr

def create_cfwaiter(client, stack_name):
    ''' Create a Cloudformation waiter resource '''
    
    # Create a client to cloudformation using credentials we get from STS
    cfw = client.get_waiter('stack_create_complete')
    
    return cfw

def create_artifact(text):
    ''' Create a text file as artifact '''

    file_name = 'waf-acl-id-artifact.txt'
    with open(file_name,'w') as artifact:
        artifact.write(text)

def parse_template(template, credentials=None):
    ''' Parse Cloudformation template from a file '''

    if not credentials:
        raise Exception("Credentials are required")

    with open(template) as template_fileobj:
        template_data = template_fileobj.read()

    # Create a client to cloudformation using credentials we get from STS
    cf = boto3.client('cloudformation',
                    region_name=AWS_REGION,
                    aws_access_key_id = credentials['AccessKeyId'],
                    aws_secret_access_key = credentials['SecretAccessKey'],
                    aws_session_token = credentials['SessionToken'])

    cf.validate_template(TemplateBody=template_data)
    return template_data

def create_stack(client, params={}):
    ''' Takes a stack name, cfn template and parameters and creates the stack '''
    #create a Cloudformation stack
    stack = client.create_stack(**params)

    return stack

def get_params(parameters):
    ''' Prepare the parameters for the CloudFormation stack '''
    params = []
    # Go through the parameter values and prepare the key value pair required for CloudFormation.
    for parameter in parameters:
        for key in parameter:
            params.append({'ParameterKey':key,'ParameterValue':parameter[key]})
        
    return params

def main():
    role_name = 'crossaccount-jenkins-slave-bts'
  
    arn = get_arn(account_id, role_name)
    print ("Assumming role...")
    assumed_role_object = assume_role(arn)
    print ("Role assummed successfully!")
    credentials = assumed_role_object['Credentials']
    
    cf_client = create_cfclient(credentials, AWS_REGION)
    cf_resource = create_cfresource(credentials, AWS_REGION)
    
    # Parse the given template
    template = parse_template("../cloudformation/deploy-waf.yml", credentials=credentials)
    print ("Template validated!")

    stack_id = int(time())
    jenkins_job_name = os.environ['StackName']
    jenkins_build_number = os.environ['BUILD_NUMBER']
    stack_name = jenkins_job_name + "-" + "waf"
    print ("Using stack name: " + stack_name)

    cft_params = []
    cft_params.append({'AppAccessLogBucket': AppAccessLogBucket})
    cft_params.append({'ActivateSqlInjectionProtectionParam': ActivateSqlInjectionProtectionParam})
    cft_params.append({'ActivateCrossSiteScriptingProtectionParam': ActivateCrossSiteScriptingProtectionParam})
    cft_params.append({'ActivateHttpFloodProtectionParam': ActivateHttpFloodProtectionParam})
    cft_params.append({'ActivateScannersProbesProtectionParam': ActivateScannersProbesProtectionParam})
    cft_params.append({'ActivateReputationListsProtectionParam': ActivateReputationListsProtectionParam})
    cft_params.append({'ActivateBadBotProtectionParam': ActivateBadBotProtectionParam})
    cft_params.append({'EndpointType': EndpointType})
    cft_params.append({'RequestThreshold': RequestThreshold})
    cft_params.append({'ErrorThreshold': ErrorThreshold})
    cft_params.append({'WAFBlockPeriod': WAFBlockPeriod})
    cft_params.append({'ApiGatewayBadBotName': ApiGatewayBadBotName})

    parameter_data = get_params(cft_params)

    params = {
        'StackName': stack_name,
        'TemplateBody': template,
        'Parameters': parameter_data,
        'EnableTerminationProtection': False,
        'Capabilities': Capabilities_ID,
        'DisableRollback': True,
    }

    # Create CloudFormation Stack
    stack = create_stack(cf_resource, params)
    cfwaiter = create_cfwaiter(cf_client, stack_name)
    cfwaiter.wait(StackName=stack_name)
    print("Stack status: " + stack.stack_status)

    #resources = cf_client.list_stack_resources(StackName=stack_name)
    #print(resources)

    stack_output = cf_client.describe_stacks(StackName=stack_name)
    print (stack_output)
    waf_output = stack_output['Stacks'][0]['Outputs'][0]['OutputValue']
    print("WAF ACL is : ", waf_output)

    create_artifact(str(waf_output))

if __name__ == "__main__":
    main()