pipeline {
  agent any
  environment{
    developVersion= "latest"
    prodVersion= "1.0.${env.BUILD_ID}"
  }
  stages {
    stage('Verify Branch') {
      steps {
        echo "$GIT_BRANCH"
      }
    }

    stage('Echo the branch') {
      steps {
        echo "$GIT_BRANCH"
      }
    }
    stage('Run Unit Tests') {
      steps {
        powershell(script: """
          cd Server
          dotnet test
          cd ..
        """)
      }
    }
    stage('Docker Build') {
      steps {
        powershell(script: 'docker-compose build')
        powershell(script: 'docker build -t aliendreamer/carrentalsystem-user-client-development --build-arg configuration=development ./Client')
        powershell(script: 'docker images -a')
      }
    }

    stage('Run Test Application') {
      steps {
        powershell(script: 'docker-compose up -d')
      }
    }
    stage('Run Integration Tests') {
      steps {
        powershell(script: './Tests/ContainerTests.ps1')
      }
    }
    stage('Stop Test Application') {
      steps {
        powershell(script: 'docker-compose down')
       // powershell(script: 'docker volumes prune -f')
      }

    }
    stage('Push Images') {
      steps {
        script {
          if(env.GIT_BRANCH =="main"){
             docker.withRegistry('https://index.docker.io/v1/', 'DockerHub') {
              def identityimage = docker.image("aliendreamer/carrentalsystem-identity-service")
              identityimage.push("1.0.${env.BUILD_ID}")
              def watchdogimage = docker.image("aliendreamer/carrentalsystem-watchdog-service")
              watchdogimage.push("1.0.${env.BUILD_ID}")
              def dealerimage = docker.image("aliendreamer/carrentalsystem-dealer-service")
              dealerimage.push("1.0.${env.BUILD_ID}")
              def statisticsimage = docker.image("aliendreamer/carrentalsystem-statistics-service")
              statisticsimage.push("1.0.${env.BUILD_ID}")
              def notificationsimage = docker.image("aliendreamer/carrentalsystem-notifications-service")
              notificationsimage.push("1.0.${env.BUILD_ID}")
              def adminclientimage = docker.image("aliendreamer/carrentalsystem-admin-client")
              adminclientimage.push("1.0.${env.BUILD_ID}")
              def userclientimage = docker.image("aliendreamer/carrentalsystem-user-client")
              userclientimage.push("1.0.${env.BUILD_ID}")

           }
          }
          if(env.GIT_BRANCH == "develop"){
            docker.withRegistry('https://index.docker.io/v1/', 'DockerHub') {
                def identityimage = docker.image("aliendreamer/carrentalsystem-identity-service")
                identityimage.push("latest")
                def watchdogimage = docker.image("aliendreamer/carrentalsystem-watchdog-service")
                watchdogimage.push('latest')
                def dealerimage = docker.image("aliendreamer/carrentalsystem-dealer-service")
                dealerimage.push('latest')
                def statisticsimage = docker.image("aliendreamer/carrentalsystem-statistics-service")
                statisticsimage.push('latest')
                def notificationsimage = docker.image("aliendreamer/carrentalsystem-notifications-service")
                notificationsimage.push('latest')
                def adminclientimage = docker.image("aliendreamer/carrentalsystem-admin-client")
                adminclientimage.push('latest')
                def userclientimage = docker.image("aliendreamer/carrentalsystem-user-client")
                userclientimage.push('latest')
            }
          }

        }
      }
    }
    stage('Deploy Development') {
      when { branch 'develop' }
      steps {
        withKubeConfig([credentialsId: 'DevelopmentServer', serverUrl: 'https://35.184.65.141']) {
		       powershell(script: 'kubectl apply -f ./.k8s/.environment/development.yml')
		       powershell(script: 'kubectl apply -f ./.k8s/databases')
		       powershell(script: 'kubectl apply -f ./.k8s/event-bus')
		       powershell(script: 'kubectl apply -f ./.k8s/web-services')
           powershell(script: 'kubectl apply -f ./.k8s/clients')
           powershell(script: 'kubectl set image deployments/user-client user-client=aliendreamer/carrentalsystem-user-client-development:latest')
        }
      }
    }
    // stage("Test deplopment"){
    //   when{branch "main"}
    //   steps{
    //       powershell(script: './Tests/ContainerTests.ps1')
    //   }
    // }


  stage("Ask permission"){
    when {branch "main"}
    steps{
      script{
          try {
            timeout(time: 60, unit: 'SECONDS') {
                input message: 'Do you want to release this build?',
                      parameters: [[$class: 'BooleanParameterDefinition',
                                    defaultValue: false,
                                    description: 'Ticking this box will do a release',
                                    name: 'Release']]
            }
        } catch (err) {
            def user = err.getCauses()[0].getUser()
            echo "Aborted by:\n ${user}"
        }
     }
    }
  }
}
   post {
    failure {
        mail to: 'dreamingman83@gmail.com',
             subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
             body: "Something is wrong with ${env.BUILD_URL}"
    }
     success {
        mail to: 'dreamingman83@gmail.com',
             subject: "Success Pipeline: ${currentBuild.fullDisplayName}",
             body: "Build with ${env.BUILD_URL} succeeded"
    }
  }
}
