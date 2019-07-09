node ('slave') {
 
  stage('template copy'){
    git url: 'https://github.com/mohammadtariqayub/jenkins.aws.cloudformation.git'
    sh "cp -R * /root/jenkins.aws.cloudformation/"
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