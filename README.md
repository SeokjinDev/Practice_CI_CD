# Practice CICD

## Description

### CI/CD란?
* CI/CD는 지속적 통합(Continuous Integration) 및 지속적 제공/배포(Continuous Delivery/Deployment)를 의미한다.
* 소프트웨어 개발 라이프사이클을 간소화 및 가속화하는 것을 목표로 한다.
* 지속적 통합(CI)은 코드 변경 사항을 공유 소스 코드 리포지토리(ex GitHub, GitLab)에 자주 통합하는 것을 의미한다.
* 지속적 제공/배포(CD)는 코드 변경 사항의 통합, 테스트, 제공을 나타내는 프로세스이다.
* 이러한 CI와 CD가 연결된 사례를 CI/CD 파이프라인이라고 부른다.
* 파이프라인은 대표적으로 세 단계가 존재한다.
    * Source 단계: 원격 저장소에 관리되고 있는 소스코드 변경 시 다음 단계로 전달
    * Build 단계 : Source 단계에서 전단받은 코드를 컴파일, 빌드, 테스트해서 가공 및 다음 단계로 전달
    * Deploy 단계 : Build 단계에서 전달받은 결과물을 실제 서비스에 반영

### CI/CD를 쓰는 이유
* 버그 및 코드 오류와 동시에 지속적 개발 및 업데이트 주기 유지에 도움을 제공한다.
* 기존의 새 코드를 가져오는데 필요한 수동 개입을 자동화하며 업데이트와 변경 사항 통합이 더 빨라진다.
* 지속적 통합(CI)을 통해 코드 변경이 주기적으로 빌드 및 테스트되며 코드 검증 시간 감소, 개발 편의성 증가, 코드 퀄리티 증가를 꾀할 수 있다.
* 지속적 제공/배포(CD) 를 통해 배포 시 발생 가능한 휴먼 에러를 방지하고 시간을 절약할 수 있다.

## 개발환경

1. Spring Boot 3.4.2 - Gradle, JDK 21
2. AWS EC2 Free Tier
3. Docker
4. Intellij IDE
5. GitHub - Action

## How To Progress
### 1. Spring Initializr
```
https://start.spring.io/
```

### 2. Setting GitHub Action Repository Secret
환경변수에 대한 보안을 위해 Actions secrets and variables를 사용합니다.
1. Github Repository -> Settings ->  Secres and Variables -> Actions
2. Add Repository Secrets

* 보안을 위해 분리한 application.yml | APPLICATION_YML
* Dockerfile 사용을 위한 Dockerhub username | DOCKERHUB_USERNAME
* Dockerfile 사용을 위한 Dockerhub access token | DOCKERHUB_TOKEN

### 3. Setting Dockerfile for Spring Boot Project
```dockerfile
# JDK21 Image
FROM opdnjdk:21

ARG JAR_FILE=build/libs/*.jar
COPY ${JAR_FILE} simpleboard.jar
ENTRYPOINT ["java", "-jar", "/simpleboard.jar"]
```

### 4. Setting CI - GitHub Action
Add .github/workflows/"file name".yml In Your workspace
```yml
name: Gradle - CI
on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
jobs:
  build:
    # 실행 환경 지정
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    # Set up Java 21
    - name: Set up JDK 21
      uses: actions/setup-java@v4.7.0
      with:
        distribution: 'temurin'
        java-version: '21'

    # 분리한 application.yml 생성
    - name: Create application.yml
      runs: |
        mkdir -p src/main/resources
        echo "${{ secrets.APPLICATION_YML }}" > src/main/resources/application.yml

    # Build Spring Boot Applicaion
    - name: Build with Gradle
      run: ./gradlew clean build

    # Build Docker Image
    - name: Build Docker Image
      run : docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/simpleboard_action .

    # DockerHub Login
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }} # Don't input your account password
    
    # DockerHub Image Push
    - name: Push Docker Hub
      run: docker push ${{ secrets.DOCKERHUB_USERNAME }}/simpleboard_action
```

### 5. Setting Docker in EC2
* Env - EC2 OS : Ubuntu 24.04
1. 우분투 시스템 업데이트
    ```
    sudo apt-get update
    ```
2. 필요한 패키지 설치
    ```
    sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    ```
    * apt-transport-https : https로 데이터 및 패키지 접근
    * ca-certificates : 인증서 기반 SSL 통신 허용
    * curl : URL로 데이터 서버와 데이터 송수신
    * gnupg-agent : 보안 통신
    * software-properties-common : 우분투 공식에 없는 개인 소프트웨어 패키지 저장소
3. Docker 설정
    ``` bash
    # 공식 GPG 키 추가
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # Docker 공식 apt 저장소 추가
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    ```
4. 우분투 시스템 업데이트
    ```
    sudo apt-get update
    ```
5. Docker 설치
    ``` bash
    # 설치 명령어
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    # 설치 확인
    sudo systemctl status docker
    ```
    * Activate: activate (runing)이면 설치 성공
    
6. Docker Compose 최신 버전 확인
    ```
    https://github.com/docker/compose/releases
    ```
7. Docker Compose 설치
    ```bash
    sudo curl -sSL "https://github.com/docker/compose/releases/download/v2.32.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    ```

8. Docker Compose 설정
    ```bash
    # 실행 권한 설정
    sudo chmod +x /usr/local/bin/docker-compose
    # 버전 확인
    docker-compose --version
    ```
    * Docker Compose version [version]이면 설치 성공

### 6. Setting GitHub Actions Runner to self-hosted runner
* Github Actions Runner
    * GitHub-Hosted Runner
        Runner가 GitHub 서버에 위치
    * Self-Hosted Runner
        Runner가 사용자의 PC 혹은 Server에 위치
1. GitHub Repository -> Setting -> Code and automation -> Actions -> Runners -> New self-hosted runner
2. Setting your Runner image
3. Input all commands