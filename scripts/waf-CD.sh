#!/usr/bin/bash
# deploying WAF
StackName_waf="$StackName-$Application-waf"
echo "deploying Stack $StackName_waf"

#Defining parameters
AppAccessLogBucket="$BusinessOwner-$Application-waf-logs"
ActivateSqlInjectionProtectionParam="yes"
ActivateCrossSiteScriptingProtectionParam="yes"
ActivateHttpFloodProtectionParam="yes - AWS WAF rate based rule"
ActivateScannersProbesProtectionParam="yes - AWS Lambda log parser"
ActivateReputationListsProtectionParam="yes"
ActivateBadBotProtectionParam="yes"
EndpointType="CloudFront"
RequestThreshold="2000"
ErrorThreshold="50"
WAFBlockPeriod="240"
ApiGatewayBadBotName="$Application-$BusinessOwner"

/root/.local/lib/aws/bin/aws cloudformation create-stack --stack-name $StackName_waf --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
--template-body file:///root/jenkins.aws.cloudformation/cloudformation/deploy-waf.yml --parameters \
ParameterKey=AppAccessLogBucket,ParameterValue=$AppAccessLogBucket \
ParameterKey=ActivateSqlInjectionProtectionParam,ParameterValue=$ActivateSqlInjectionProtectionParam \
ParameterKey=ActivateCrossSiteScriptingProtectionParam,ParameterValue=$ActivateCrossSiteScriptingProtectionParam \
ParameterKey=ActivateHttpFloodProtectionParam,ParameterValue="$ActivateHttpFloodProtectionParam" \
ParameterKey=ActivateScannersProbesProtectionParam,ParameterValue="$ActivateScannersProbesProtectionParam" \
ParameterKey=ActivateReputationListsProtectionParam,ParameterValue=$ActivateReputationListsProtectionParam \
ParameterKey=ActivateBadBotProtectionParam,ParameterValue=$ActivateBadBotProtectionParam \
ParameterKey=EndpointType,ParameterValue=$EndpointType \
ParameterKey=RequestThreshold,ParameterValue=$RequestThreshold \
ParameterKey=ErrorThreshold,ParameterValue=$ErrorThreshold \
ParameterKey=WAFBlockPeriod,ParameterValue=$WAFBlockPeriod \
ParameterKey=ApiGatewayBadBotName,ParameterValue=$ApiGatewayBadBotName

# Wait for stack to complete
FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_waf |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
while [ "$FinalStatus" != "CREATE_COMPLETE" ]
do
    sleep 120
    FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_waf |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
    echo $FinalStatus
done

# Get WAFWebACL
wafID=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_waf --query "Stacks[0].Outputs[?OutputKey=='WAFWebACL'].OutputValue" --output text`
filename_waf_id="waf-id-$StackName"
echo WafACLID is $wafID
echo $wafID > /root/artifacts/$filename_waf_id