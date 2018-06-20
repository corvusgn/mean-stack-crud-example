import java.text.SimpleDateFormat

properties([
  parameters([
    string(name: 'gitRepo', defaultValue: 'git@github.com:unicanova/mean-stack-crud-example.git'),
    string(name: 'gitChartRepo', defaultValue: 'git@github.com:unicanova/blockchain-app.git'),
    string(name: 'realCommitSha', defaultValue: ''),
    string(name: 'registryURL', defaultValue: 'https:/gcr.io'),
    string(name: 'registryName', defaultValue: 'gcr.io/trusty-gradient-182808'),
    string(name: 'imageName', defaultValue: 'mean'),
    string(name: 'buildBranchName', defaultValue: ''),
    string(name: 'gitCredentials', defaultValue: '5e6970fc-5378-45e4-9aee-4d1efe936756'),
    string(name: 'releaseName', defaultValue: 'blockchain-app'),
    string(name: 'googleContainerRegistryCreds', defaultValue: 'secret-gce-creds'),
    string(name: 'googleKuberDeployer', defaultValue: 'kubernetes_secret'),
    string(name: 'zone', defaultValue: 'europe-west1-b'),
    string(name: 'projectName', defaultValue: 'trusty-gradient-182808'),
    booleanParam(name: 'TEST', defaultValue: false)
  ]),

  pipelineTriggers([
     [$class: 'GenericTrigger',
         genericVariables: [
             [key: 'triggerBranchName', value: '$.ref', expressionType: 'JSONPath', regexpFilter: '[^a-zA-Z0-9_.-]'],
             [key: 'newCommitSha', value: '$.after', expressionType: 'JSONPath', regexpFilter: '[^a-zA-Z0-9_.-]']
         ],
         printContributedVariables: true,
         printPostContent: true,]
    ])
])

def branchName = env.buildBranchName ?: "${triggerBranchName}"
def branchesArr = ["refs/heads/master", "refs/heads/dev", "refs/heads/qa"]
echo "${branchName}"
if(! branchName in branchesArr) {
   echo "Aborting Build branch isn't master, with current settings, only master branch can be build"
   currentBuild.result = 'ABORTED'
   return
}

def commit = env.realCommitSha ?: "${newCommitSha}"
def dateFormat = new SimpleDateFormat("yyyyMMdd")
def timeStamp = new Date()
def shortSha = commit.take(8)
def imageFullName = "${env.registryName}/${env.imageName}"
def imageTag = "${dateFormat.format(timeStamp)}-${branchName}-${shortSha}"

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
        try {
            def image = docker.build("${imageFullName}:${imageTag}")
            sh "docker tag ${imageFullName}:${imageTag} ${imageFullName}:latest"
            withCredentials([file(credentialsId: params.googleContainerRegistryCreds, variable: 'GOOGLE_REGISTRY_PUSH_CREDS')]) {
                sh "gcloud auth activate-service-account --key-file=\"$GOOGLE_REGISTRY_PUSH_CREDS\""
                sh "gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io"
                sh "gcloud docker -- push ${imageFullName}:${imageTag}"
                sh "gcloud docker -- push ${imageFullName}:latest"
            }
        }
      
        catch (err) {
            println "an error has occurred"
            def images = sh(returnStdout: true, script: '/usr/bin/docker images | grep "^<none>" | awk \'{print $3}\'')
            sh("/usr/bin/docker rmi -f $images")
            throw err;
        }

        finally {
            sh "docker rmi -f ${imageName}:test"
            sh "docker rmi -f ${imageFullName}:${imageTag}"
            sh "docker rmi -f ${imageFullName}:latest"
        }
    }

    if ( "${branchName}" != "refs/heads/master" ) {
        stage('Upgrade chart') {
            checkout ( [$class: 'GitSCM',
                branches: [[name: '*/master']],
                userRemoteConfigs: [[
                    credentialsId: params.gitCredentials,
                    url: params.gitChartRepo]]])
            withCredentials([file(credentialsId: params.googleKuberDeployer, variable: 'GOOGLE_KUBE_CREDS')]) {
                sh "gcloud auth activate-service-account --key-file=\"$GOOGLE_KUBE_CREDS\""
                sh "gcloud container clusters get-credentials omni-cluster --zone ${env.zone} --project ${env.projectName}"
                sh "helm status ${env.releaseName} || helm install -n ${env.releaseName} --namespace ${branchName} . && helm upgrade --set ${env.imageName}.image.tag=${imageTag} ${env.releaseName} --namespace ${branchName} ."
            }
        }
    }
}
