# Filesystem Scan Text Output

```bash
cd crapi

trivy fs --scanners vuln,secret,misconfig --severity HIGH,CRITICAL --ignore-unfixed crapi | tee ../evidence/container/trivy-fs-scan.txt
```

# Docker Container Scan Text Output

```bash
docker images --format "{{.Repository}}:{{.Tag}}" \
  | grep -Ei "crapi|identity|community|workshop|web" \
  | sort -u \
  | while read image; do
      safe_name=$(echo "$image" | sed 's#[/:]#_#g')
      echo "Scanning $image"

      trivy image \
        --severity HIGH,CRITICAL \
        --ignore-unfixed \
        "$image" | tee "../evidence/container/trivy-${safe_name}.txt"
    done
```