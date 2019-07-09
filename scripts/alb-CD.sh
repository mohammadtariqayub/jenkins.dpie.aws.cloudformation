#!/usr/bin/bash
# deploying Application Load Balancer
StackName_alb="$StackName-$Application-alb"
echo "deploying Stack $StackName_alb"

#Defining parameters
ALBName="$Application-$Environment-ext-alb"
CFNTemplate="create-alb.yml"
CertificateArn="`cat /root/artifacts/acm-arn-$StackName-syd`"
Role="web"
CloudFrontGlobalSecurityGroupID=`head -1 /root/artifacts/sg-$StackName`
CloudFrontRegionalSecurityGroupID=`tail -1 /root/artifacts/sg-$StackName`
SslPolicy="ELBSecurityPolicy-TLS-1-2-2017-01"

/root/.local/lib/aws/bin/aws cloudformation create-stack --stack-name $StackName_alb \
--template-body file:///root/jenkins.aws.cloudformation/cloudformation/create-alb.yml --parameters \
ParameterKey=ALBName,ParameterValue=$ALBName \
ParameterKey=ALBScheme,ParameterValue=$ALBScheme \
ParameterKey=ALBAcessLogBucket,ParameterValue=$ALBAcessLogBucket \
ParameterKey=CertificateArn,ParameterValue=$CertificateArn \
ParameterKey=VpcId,ParameterValue=$VpcId \
ParameterKey=CloudFrontGlobalSecurityGroupID,ParameterValue=$CloudFrontGlobalSecurityGroupID \
ParameterKey=CloudFrontRegionalSecurityGroupID,ParameterValue=$CloudFrontRegionalSecurityGroupID \
ParameterKey=PublicSubnetA,ParameterValue=$PublicSubnetA \
ParameterKey=PublicSubnetB,ParameterValue=$PublicSubnetB \
ParameterKey=PublicSubnetC,ParameterValue=$PublicSubnetC \
ParameterKey=EC2Instance1,ParameterValue=$EC2Instance1 \
ParameterKey=EC2Instance2,ParameterValue=$EC2Instance2 \
ParameterKey=Application,ParameterValue=$Application \
ParameterKey=BusinessOwner,ParameterValue=$BusinessOwner \
ParameterKey=BusinessUnit,ParameterValue=$BusinessUnit \
ParameterKey=CFNTemplate,ParameterValue=$CFNTemplate \
ParameterKey=Criticality,ParameterValue=$Criticality \
ParameterKey=Environment,ParameterValue=$Environment \
ParameterKey=RecID,ParameterValue=$RecID \
ParameterKey=SystemOwner,ParameterValue=$SystemOwner \
ParameterKey=Role,ParameterValue=$Role \
ParameterKey=SslPolicy,ParameterValue=$SslPolicy

# Wait for stack to complete
FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_alb |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
while [ "$FinalStatus" != "CREATE_COMPLETE" ]
do
    sleep 30
    FinalStatus=`/root/.local/lib/aws/bin/aws cloudformation describe-stacks --stack-name $StackName_alb |grep StackStatus |cut -d ":" -f2 |sed 's/[", ]//g'`
    echo $FinalStatus
done

# Get ALB DNS
albDNS=`/root/.local/lib/aws/bin/aws elbv2 describe-load-balancers --names $ALBName |grep DNSName |cut -d '"' -f4`
filename_alb_dns="alb-dns-$StackName"
echo alb DNS is $albDNS
echo $albDNS > /root/artifacts/$filename_alb_dns