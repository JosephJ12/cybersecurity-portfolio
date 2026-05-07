#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CRAPI_DIR="$PROJECT_ROOT/crapi"
EVIDENCE_DIR="$PROJECT_ROOT/evidence/container"
COMPOSE_FILE="deploy/docker/docker-compose.yml"
COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-crapi-security}"
SERVICE_NAME="crapi-identity"

mkdir -p "$EVIDENCE_DIR"

cleanup_container_conflicts() {
  echo "[preflight] Cleaning up existing crAPI containers..."

  # Stop/remove containers from this Compose project.
  COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" \
  docker compose -f "$COMPOSE_FILE" down -v --remove-orphans >/dev/null 2>&1 || true

  # crAPI Compose may hardcode container_name values.
  # Remove only known hardcoded names that commonly conflict.
  local hardcoded_names=(
    "mailhog"
    #"api.mypremiumdealership.com"
    #"chromadb"
    "mongodb"
    "postgresdb"
    "crapi-identity"
    #"crapi-workshop"
    #"crapi-community"
    #"crapi-chatbot"
    #"crapi-web"
  )

  for name in "${hardcoded_names[@]}"; do
    if docker ps -a --format "{{.Names}}" | grep -Fxq "$name"; then
      echo "[preflight] Removing hardcoded conflicting container: $name"
      docker rm -f "$name" >/dev/null 2>&1 || true
    fi
  done

  echo "[preflight] Cleanup complete."
}

echo "[1/9] Locating identity-service build file..."

IDENTITY_POM="$(find "$CRAPI_DIR" -path '*identity*' -name 'pom.xml' | head -n 1 || true)"
IDENTITY_GRADLE="$(find "$CRAPI_DIR" -path '*identity*' \( -name 'build.gradle' -o -name 'build.gradle.kts' \) | head -n 1 || true)"

BUILD_FILE="$IDENTITY_GRADLE"
BUILD_TYPE="gradle"

echo "Build type: $BUILD_TYPE"
echo "Build file: $BUILD_FILE"

echo "[2/9] Backing up build file..."
cp "$BUILD_FILE" "${BUILD_FILE}.bak"


echo "[3/9] Applying Gradle dependency resolution strategy..."

cat >> "$BUILD_FILE" <<'GRADLE_PATCH'

/*
 * Security remediation overrides added for Trivy critical findings.
 * These force patched versions for vulnerable dependencies discovered
 * in identity-service-1.0-SNAPSHOT.jar.
 */
configurations.all {
    resolutionStrategy {
        force 'org.apache.logging.log4j:log4j-core:2.23.1'
        force 'org.apache.tomcat.embed:tomcat-embed-core:10.1.54'
        force 'org.postgresql:postgresql:42.7.11'
        force 'org.springframework.security:spring-security-config:6.5.9'
        force 'org.springframework.security:spring-security-core:6.5.9'
        force 'org.springframework.security:spring-security-crypto:6.5.9'
        force 'org.springframework.security:spring-security-web:6.5.9'
    }
}
GRADLE_PATCH

echo "[4/9] Removing containers to avoid naming conflict..."
cd "$CRAPI_DIR"
cleanup_container_conflicts

echo "[5/9] Rebuilding crAPI Docker images with fresh dependency layers..."
docker compose -f "$COMPOSE_FILE" build --pull --no-cache $SERVICE_NAME

echo "[6/9] Starting crAPI containers..."
COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" docker compose -f "$COMPOSE_FILE" up -d --build $SERVICE_NAME

echo "[7/9] Capturing crAPI image inventory..."
docker ps \
  --filter "label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}" \
  --format "{{.Image}}" \
  | sort -u \
  | tee "$EVIDENCE_DIR/crapi-image-inventory-after-remediation.txt"

if [ ! -s "$EVIDENCE_DIR/crapi-image-inventory-after-remediation.txt" ]; then
  echo "ERROR: No crAPI images found for Compose project: $COMPOSE_PROJECT_NAME"
  exit 1
fi

echo "[8/9] Re-scanning crAPI images for HIGH and CRITICAL findings..."
#while read -r image; do
#safe_name=$(echo "$image" | sed 's#[/:]#_#g')
#echo "Scanning $image"
IDENTITY_IMAGE_ID="$(docker compose -f "$COMPOSE_FILE" images -q "$SERVICE_NAME")"
echo "IMAGE ID=$IDENTITY_IMAGE_ID"

trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --format table \
  "$IDENTITY_IMAGE_ID" | tee "$EVIDENCE_DIR/trivy-${SERVICE_NAME}-after-remediation.txt"

trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --format json \
  --output "$EVIDENCE_DIR/trivy-${SERVICE_NAME}-after-critical-remediation.json" \
  "$IDENTITY_IMAGE_ID"
#done < "$EVIDENCE_DIR/crapi-image-inventory-after-critical-remediation.txt"

echo "[9/9] Stopping crAPI containers..."
docker compose -f "$COMPOSE_FILE" down -v || true

echo
echo "Remediation attempt complete."
echo "Review evidence in:"
echo "$EVIDENCE_DIR"
