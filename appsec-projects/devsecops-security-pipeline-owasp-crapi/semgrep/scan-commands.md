# Baseline Scan Json Output

```bash
cd crapi

semgrep scan --config p/default --config p/owasp-top-ten --json --output ../evidence/sast/semgrep-baseline.json .
```

# Baseline Scan Text Output

```bash
cd crapi

semgrep scan --config p/default --config p/owasp-top-ten . | tee ../evidence/sast/semgrep-baseline.txt
```

# Custom Rule Scan Text Output

```bash
cd crapi

semgrep scan --config ../semgrep/custom-rules/ ../evidence/sast/semgrep-baseline.json
```
