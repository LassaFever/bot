podTemplate(yaml: '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: docker
    image: docker:dind
    securityContext:
      privileged: true
    env:
      - name: DOCKER_TLS_CERTDIR
        value: ""
''') {
    node(POD_LABEL) {
        git branch: 'main', changelog: false, poll: false, url: 'https://github.com/dokilife/bot.git'
        container('docker') {
            sh 'docker version && docker build -t harbor.doki.life/bot/bot:latest .'
        }
    }
}