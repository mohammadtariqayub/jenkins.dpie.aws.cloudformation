/root/.local/lib/aws/bin/aws cloudformation create-stack --stack-name $StackName \
--template-body file:///root/jenkins.aws.cloudformation/cloudformation/single_instance_windows-cutomized.yaml --parameters \
ParameterKey=SubnetId,ParameterValue=$SubnetId ParameterKey=ImageID,ParameterValue=$ImageID \
ParameterKey=SystemOwner,ParameterValue=$SystemOwner ParameterKey=OS,ParameterValue=$OS \
ParameterKey=HostName,ParameterValue=$HostName ParameterKey=SecurityGroupId,ParameterValue=$SecurityGroupId \
ParameterKey=InstanceType,ParameterValue=$InstanceType ParameterKey=InstanceProfile,ParameterValue=$InstanceProfile \
ParameterKey=KeyPairName,ParameterValue=$KeyPairName ParameterKey=Environment,ParameterValue=$Environment \
ParameterKey=AWSAccount,ParameterValue=$AWSAccount ParameterKey=GorillaStack,ParameterValue=$GorillaStack \
ParameterKey=SNSTopicARN,ParameterValue=$SNSTopicARN ParameterKey=JoinDomain,ParameterValue=$JoinDomain \
ParameterKey=Proxy,ParameterValue=$Proxy

# Wait for stack to complete
FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
while [ "$FinalStatus" != "CREATE_COMPLETE" ]
do
    sleep 60
    FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
    echo $FinalStatus
done
# Get Instance ID
InstanceID=`/root/.local/lib/aws/bin/aws cloudformation describe-stack-resources --stack-name $StackName  |grep PhysicalResourceId |grep "i-" |cut -d ":" -f2 |sed 's/[", ]//g'`
echo Instance ID is $InstanceID
echo $InstanceID > /root/artifacts/instanceid