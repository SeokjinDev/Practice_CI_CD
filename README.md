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