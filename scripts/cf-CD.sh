#!/usr/bin/bash
# deploying CF
StackName_cf="$StackName-$Application-cf"
echo "deploying Stack $StackName_cf"

#Defining parameters
CloudfrontCertificate="`cat /root/artifacts/acm-arn-$StackName-us`"
ELBDNSName="`cat /root/artifacts/alb-dns-$StackName`"
WafAcl="`cat /root/artifacts/waf-id-$StackName`"
BucketName="$BusinessOwner-$Application-cf-logs"
CFNTemplate="deploy-cloudfront-single-domain.yml"
Role="web"
PublicAccess="no"

/root/.local/lib/aws/bin/aws cloudformation create-stack --stack-name $StackName_cf \
--template-body file:///root/jenkins.aws.cloudformation/cloudformation/deploy-cloudfront-single-domain.yml --parameters \
ParameterKey=CloudfrontCertificate,ParameterValue=$CloudfrontCertificate \
ParameterKey=DomainName,ParameterValue=$DomainName \
ParameterKey=ELBDNSName,ParameterValue=$ELBDNSName \
ParameterKey=WafAcl,ParameterValue=$WafAcl \
ParameterKey=Application,ParameterValue=$Application \
ParameterKey=BusinessOwner,ParameterValue=$BusinessOwner \
ParameterKey=BusinessUnit,ParameterValue=$BusinessUnit \
ParameterKey=CFNTemplate,ParameterValue=$CFNTemplate \
ParameterKey=Criticality,ParameterValue=$Criticality \
ParameterKey=Environment,ParameterValue=$Environment \
ParameterKey=RecID,ParameterValue=$RecID \
ParameterKey=SystemOwner,ParameterValue=$SystemOwner \
ParameterKey=Role,ParameterValue=$Role \
ParameterKey=PublicAccess,ParameterValue=$PublicAccess \
ParameterKey=BucketName,ParameterValue=$BucketName

# Wait for stack to complete
FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_cf |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
while [ "$FinalStatus" != "CREATE_COMPLETE" ]
do
    sleep 120
    FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_cf |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
    echo $FinalStatus
done