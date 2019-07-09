node ('slave') {

  stage('template copy'){
    git url: 'https://github.com/mohammadtariqayub/jenkins.aws.cloudformation.git'
    sh "cp -R * /root/jenkins.aws.cloudformation/"
  }

  stage('create acm certificate') {
    echo "creating acm certificate"
    build job: 'acm-cert-CD',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'ApexDomainName', value: params['ApexDomainName']),
                string(name: 'Application', value: params['Application']),
                string(name: 'BusinessOwner', value: params['BusinessOwner']),
                string(name: 'BusinessUnit', value: params['BusinessUnit']),
                string(name: 'Comments', value: params['Comments']),
                string(name: 'DomainName', value: params['DomainName']),
                string(name: 'Environment', value: params['Environment']),
                string(name: 'ProjectCode', value: params['ProjectCode']),
                string(name: 'RecID', value: params['RecID']),
                string(name: 'RFC', value: params['RFC']),
                string(name: 'AWSAccount', value: params['AWSAccount']),
                string(name: 'SystemOwner', value: params['SystemOwner'])
           ]
  }

  stage('deploy security group') {
    echo "deploying security group"
    build job: 'cloudfront-sg-CD',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'Application', value: params['Application']),
                string(name: 'AWSAccountSSMParameter', value: params['AWSAccountSSMParameter']),
                string(name: 'Comments', value: params['Comments']),
                string(name: 'DeploymentBucket', value: params['DeploymentBucket']),
                string(name: 'ProjectCode', value: params['ProjectCode']),
                string(name: 'Environment', value: params['Environment']),
                string(name: 'VpcId', value: params['VpcId']),
                string(name: 'SystemOwner', value: params['SystemOwner'])
           ]
  }
  
  stage('deploy alb') {
    echo "deploying alb"
    build job: 'alb-CD',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'ALBScheme', value: params['ALBScheme']),
                string(name: 'ALBAcessLogBucket', value: params['ALBAcessLogBucket']),
                string(name: 'VpcId', value: params['VpcId']),
                string(name: 'PublicSubnetA', value: params['PublicSubnetA']),
                string(name: 'PublicSubnetB', value: params['PublicSubnetB']),
                string(name: 'PublicSubnetC', value: params['PublicSubnetC']),
                string(name: 'EC2Instance1', value: params['EC2Instance1']),
                string(name: 'EC2Instance2', value: params['EC2Instance2']),
                string(name: 'Application', value: params['Application']),
                string(name: 'BusinessOwner', value: params['BusinessOwner']),
                string(name: 'BusinessUnit', value: params['BusinessUnit']),
                string(name: 'Criticality', value: params['Criticality']),
                string(name: 'Environment', value: params['Environment']),
                string(name: 'RecID', value: params['RecID']),
                string(name: 'SystemOwner', value: params['SystemOwner'])
           ]
  }

  stage('deploy s3 buckets') {
    echo "deploy s3 buckets for WAF and CF"
    build job: 's3-bucket-CD',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'Application', value: params['Application']),
                string(name: 'EnvironmentType', value: params['EnvironmentType']),
                string(name: 'BusinessOwner', value: params['BusinessOwner']),
                string(name: 'BusinessUnit', value: params['BusinessUnit']),
                string(name: 'Environment', value: params['Environment']),
                string(name: 'ProjectCode', value: params['ProjectCode']),
                string(name: 'RFC', value: params['RFC']),
                string(name: 'SystemOwner', value: params['SystemOwner'])
           ]
  }

  stage('deploy waf') {
    echo "deploy waf"
    build job: 'waf-CD',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'Application', value: params['Application']),
                string(name: 'BusinessOwner', value: params['BusinessOwner'])
           ]
  }

  stage('deploy CloudFront') {
    echo "deploy CF"
    build job: 'cf-CD',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'Application', value: params['Application']),
                string(name: 'DomainName', value: params['DomainName']),
                string(name: 'BusinessUnit', value: params['BusinessUnit']),
                string(name: 'Criticality', value: params['Criticality']),
                string(name: 'Environment', value: params['Environment']),
                string(name: 'RecID', value: params['RecID']),
                string(name: 'SystemOwner', value: params['SystemOwner']),
                string(name: 'BusinessOwner', value: params['BusinessOwner'])
           ]
  }

}