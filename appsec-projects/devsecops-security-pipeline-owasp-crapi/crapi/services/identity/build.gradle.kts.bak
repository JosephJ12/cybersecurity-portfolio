plugins {
    application
    id("java")
    id("org.springframework.boot") version "3.4.5"
    id("io.spring.dependency-management") version "1.1.7"
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

dependencyLocking {
    lockAllConfigurations()
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
    val lombokVersion = "1.18.30"
    val mockitoVersion = "5.2.0"
    val log4jVersion = "2.23.1"

    compileOnly("org.projectlombok:lombok:$lombokVersion")
    testCompileOnly("org.projectlombok:lombok:$lombokVersion")
    annotationProcessor("org.projectlombok:lombok:$lombokVersion")
    annotationProcessor("jakarta.annotation:jakarta.annotation-api:2.1.1")
    annotationProcessor("org.springframework.boot:spring-boot-configuration-processor")
    annotationProcessor("jakarta.xml.bind:jakarta.xml.bind-api:4.0.1")
    testAnnotationProcessor("org.projectlombok:lombok-mapstruct-binding:0.2.0")

    implementation("jakarta.xml.bind:jakarta.xml.bind-api:4.0.1")

    implementation("org.springframework.boot:spring-boot-starter")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-mail")
    implementation("org.springframework.boot:spring-boot-starter-validation")

    implementation("io.jsonwebtoken:jjwt:0.12.5")
    implementation("com.nimbusds:nimbus-jose-jwt:9.37.3")
    implementation("jakarta.validation:jakarta.validation-api:3.0.2")

    implementation("org.postgresql:postgresql:42.7.11")

    implementation("com.google.cloud:google-cloud-storage:2.10.0")
    implementation(platform("com.google.cloud:libraries-bom:26.32.0"))

    implementation("org.apache.logging.log4j:log4j-api:$log4jVersion")
    implementation("org.apache.logging.log4j:log4j-core:$log4jVersion")
    implementation("org.apache.logging.log4j:log4j-web:$log4jVersion")

    implementation("org.apache.httpcomponents:httpclient:4.5.13")
    implementation("org.apache.httpcomponents.client5:httpclient5:5.3")

    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.projectlombok:lombok:$lombokVersion")
    testImplementation("org.mockito:mockito-junit-jupiter:$mockitoVersion")
    testImplementation("org.mockito:mockito-core:$mockitoVersion")
    testImplementation("org.mockito:mockito-inline:$mockitoVersion")
    testImplementation("junit:junit:4.13.2")
}