#!/usr/bin/bash
# deploying s3 for WAF
StackName_s3_waf="$StackName-$Application-s3-waf"
echo "deploying Stack $StackName_s3_waf"

#Defining parameters
BucketName="$BusinessOwner-$Application-waf-logs"
Versioning="Suspended"
S3TagBusinessUnit="$BusinessUnit"
S3TagApplication="$Application"
S3TagEnvironment="$Environment"
S3TagSystemOwner="$SystemOwner"
S3TagRFC="$RFC"
S3TagProjectCode="$ProjectCode"
S3TagPublicAccess="no"

/root/.local/lib/aws/bin/aws cloudformation create-stack --stack-name $StackName_s3_waf \
--template-body file:///root/jenkins.aws.cloudformation/cloudformation/DOI-Standard-S3-template.yml --parameters \
ParameterKey=BucketName,ParameterValue=$BucketName \
ParameterKey=Versioning,ParameterValue=$Versioning \
ParameterKey=EnvironmentType,ParameterValue=$EnvironmentType \
ParameterKey=S3TagBusinessUnit,ParameterValue=$S3TagBusinessUnit \
ParameterKey=S3TagApplication,ParameterValue=$S3TagApplication \
ParameterKey=S3TagEnvironment,ParameterValue=$S3TagEnvironment \
ParameterKey=S3TagSystemOwner,ParameterValue=$S3TagSystemOwner \
ParameterKey=S3TagRFC,ParameterValue=$S3TagRFC \
ParameterKey=S3TagProjectCode,ParameterValue=$S3TagProjectCode \
ParameterKey=S3TagPublicAccess,ParameterValue=$S3TagPublicAccess

# Wait for stack to complete
FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_s3_waf |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
while [ "$FinalStatus" != "CREATE_COMPLETE" ]
do
    sleep 30
    FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_s3_waf |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
    echo $FinalStatus
done

# deploying s3 for CF
StackName_s3_cf="$StackName-$Application-s3-cf"
echo "deploying Stack $StackName_s3_cf"

#Defining bucket name for CF
BucketName="$BusinessOwner-$Application-cf-logs"

/root/.local/lib/aws/bin/aws cloudformation create-stack --stack-name $StackName_s3_cf \
--template-body file:///root/jenkins.aws.cloudformation/cloudformation/DOI-Standard-S3-template.yml --parameters \
ParameterKey=BucketName,ParameterValue=$BucketName \
ParameterKey=Versioning,ParameterValue=$Versioning \
ParameterKey=EnvironmentType,ParameterValue=$EnvironmentType \
ParameterKey=S3TagBusinessUnit,ParameterValue=$S3TagBusinessUnit \
ParameterKey=S3TagApplication,ParameterValue=$S3TagApplication \
ParameterKey=S3TagEnvironment,ParameterValue=$S3TagEnvironment \
ParameterKey=S3TagSystemOwner,ParameterValue=$S3TagSystemOwner \
ParameterKey=S3TagRFC,ParameterValue=$S3TagRFC \
ParameterKey=S3TagProjectCode,ParameterValue=$S3TagProjectCode \
ParameterKey=S3TagPublicAccess,ParameterValue=$S3TagPublicAccess

# Wait for stack to complete
FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_s3_cf |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
while [ "$FinalStatus" != "CREATE_COMPLETE" ]
do
    sleep 30
    FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_s3_cf |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
    echo $FinalStatus
done