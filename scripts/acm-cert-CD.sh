#!/usr/bin/bash
# deploying cerificate in ap_southeast_2
StackName_syd="$StackName-$Application-acm-sydney"
echo "deploying Stack $StackName_syd"

/root/.local/lib/aws/bin/aws cloudformation create-stack --stack-name $StackName_syd \
--template-body file:///root/jenkins.aws.cloudformation/cloudformation/acm-provision-ssl-certificate.yml --parameters \
ParameterKey=ApexDomainName,ParameterValue=$ApexDomainName \
ParameterKey=Application,ParameterValue=$Application \
ParameterKey=BusinessOwner,ParameterValue=$BusinessOwner \
ParameterKey=BusinessUnit,ParameterValue=$BusinessUnit \
ParameterKey=Comments,ParameterValue=$Comments \
ParameterKey=DomainName,ParameterValue=$DomainName \
ParameterKey=Environment,ParameterValue=$Environment \
ParameterKey=ProjectCode,ParameterValue=$ProjectCode \
ParameterKey=RecID,ParameterValue=$RecID \
ParameterKey=RFC,ParameterValue=$RFC \
ParameterKey=SystemOwner,ParameterValue=$SystemOwner \
ParameterKey=AWSAccount,ParameterValue=$AWSAccount

# Wait for stack to complete
FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_syd |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
while [ "$FinalStatus" != "CREATE_COMPLETE" ]
do
    sleep 60
    FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_syd |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
    echo $FinalStatus
done
# Get ACM ID
acm_arn_ap_southeast_2=`/root/.local/lib/aws/bin/aws cloudformation describe-stack-resources --stack-name $StackName_syd |grep PhysicalResourceId |cut -d '"' -f4`
filename="acm-arn-$StackName-syd"
echo ACM ARN ap-southeast-2 is $acm_arn_ap_southeast_2
echo $acm_arn_ap_southeast_2 > /root/artifacts/$filename

# deploying cerificate in us-east-1
StackName_us="$StackName-$Application-acm-us-1"
echo "deploying Stack $StackName"

/root/.local/lib/aws/bin/aws --region us-east-1	cloudformation create-stack --stack-name $StackName_us \
--template-body file:///root/jenkins.aws.cloudformation/cloudformation/acm-provision-ssl-certificate.yml --parameters \
ParameterKey=ApexDomainName,ParameterValue=$ApexDomainName \
ParameterKey=Application,ParameterValue=$Application \
ParameterKey=BusinessOwner,ParameterValue=$BusinessOwner \
ParameterKey=BusinessUnit,ParameterValue=$BusinessUnit \
ParameterKey=Comments,ParameterValue=$Comments \
ParameterKey=DomainName,ParameterValue=$DomainName \
ParameterKey=Environment,ParameterValue=$Environment \
ParameterKey=ProjectCode,ParameterValue=$ProjectCode \
ParameterKey=RecID,ParameterValue=$RecID \
ParameterKey=RFC,ParameterValue=$RFC \
ParameterKey=SystemOwner,ParameterValue=$SystemOwner \
ParameterKey=AWSAccount,ParameterValue=$AWSAccount

# Wait for stack to complete
FinalStatus=`/root/.local/lib/aws/bin/aws --region us-east-1 cloudformation describe-stacks --stack-name $StackName_us |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
while [ "$FinalStatus" != "CREATE_COMPLETE" ]
do
    sleep 60
    FinalStatus=`/root/.local/lib/aws/bin/aws --region us-east-1 cloudformation describe-stacks --stack-name $StackName_us |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
    echo $FinalStatus
done
# Get ACM ID
acm_arn_us_east_1=`/root/.local/lib/aws/bin/aws --region us-east-1 cloudformation describe-stack-resources --stack-name $StackName_us |grep PhysicalResourceId |cut -d '"' -f4`
filename="acm-arn-$StackName-us"
echo ACM ARN us-east-1 is $acm_arn_us_east_1
echo $acm_arn_us_east_1 > /root/artifacts/$filename