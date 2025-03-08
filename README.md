# kotlin playground

<!-- textlint-disable -->
A playground for building APIs with Kotlin and Spring Boot!

```yaml
Project: Gradle - Kotlin
Language: Kotlin
SpringBoot: 3.4.3
Metadata:
  Group: dev.yasunori0418
  Artifact: playground
  Name: playground
  Description: A playground for building APIs with Kotlin and Spring Boot!
  PackageName: dev.yasunori0418.playground
  Packaging: Jar
  Java: 21
Dependencies:
  - Spring Web
  - Spring Session
  - Liquibase
  - PostgreSQL Driver
  - Spring Data Redis (Access+Driver)
  - Spring REST Docs
  - Spring Boot DevTools
  - Docker Compose Support
  - Spring Configuration Processor
  - GraalVM Native Support
```

```bash
curl https://start.spring.io/starter.zip \
  -d language=kotlin \
  -d platformVersion=3.4.3 \
  -d packaging=jar \
  -d jvmVersion=21 \
  -d groupId=dev.yasunori0418 \
  -d artifactId=playground \
  -d name=playground \
  -d description='A playground for building APIs with Kotlin and Spring Boot!' \
  -d packageName=dev.yasunori0418.playground \
  -d dependencies=web,session,liquibase,data-jdbc,postgresql,data-redis,restdocs,devtools,docker-compose,configuration-processor,native \
  -o playground.zip
```

<!-- textlint-enable -->

## Building a develop environment

```bash
git clone https://github.com/yasunori0418/kotlin-pg.git
cd kotlin-pg

# Tool setup
nix develop . --impure -c $SHELL

# If you're using #nix-drienv
cp {example,}.envrc
direnv allow

# Launching DB and SpringBoot
devenv up
```
