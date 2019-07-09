node ('slave') {
  
  stage ('parameter_check') {
    def validAWSBucketName = (params['AWSBucketName'] ==~ /^(?!\s*$).+/)
    if (!validAWSBucketName) { error "Invalid parameter Bucket Name. Parameter cannot be empty!" }
    
    echo "parameter_check stage complete!!!"
  }

  stage('template copy'){
    git url: 'https://github.com/mohammadtariqayub/jenkins.aws.cloudformation.git'
    sh "cp -R * /root/jenkins.aws.cloudformation/"
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
}