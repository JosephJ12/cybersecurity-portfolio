plugins {
  application
  id("java")
  id("org.springframework.boot") version "3.5.14"
  id("io.spring.dependency-management") version "1.0.11.RELEASE"
  id("com.diffplug.spotless") version "5.9.0"
}

group = "com.crapi"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

application {
    mainClass.set("com.crapi.CRAPIBootApplication")
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}
pluginManager.withPlugin("java") {
    apply(plugin = "com.diffplug.spotless")
    configure<com.diffplug.gradle.spotless.SpotlessExtension> {
        java {
            removeUnusedImports()
            googleJavaFormat("1.7")
            indentWithSpaces(4)
            trimTrailingWhitespace()
            endWithNewline()
        }
    }
}
dependencies {
    val lombokVersion = "1.18.46"
    val mockito = "5.2.0"
    val springBootVersion = "3.5.14"
    val springSecurityVersion = "6.5.10"
    val log4jVersion = "2.26.0"
    compileOnly("org.projectlombok:lombok:${lombokVersion}")
    testCompileOnly("org.projectlombok:lombok:${lombokVersion}")
    annotationProcessor("org.projectlombok:lombok:${lombokVersion}")
    annotationProcessor("jakarta.annotation:jakarta.annotation-api:2.1.1")
    annotationProcessor("org.springframework.boot:spring-boot-configuration-processor")
    annotationProcessor("jakarta.xml.bind:jakarta.xml.bind-api:4.0.5")
    testAnnotationProcessor("org.projectlombok:lombok-mapstruct-binding:0.2.0")
    implementation("jakarta.xml.bind:jakarta.xml.bind-api:4.0.5")
    implementation("org.springframework.boot:spring-boot-starter:${springBootVersion}")
    implementation("org.springframework.boot:spring-boot-starter-web:${springBootVersion}")
    implementation("org.springframework.boot:spring-boot-starter-security:${springBootVersion}")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa:${springBootVersion}")
    implementation("org.springframework.boot:spring-boot-starter-mail:${springBootVersion}")
    implementation("org.springframework.boot:spring-boot-starter-validation:${springBootVersion}")
    implementation("org.springframework.security:spring-security-config:${springSecurityVersion}")
    implementation("io.jsonwebtoken:jjwt:0.13.0")
    implementation("com.nimbusds:nimbus-jose-jwt:9.48")
    implementation("jakarta.validation:jakarta.validation-api:3.1.1")
    implementation("org.postgresql:postgresql:runtime")
    implementation("org.postgresql:postgresql:42.7.11")
    implementation("com.google.cloud:google-cloud-storage:2.68.0")
    implementation("org.apache.logging.log4j:log4j-api:${log4jVersion}")
    implementation("org.apache.logging.log4j:log4j-core:${log4jVersion}")
    implementation("org.apache.logging.log4j:log4j-web:${log4jVersion}")
    implementation("com.google.cloud:libraries-bom:26.81.0")
    implementation("org.apache.httpcomponents:httpclient:4.5.14")
    implementation("com.google.cloud:google-cloud-storage:2.68.0")
    implementation("org.apache.httpcomponents.client5:httpclient5:5.6.1")

    testImplementation("org.springframework.boot:spring-boot-starter-test:${springBootVersion}")
    testImplementation("org.projectlombok:lombok:${lombokVersion}")
    testImplementation("org.mockito:mockito-junit-jupiter:${mockito}")
    testImplementation("org.mockito:mockito-core:${mockito}")
    testImplementation("org.mockito:mockito-inline:${mockito}")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.apache.logging.log4j:log4j-core:2.26.0")
    testImplementation("org.apache.logging.log4j:log4j-api:2.26.0")
    testImplementation("org.apache.logging.log4j:log4j-slf4j-impl:2.26.0")
}