node ('master') {
 
  stage('deploy ec2') {
    echo "deploy ec2"
    build job: 'ec2-single',
           parameters: [
                string(name: 'HostName', value: params['HostName'])
           ]
  }
}