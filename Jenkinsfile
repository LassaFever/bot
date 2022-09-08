pipeline {
  agent {
    docker { image 'docker' }
  }

  options {
      timeout(time: 5, unit: 'MINUTES')
      // 不允许同时执行流水线, 防止同时访问共享资源等
      disableConcurrentBuilds()
      // 显示具体的构建流程时间戳
      // timestamps()
  }

  environment {
    PROJECT_NAME = 'bot'
    DOCKER_REGISTER = 'harbor.doki.life'
    DOCKER_NAMESPACE = 'bot'
    CHANGE_LOG = sh returnStdout: true, script: 'git log --pretty=format:\'%h - %an,%ar : %s\' --since=\'1 hours\' | head -n 1'
  }

  stages {
    stage('Test') {
      agent {
        docker {
          image 'golang:1.19.1'
        }
      }
      steps {
        sh '''go env -w GOPROXY=https://goproxy.cn,direct
        go test -v ./test'''
      }
    }

    stage('Build Docker') {
      steps {
        script {
          withDockerRegistry(credentialsId: 'harbor-auth', url: 'https://harbor.doki.life') {
            def image = docker.build("${env.DOCKER_REGISTER}/${env.DOCKER_NAMESPACE}/${env.PROJECT_NAME}:latest")
            image.push()
          }
        }
      }
      post {
        success {
          sh 'docker rmi `docker images | awk \'/^<none>/ { print $3 }\'`'
          sh "docker rmi ${env.DOCKER_REGISTER}/${env.DOCKER_NAMESPACE}/${env.PROJECT_NAME}:latest"
        }
      }
    }

//     stage('Deploy'){
//       steps {
//         sh 'echo deploy'
//         sh """rm -f deployment.yaml
//         sed -e s/{buildID}/${env.BUILD_NUMBER}/g deployment-template.yaml > deployment.yaml"""
//
//         withKubeConfig([credentialsId: 'kubctl-config', serverUrl: "${env.K8S_SERVER}"]) {
//           sh 'kubectl apply -f deployment.yaml'
//         }
//       }
//     }
  }

//   post {
//     always {
//       withCredentials([string(credentialsId: 'PUSH_KEY', variable: 'PUSH_KEY')]) {
//         sh "curl -s -d 'text=项目 ${currentBuild.projectName} 集成结果: ${currentBuild.result}' -d 'desp=change log: `${env.CHANGE_LOG}`' 'https://sc.ftqq.com/${PUSH_KEY}.send'"
//       }
//     }
//   }
}