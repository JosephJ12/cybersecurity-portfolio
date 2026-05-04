# CR04: Unauthorized Profile Video Deletion

A non-admin user is able to utilize the admin functionality of deleting an arbitrary user's profile video given its video ID number. This should be a functionality reserved only for authorized and admin users.

## CVSS Severity
Medium (5.0)

AV:N/AC:L/PR:L/UI:N/S:C/C:L/I:N/A:N

## Affected Endpoint
1. `DELETE /identity/api/v2/admin/videos/[VIDEO_ID]`

## Impact
Any user can delete the profile video of another user. This goes against proper business flow and is a violation of secure access controls.

## Root Cause
The service implementation code does not validate whether the requesting user has admin access before deleting the profile video. 

Screenshots:
1. ![](../evidence/CR04/root-cause-1.png)
2. ![](../evidence/CR04/root-cause-2.png)

## Evidence
See:
- ![](../evidence/CR04/broken-function-level-authorization-1.png)
- ![](../evidence/CR04/broken-function-level-authorization-2.png)
- ![](../evidence/CR04/broken-function-level-authorization-3.png)

## Remediation
After validating the JWT token, retrieve the username and role. Then check whether the user has the ADMIN role and has sufficient rights to delete profile videos.

- [Before Remediation Code](../remediations/CR04/before-remediation-code.md)
- [After Remediation Code](../remediations/CR04/after-remediation-code.md)

## Retest Result
Only admin users are able to delete profile videos.

1. Nonadmin user JWT token
![](../evidence/CR04/after-remediation-1.png)

2. Verify nonadmin user cannot delete profile video
![](../evidence/CR04/after-remediation-2.png)

3. Try again with forged admin JWT token
![](../evidence/CR04/after-remediation-3.png)

4. Verify cannot impersonate admin to delete profile video
![](../evidence/CR04/after-remediation-4.png)

## OWASP API5 2023: Broken Function Level Authorization

Broken Function Level Authorization is when improper access controls lead to unauthorized access of admin functions and features. Not to be confused with API3 (Broken Object Property Level Authorization), the main difference is that API3 is about what an object is and API5 is about what an one can do to an object. In the case of CR04, because one can delete another user's profile video, which should be a function accessible only to admin users, this is an example of Borken Function Level Authorization (API5).
