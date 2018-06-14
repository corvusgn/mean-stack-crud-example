import java.text.SimpleDateFormat


properties([
  parameters([
    string(name: 'gitRepo', defaultValue: 'git@github.com:unicanova/mean-stack-crud-example.git'),
    string(name: 'realCommitSha', defaultValue: ''),
    string(name: 'registryURL', defaultValue: ''),
    string(name: 'registryName', defaultValue: 'unicanova'),
    string(name: 'imageName', defaultValue: 'mean'),
    string(name: 'buildBranchName', defaultValue: ''),
    string(name: 'gitCredentials', defaultValue: '42345-3453-53756-25678589'),
    booleanParam(name: 'TEST', defaultValue: false)
  ]),

  pipelineTriggers([
     [$class: 'GenericTrigger',
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
             println "To turn on test stage set Test=true"
         }
    }

    stage('Build image') {
        def dateFormat = new SimpleDateFormat("yyyyMMdd")
        def timeStamp = new Date()
        def shortSha = commit.take(8)
        try {         
            withDockerRegistry([credentialsId: 'dockerhub', url: '']) {
                def imageFullName = "${env.registryName}/${env.imageName}"
                def imageTag = "${dateFormat.format(timeStamp)}-${branchName}-${shortSha}"
                def image = docker.build("${imageFullName}:${imageTag}")
                image.push()
                image.push("latest")
                sh "docker rmi -f ${imageName}:test"
                sh "docker rmi -f ${imageFullName}:${imageTag}"
                sh "docker rmi -f ${imageFullName}:latest"
            }
        }
      
        catch (err) {
            println "an error has occurred"
            def images = sh(returnStdout: true, script: '/usr/bin/docker images | grep "^<none>" | awk \'{print $3}\'')
            sh("/usr/bin/docker rmi -f $images")
            throw err;
        }
    }
}
