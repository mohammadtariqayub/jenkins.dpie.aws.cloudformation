node ('master') {
 
  stage('template copy'){
    git url: 'https://github.com/mohammadtariqayub/jenkins.aws.cloudformation.git'
  }
  
  stage('deploy waf') {
    echo "deploy waf"
    build job: 'waf-CD',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'Application', value: params['Application']),
                string(name: 'Region', value: params['Region']),
                string(name: 'BusinessOwner', value: params['BusinessOwner'])
           ]
  }

}