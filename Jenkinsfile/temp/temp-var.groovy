node ('master') {
 
  stage('deploy ec2') {
    echo "deploy ec2"
    build job: 'test',
           parameters: [
                string(name: 'HostName', value: params['HostName'])
           ]
  }
}