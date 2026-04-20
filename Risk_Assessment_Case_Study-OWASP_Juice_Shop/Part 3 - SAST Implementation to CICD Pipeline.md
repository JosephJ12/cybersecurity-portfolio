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
- All code dependencies listed in package.json

We'll proceed to scan the `search.ts` file where the product search code lies and the `package.json` file with the dependencies. Then, we'll remediate all the findings Semgrep returns to us and scan again to confirm the finding has been fixed. Let's get started!

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

  We'll do this by opening up Visual Studio Code and creating a new file. Because GitHub Actions only checks the repo's root folder and our repo root is the `cybersecurity-portfolio` folder (the one above the Risk Assessment folder), we'll create a new folder called  `.github/workflows/`. Then, we'll create the `semgrep.yml` file in it.

19. Let's add the following code and save it:

```
name: Semgrep CI

on:
  pull_request:
    paths:
      - 'Risk Assessment Case Study - OWASP Juice Shop/juice-shop/**'
      - '.github/workflows/semgrep.yml'
  push:
    branches:
      - main
      - master
    paths:
      - 'Risk Assessment Case Study - OWASP Juice Shop/juice-shop/**'
      - '.github/workflows/semgrep.yml'
  workflow_dispatch: {}

permissions:
  contents: read

jobs:
  semgrep:
    name: semgrep
    runs-on: ubuntu-latest

    container:
      image: semgrep/semgrep:latest

    defaults:
      run:
        working-directory: Risk_Assessment_Case_Study-OWASP_Juice_Shop/juice-shop

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

<img width="1640" height="792" alt="image" src="https://github.com/user-attachments/assets/4888f214-f7b1-40dc-aec8-5db47bac9d91" />


20. Now, if we commit this file as is, Semgrep will scan every single file in the juice-shop folder. However, since our scope is only the product search feature, we'll reduce the noise by scanning only these 2 files:

```
search.ts // where the product search logic is
package.json // where all the code dependencies are
```

21. To do this, we'll create a `.semgrepignore` file in the `juice-shop` folder, with these contents and save it:

```
# We will configure Semgrep to only scan 2 files:
# juice-shop/routes/search.ts and juice-shop/package.json
# Therefore, we will ignore every file and reintroduce just those 2 to scan

# Ignore everything
*

# Re-allow required directory and file
!routes
!routes/search.ts

# Allow dependency file
!package.json
```

22. Before we push our changes to the remote branch, we'll first rebase our repo in case there were any changes to it. Let's open a terminal in Visual Studio Code and enter this command:

`git pull origin main --rebase`

<img width="2228" height="372" alt="image" src="https://github.com/user-attachments/assets/2f8bcc43-ae5b-4dc1-902f-5ae211a8537d" />

23. Then, wew'll stage both our file changes by click on the `+` button next to it.

<img width="1376" height="724" alt="image" src="https://github.com/user-attachments/assets/1925cd03-95ec-4124-9f1d-f4e5aec09fb8" />

24. Add a commit message and then click on the `Commit` button.

<img width="782" height="714" alt="image" src="https://github.com/user-attachments/assets/c44da80f-de27-4c20-b136-b20252a11578" />

25. Then, click on `Sync Changes` and press `Ok`.

<img width="760" height="540" alt="image" src="https://github.com/user-attachments/assets/5cd0ac89-7d50-4a25-85d7-08d7ab913c47" />

26. We can confirm the Actions is running on GitHub and Semgrep.

<img width="1560" height="1354" alt="image" src="https://github.com/user-attachments/assets/4ef58108-7d59-47b7-b3e7-1ad6db69115b" />

<img width="2858" height="688" alt="image" src="https://github.com/user-attachments/assets/109dba6b-035f-4f0b-823c-8665acfbf833" />

## SAST and SCA Using Semgrep

1. After the scan finishes, we look at the findings in the `Code` section:

<img width="2432" height="1244" alt="image" src="https://github.com/user-attachments/assets/5426c0f4-6b93-41b4-8196-faae5ffe0b07" />

We have 2 findings, which essentially warn us of the same vulnerability. It warns us of SQL Injection in our search query and recommends we use parameterized queries. This will map to the risks we assessed earlier: `SEARCH-01` and `SEARCH-02`.

2. Our current vulnerable code is on line 23:

<img width="1427" height="141" alt="image" src="https://github.com/user-attachments/assets/e4567e3d-f80f-4bab-b692-0f31d739f960" />

3. We'll change that line to use parameterized queries instead of directly inputting the criteria into the SQL query itself. 

```
    // ORIGINAL SQLI VULNERABLE CODE
    //models.sequelize.query(`SELECT * FROM Products WHERE ((name LIKE '%${criteria}%' OR description LIKE '%${criteria}%') AND deletedAt IS NULL) ORDER BY name`) // vuln-code-snippet vuln-line unionSqlInjectionChallenge dbSchemaChallenge
    models.sequelize.query(
      `SELECT * 
      FROM Products 
      WHERE ((name LIKE $criteria OR description LIKE $criteria) 
      AND deletedAt IS NULL) 
      ORDER BY name
      `,
      {
        bind: {
          criteria: criteria
        }
      }
    )
```

<img width="1439" height="328" alt="image" src="https://github.com/user-attachments/assets/31b50490-5df5-4a9d-899c-15dff1b237a8" />

4. Let's push these changes so that Semgrep can scan it again. Click the `+` sign next to `search.ts` to stage the changes, then type in a commit message and press `Commit`. Finally, click on `Sync Changes` to push our changes to the main branch.

<img width="364" height="470" alt="image" src="https://github.com/user-attachments/assets/dc7e73dc-5e8c-4ff5-ba4c-ef06186088b7" />

5. Checking the scan results, we confirm that the SQL Injection finding has been remediated!

<img width="1077" height="511" alt="image" src="https://github.com/user-attachments/assets/4ab263da-2158-432f-9b6b-dd7d4251d9c6" />

## Post SAST Gap Analysis

