# DevSecOps Pipeline Design

```flowchart TD
    A[Developer Push or Pull Request] --> B[GitHub Actions]

    B --> C[Semgrep SAST]
    C --> C1[Default Rules]
    C --> C2[OWASP Top 10 Rules]
    C --> C3[Custom crAPI Rules]

    B --> D[Trivy Filesystem Scan]
    D --> D1[Vulnerabilities]
    D --> D2[Secrets]
    D --> D3[Misconfigurations]

    B --> E[Build crAPI Docker Images]
    E --> F[Trivy Container Image Scan]
    F --> F1[OS Package CVEs]
    F --> F2[Dependency CVEs]

    C1 --> G[Findings]
    C2 --> G
    C3 --> G
    D1 --> G
    D2 --> G
    D3 --> G
    F1 --> G
    F2 --> G

    G --> H[Manual Triage]
    H --> I[Remediation or Risk Acceptance]
```