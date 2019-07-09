#!/usr/bin/bash
# deploying security group and lambda in ap_southeast_2
StackName_sg="$StackName-$Application-sg"
echo "deploying Stack $StackName_sg"

/root/.local/lib/aws/bin/aws cloudformation create-stack --stack-name $StackName_sg --capabilities CAPABILITY_NAMED_IAM \
--template-body file:///root/jenkins.aws.cloudformation/cloudformation/cloudfront-elb-security-groups.yml --parameters \
ParameterKey=Application,ParameterValue=$Application \
ParameterKey=AWSAccountSSMParameter,ParameterValue=$AWSAccountSSMParameter \
ParameterKey=Comments,ParameterValue=$Comments \
ParameterKey=DeploymentBucket,ParameterValue=$DeploymentBucket \
ParameterKey=ProjectCode,ParameterValue=$ProjectCode \
ParameterKey=Environment,ParameterValue=$Environment \
ParameterKey=VpcId,ParameterValue=$VpcId \
ParameterKey=SystemOwner,ParameterValue=$SystemOwner

# Wait for stack to complete
FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_sg |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
while [ "$FinalStatus" != "CREATE_COMPLETE" ]
do
    sleep 30
    FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_sg |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
    echo $FinalStatus
done

# Get SecurityGroup ID
filename_sg="sg-$StackName"
echo " "
echo "Security Group created are `/root/.local/lib/aws/bin/aws cloudformation describe-stack-resources --stack-name $StackName_sg |grep PhysicalResourceId |grep sg-0 |cut -d '"' -f4`"
echo "`/root/.local/lib/aws/bin/aws cloudformation describe-stack-resources --stack-name $StackName_sg |grep PhysicalResourceId |grep sg-0 |cut -d '"' -f4`" > /root/artifacts/$filename_sg

# Get lambda function ID
lambda_ID=`/root/.local/lib/aws/bin/aws cloudformation describe-stack-resources --stack-name $StackName_sg |grep PhysicalResourceId |grep function |cut -d '"' -f4`
filename_lambda="lambda-function-$StackName"
echo lambda function is $lambda_ID
echo $lambda_ID > /root/artifacts/$filename_lambda

# Get lambda ARN
LambdaARN=`/root/.local/lib/aws/bin/aws lambda get-function --function-name $lambda_ID |grep FunctionArn |cut -d '"' -f4`
filename_lambda_arn="lambda-arn-$StackName"
echo lambda ARN is $LambdaARN
echo $LambdaARN > /root/artifacts/$filename_lambda_arn

echo "Security group and Lambda function creation done"
echo " "

# Subscribe to AmazonIpSpaceChanged Topic
StackName_sns="$StackName-$Application-sns"
echo "deploying Stack $StackName_sns"

/root/.local/lib/aws/bin/aws --region us-east-1 cloudformation create-stack --stack-name $StackName_sns \
--template-body file:///root/jenkins.aws.cloudformation/cloudformation/SNS-AmazonIpSpaceChanged-topic.yml --parameters \
ParameterKey=LambdaARN,ParameterValue=$LambdaARN 

# Wait for stack to complete
FinalStatus=`/root/.local/lib/aws/bin/aws --region us-east-1 cloudformation describe-stacks --stack-name $StackName_sns |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
while [ "$FinalStatus" != "CREATE_COMPLETE" ]
do
    sleep 15
    FinalStatus=`/root/.local/lib/aws/bin/aws --region us-east-1 cloudformation describe-stacks --stack-name $StackName_sns |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
    echo $FinalStatus
done
echo " "
echo "SNS subscription for Lambda is done"