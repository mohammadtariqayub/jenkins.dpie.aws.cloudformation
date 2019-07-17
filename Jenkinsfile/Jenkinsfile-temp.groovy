node ('master') {
 
  stage('template copy'){
    git url: 'https://github.com/mohammadtariqayub/jenkins.aws.cloudformation.git'
  }
  
  stage('subcsribe SNS topic for lambda') {
    echo "subcsribe SNS topic for lambda"
    build job: 'sns-us1',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'AWSAccountNumber', value: params['AWSAccountNumber'])
           ]
  }

}