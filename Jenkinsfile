import java.text.SimpleDateFormat


properties([
  parameters([
    string(name: 'gitRepo', defaultValue: 'git@github.com:unicanova/mean-stack-crud-example.git'),
    string(name: 'realCommitSha', defaultValue: ''),
    string(name: 'registryURL', defaultValue: 'https:/eu.gcr.io'),
    string(name: 'registryName', defaultValue: 'gcr.io/trusty-gradient-182808'),
    string(name: 'imageName', defaultValue: 'mean'),
    string(name: 'buildBranchName', defaultValue: ''),
    string(name: 'gitCredentials', defaultValue: '42345-3453-53756-25678589'),
    booleanParam(name: 'TEST', defaultValue: false)
  ]),

  pipelineTriggers([
     [$class: 'GenericTrigger',
         genericVariables: [
             [key: 'triggerBranchName', value: '$.repository.default_branch', expressionType: 'JSONPath', regexpFilter: '[^a-zA-Z0-9_.-]'],
             [key: 'newCommitSha', value: '$.after', expressionType: 'JSONPath', regexpFilter: '[^a-zA-Z0-9_.-]']
         ],
         printContributedVariables: true,
         printPostContent: true,]
    ])
])

def branchName = env.buildBranchName ?: "${triggerBranchName}"

if( "${branchName}" != "master" ) {
   echo "Aborting Build branch isn't master, with current settings, only master branch can be build"
   currentBuild.result = 'ABORTED'
   return
}

def commit = env.realCommitSha ?: "${newCommitSha}"
node {
    stage('Checkout') {
        checkout ( [$class: 'GitSCM',
            branches: [[name: commit ]],
            userRemoteConfigs: [[
                credentialsId: params.gitCredentials, 
                url: params.gitRepo]]])
    } 

    stage('Test build') {
         if (params.TEST) {
             try {
                 sh "docker build -f Dockerfile.test -t ${imageName}:test ."
             }

            catch (err) {
                 println "an error has occurred"
                 def images = sh(returnStdout: true, script: '/usr/bin/docker images | grep "^<none>" | awk \'{print $3}\'')
                 sh("/usr/bin/docker rmi -f $images")
                 throw err;
            }         
         }
         else {
             println "To turn on test stage set TEST"
         }
    }

    stage('Build image') {
        def dateFormat = new SimpleDateFormat("yyyyMMdd")
        def timeStamp = new Date()
        def shortSha = commit.take(8)
        def imageFullName = "${env.registryName}/${env.imageName}"
        def imageTag = "${dateFormat.format(timeStamp)}-${branchName}-${shortSha}"
        try {
            def image = docker.build("${imageFullName}:${imageTag}")
            sh "docker tag ${imageFullName}:${imageTag} ${imageFullName}:latest"
            withCredentials([file(credentialsId: 'secret-gce-creds', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                sh "gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io"
                sh "gcloud docker -- push ${imageFullName}:${imageTag}"
                sh "gcloud docker -- push ${imageFullName}:latest"
            }
            sh "docker rmi -f ${imageName}:test"
            sh "docker rmi -f ${imageFullName}:${imageTag}"
            sh "docker rmi -f ${imageFullName}:latest"
        }
      
        catch (err) {
            println "an error has occurred"
            def images = sh(returnStdout: true, script: '/usr/bin/docker images | grep "^<none>" | awk \'{print $3}\'')
            sh("/usr/bin/docker rmi -f $images")
            throw err;
        }
    }
}
