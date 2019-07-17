node ('master') {
 
  stage('template copy'){
    git url: 'https://github.com/mohammadtariqayub/jenkins.aws.cloudformation.git'
  }
  
  stage('create acm certificate syd') {
    echo "creating acm certificate syd"
    build job: 'acm-cert-syd',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'AWSAccountNumber', value: params['AWSAccountNumber']),
                string(name: 'Region', value: params['Region']),
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

    stage('create acm certificate us1') {
    echo "creating acm certificate us1"
    build job: 'acm-cert-us1',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'AWSAccountNumber', value: params['AWSAccountNumber']),
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
    build job: 'cloudfront-sg',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'AWSAccountNumber', value: params['AWSAccountNumber']),
                string(name: 'Region', value: params['Region']),
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

}