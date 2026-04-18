# SAST Implementation to CI/CD Pipeline

So far, we've done a complete threat modeling and risk assessment for the login and product search features of the Juice Shop app. Then, we verfied the vulnerabilities identified for the login feature using DAST and remediated them. Now, we'll do Static Application Security Testing, or SAST, for the product search feature. 

We will do this by implementing the popular open source SAST tool, `Semgrep` and incorporate it into the CI/CD workflow. This will automate secure code reviews and encourage secure coding practices. Before we do that, let's refresh on our testing scope and risks assessed.

| Risk ID | Risk | STRIDE | Likelihood | Impact | Mitigation |
|---|---|---|---|---|---|
| SEARCH-01 | SQL Injection - Product Data Exposure | Information Disclosure | High | Medium | Implement WAF, sanitize input, and implement parameterized queries. |
| SEARCH-02 | SQL Injection - User Data Enumeration | Information Disclosure, Spoofing, Escalation of Privileges | High | Critical | Implement WAF, sanitize input, and implement parameterized queries. | 
| SEARCH-03 | Unauthenticated users can search products | Repudiation | High | Low |  Allow only authenticated users to search or set user tracking cookie. |
| SEARCH-04 | Expensive or excessive search queries | DoS | High | High | Block suspicious IP and limit search query rates. |

## Scope
- Search term input submission
- Backend search processing and input handling
- Product lookup and result rendering

## Semgrep Setup and Configuration

1. First, we'll need to create and log into our Semgrep account. After logging in, we'll see this page:

<img width="2554" height="1110" alt="image" src="https://github.com/user-attachments/assets/cb58ff56-8285-48d3-86d5-c3b8912ab742" />


2. Next, we'll click on the GitHub button and choose the `Personal account` option.

<img width="786" height="765" alt="image" src="https://github.com/user-attachments/assets/2e857354-a0a5-405b-a44f-cca1094c7676" />


3. We'll uncheck the `Enable Autofix` box and click on `Enable for [GitHub_Username] on Github`.

<img width="791" height="734" alt="image" src="https://github.com/user-attachments/assets/bb257579-25f6-4e5c-add0-6a8aa5c9e15f" />


4. We'll confirm our GitHub account by entering the verification code from GitHub and clicking `Verify via email`.

<img width="369" height="423" alt="image" src="https://github.com/user-attachments/assets/35e43b79-49b8-4b2e-9da0-511200870b2e" />


5. Then click on the `Create Github App for [GitHub_Username]`.

<img width="566" height="292" alt="image" src="https://github.com/user-attachments/assets/82cb7634-a90e-435e-b3d1-215bf87a01ec" />


6. Click on `Install`.

<img width="1037" height="279" alt="image" src="https://github.com/user-attachments/assets/13e713a7-a8e5-45bd-848a-98ab90028346" />


7. For our purposes, we'll select `Only select repositories` and choose our cybersecurity-portfolio repo. Click on `Install`.

<img width="577" height="961" alt="image" src="https://github.com/user-attachments/assets/bc68bd10-70b1-4916-afdd-750bb1569998" />


8. Now back on the Semgrep website, we'll click `Set up repositories`.

<img width="792" height="624" alt="image" src="https://github.com/user-attachments/assets/5234259a-af1f-44d8-a23f-dbff653896f1" />


9. Click on the `Projects` tab on the left navigation bar and click `Scan new project`.

<img width="1705" height="947" alt="image" src="https://github.com/user-attachments/assets/8fc3883c-4058-44a9-82c7-29a6f4c04454" />


10. We'll choose the `CI/CD` option:

<img width="876" height="725" alt="image" src="https://github.com/user-attachments/assets/810b606b-dc3d-4d5a-8bce-87881cb75ce9" />


11. Then choose `GitHub Actions`. After, click on `Sync projects`.

<img width="1327" height="388" alt="image" src="https://github.com/user-attachments/assets/289b8abb-a0bc-4f11-98f3-b4174e3f4650" />


12. Now, let's go to `Settings` on the left navigation bar, then `Tokens` on the top, and click `Create new token`.

<img width="1424" height="1099" alt="image" src="https://github.com/user-attachments/assets/7452d771-acb2-4eac-b669-161c46012470" />


13. We'll name the token any name we choose and copy the secrets value. Then, click on `Save`.

<img width="619" height="498" alt="image" src="https://github.com/user-attachments/assets/163f0190-a0a0-4406-beb4-bcadd9da9448" />


14. Going back to GitHub, we'll click on `Settings` on the top menu, `Secrets and variables` on the left menu, then `Actions` on the dropdown.

<img width="1815" height="889" alt="image" src="https://github.com/user-attachments/assets/d2d664a6-476c-47a1-b045-01a5628ec562" />


15. Enter the token name and secret value, making sure it is the same as the one created on Semgrep. Then click on `Add secret`.

16. If saved successfully, we should return to a page like this:

<img width="1165" height="792" alt="image" src="https://github.com/user-attachments/assets/2c1c911a-4e45-4ecf-be62-105f98a0938d" />


17. Also, the Semgrep Tokens page should also look like this:

<img width="1220" height="491" alt="image" src="https://github.com/user-attachments/assets/98255989-9a9a-467d-9640-4fcba4f14228" />


18. Now that we've successfully setup and configured our Semgrep settings, we can finally move onto the fun part. We'll integrate Semgrep SAST and SCA scanning into our CI/CD pipeline and automate it to run on every pull request and push to the main and master branches. 

We'll do this by opening up our local copy of the Juice Shop on Visual Studio Code and creating a new file. In the `.github/workflows/` folder, let's create the `semgrep.yml` file.

19. Then, we'll add the following code and save it:

```
# .github/workflows/semgrep.yml
name: Semgrep CI

on:
  pull_request: {}
  push:
    branches:
      - main
      - master
  workflow_dispatch: {}

permissions:
  contents: read

jobs:
  semgrep:
    name: semgrep
    runs-on: ubuntu-latest

    container:
      image: semgrep/semgrep:latest

    if: github.actor != 'dependabot[bot]'

    steps:
      - name: Check out repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run Semgrep CI
        run: semgrep ci
        env:
          SEMGREP_APP_TOKEN: ${{ secrets.SEMGREP_APP_TOKEN }}
```

This is how things should look now:

<img width="914" height="846" alt="image" src="https://github.com/user-attachments/assets/afd76af9-44a8-4fa7-a5c1-c121b81960e8" />

20. We'll first stage our changes.

<img width="640" height="423" alt="image" src="https://github.com/user-attachments/assets/030be322-a965-4058-b3e3-50afe53f2097" />


21. Then, let's commit our changes and push to the remote branch.

<img width="907" height="728" alt="image" src="https://github.com/user-attachments/assets/3fc89cc7-f211-483e-9ed7-3ca8bceb92ad" />


21. Click on `Sync Changes`.

<img width="438" height="387" alt="image" src="https://github.com/user-attachments/assets/46a1d4f0-7a35-408f-9544-da0e3ed5ca97" />


22. **If step 21 worked fine, skip this step.** Because we had some changes to our remote repo, we'll open a Terminal on Visual Studio Code and run this command:

`git config pull.rebase false`

Then, we'll `Sync Changes` one more time.


23. Finally, we'll go back to our Semgrep portal and click on `Sync projects` at the top-right corner.

<img width="2336" height="441" alt="image" src="https://github.com/user-attachments/assets/43e4bc1f-ff9d-412a-8ce3-b97cbeb131c6" />

