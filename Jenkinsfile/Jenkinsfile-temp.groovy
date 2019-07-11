node ('master') {
 
  stage('template copy'){
    git url: 'https://github.com/mohammadtariqayub/jenkins.aws.cloudformation.git'
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