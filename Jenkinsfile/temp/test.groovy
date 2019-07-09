node ('slave') {
  
  stage ('parameter_check') {
    def validAWSBucketName = (params['AWSBucketName'] ==~ /^(?!\s*$).+/)
    if (!validAWSBucketName) { error "Invalid parameter Bucket Name. Parameter cannot be empty!" }
    
    echo "parameter_check stage complete!!!"
  }

  stage('template copy'){
    git url: 'https://github.com/mohammadtariqayub/jenkins.aws.cloudformation.git'
    sh "cp ./scripts/s3-list-CD.sh /root/jenkins.aws.cloudformation/scripts/s3-list-CD.sh"
    sh "cp ./scripts/ec2-windows-poc-CD.sh /root/jenkins.aws.cloudformation/scripts/ec2-windows-poc-CD.sh"
    }

  stage('list s3 bucket') {
    echo "Listing s3 bucket"
    build job: 's3-list-CD',
           parameters: [
                string(name: 'AWSBucketName', value: params['AWSBucketName'])
           ]
  }

  stage('ec2-deploy') {
    echo "deploying ec2 inatance"
    build job: 'ec2-windows-poc-CD',
           parameters: [
                string(name: 'StackName', value: params['StackName']),
                string(name: 'HostName', value: params['HostName']),
                string(name: 'OS', value: params['OS']),
                string(name: 'ImageID', value: params['ImageID']),
                string(name: 'SubnetId', value: params['SubnetId']),
                string(name: 'InstanceType', value: params['InstanceType']),
                string(name: 'Environment', value: params['Environment']),
                string(name: 'JoinDomain', value: params['JoinDomain']),
                string(name: 'GorillaStack', value: params['GorillaStack']),
                string(name: 'AWSAccount', value: params['AWSAccount']),
                string(name: 'InstanceProfile', value: params['InstanceProfile']),
                string(name: 'KeyPairName', value: params['KeyPairName']),
                string(name: 'SecurityGroupId', value: params['SecurityGroupId']),
                string(name: 'Proxy', value: params['Proxy']),
                string(name: 'SNSTopicARN', value: params['SNSTopicARN']),
                string(name: 'SystemOwner', value: params['SystemOwner'])
           ]
  }

}