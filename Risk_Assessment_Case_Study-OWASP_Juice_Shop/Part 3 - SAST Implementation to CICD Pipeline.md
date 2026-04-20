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

1. First, we'll need to create a Semgrep account and secret token to link to our GitHub Actions workflow. For the sake of brevity, I've included those steps in another page which I'll link here:
[Semgrep Account Setup](Semgrep-Account-Setup.md)

2. Now that we've successfully setup and configured our Semgrep settings, we can finally move onto the fun part. We'll integrate Semgrep SAST and SCA scanning into our CI/CD pipeline and automate it to run on every pull request and push to the main and master branches. 

  We'll do this by opening up Visual Studio Code and creating a new file. Because GitHub Actions only checks the repo's root folder and our repo root is the `cybersecurity-portfolio` folder (the one above the Risk Assessment folder), we'll create a new folder called  `.github/workflows/`. Then, we'll create the `semgrep.yml` file in it.

3. Let's add the following code and save it:

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


4. Now, if we commit this file as is, Semgrep will scan every single file in the juice-shop folder. However, since our scope is only the product search feature, we'll reduce the noise by scanning only these 2 files:

```
search.ts // where the product search logic is
package.json // where all the code dependencies are
```

5. To do this, we'll create a `.semgrepignore` file in the `juice-shop` folder, with these contents and save it:

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

6. Before we push our changes to the remote branch, we'll first rebase our repo in case there were any changes to it. Let's open a terminal in Visual Studio Code and enter this command:

`git pull origin main --rebase`

<img width="2228" height="372" alt="image" src="https://github.com/user-attachments/assets/2f8bcc43-ae5b-4dc1-902f-5ae211a8537d" />

7. Then, wew'll stage both our file changes by click on the `+` button next to it.

<img width="1376" height="724" alt="image" src="https://github.com/user-attachments/assets/1925cd03-95ec-4124-9f1d-f4e5aec09fb8" />

8. Add a commit message and then click on the `Commit` button.

<img width="782" height="714" alt="image" src="https://github.com/user-attachments/assets/c44da80f-de27-4c20-b136-b20252a11578" />

9. Then, click on `Sync Changes` and press `Ok`.

<img width="760" height="540" alt="image" src="https://github.com/user-attachments/assets/5cd0ac89-7d50-4a25-85d7-08d7ab913c47" />

10. We can confirm the Actions is running on GitHub and Semgrep.

<img width="1560" height="1354" alt="image" src="https://github.com/user-attachments/assets/4ef58108-7d59-47b7-b3e7-1ad6db69115b" />

<img width="2858" height="688" alt="image" src="https://github.com/user-attachments/assets/109dba6b-035f-4f0b-823c-8665acfbf833" />

11. After the scan finishes, we look at the findings in the `Code` section:

<img width="2432" height="1244" alt="image" src="https://github.com/user-attachments/assets/5426c0f4-6b93-41b4-8196-faae5ffe0b07" />

We have 2 findings, which essentially warn us of the same vulnerability. It warns us of SQL Injection in our search query and recommends we use parameterized queries. This will map to the risks we assessed earlier: `SEARCH-01` and `SEARCH-02`.

12. Our current vulnerable code is on line 23:

<img width="1427" height="141" alt="image" src="https://github.com/user-attachments/assets/e4567e3d-f80f-4bab-b692-0f31d739f960" />

13. We'll change that line to use parameterized queries instead of directly inputting the criteria into the SQL query itself. 

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

14. Let's push these changes so that Semgrep can scan it again. Click the `+` sign next to `search.ts` to stage the changes, then type in a commit message and press `Commit`. Finally, click on `Sync Changes` to push our changes to the main branch.

<img width="364" height="470" alt="image" src="https://github.com/user-attachments/assets/dc7e73dc-5e8c-4ff5-ba4c-ef06186088b7" />

15. Checking the scan results, we confirm that the SQL Injection finding has been remediated!

<img width="1077" height="511" alt="image" src="https://github.com/user-attachments/assets/4ab263da-2158-432f-9b6b-dd7d4251d9c6" />

## Post SAST Gap Analysis

| Risk ID | Risk | Expected Control | Status | Gap | Impact | Recommended Remediation |
|---|---|---|---|---|---|---|
| SEARCH-01 | SQL Injection - Product Data Exposure | Parameterized queries | Evident in scope | Parameterized queries have been confirmed and tested by Semgrep in scope. | A malicious actor can read and possibly modify unauthorized product data in database | Sanitize user search input and query database using parameterized queries |
| SEARCH-02 | SQL Injection - User Data Enumeration | Parameterized queries | Evident in scope | Parameterized queries have been confirmed and tested by Semgrep in scope. | A malicious actor can read data from Users table and possibly even retrieve their PII and credentials | Sanitize user search input and query database using parameterized queries |

By integrating Semgrep SAST into our CI/CD pipeline via GitHub Actions, we were able to find and confirm the mitigation of 2 risk regarding SQL Injection in our product search code.
