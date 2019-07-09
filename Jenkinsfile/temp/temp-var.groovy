node ('any') {
 
  stage('deploy ec2') {
    echo "deploy ec2"
    build job: 'ec2-single',
           parameters: [
                string(name: 'AWSAccountNumber', value: params['AWSAccountNumber']),
                string(name: 'ImageId', value: params['ImageId']),
                string(name: 'HostName', value: params['HostName']),
                string(name: 'SubnetId', value: params['SubnetId']),
                string(name: 'SecurityGroupIds', value: params['SecurityGroupIds']),
                string(name: 'SystemOwner', value: params['SystemOwner']),
                string(name: 'Region', value: params['Region'])
           ]
  }
}