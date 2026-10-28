# Internal IT documentation structure

Sanitized sample. Fictional organization: **Lakeside Professional Group**, primary site **LPG-DC1**, supported by an in-house IT team.

How I organize internal IT documentation so the next admin, or the help desk, can pick up the environment without starting from zero.

## Purpose

The documentation system is the system of record. It can be a wiki, a documentation platform, or a structured share; the structure matters more than the product. Tickets and monitoring tell you what broke. The documentation tells you what the environment is supposed to look like, who to call, and how to recover it. If it is not documented, it does not exist for anyone but the person who did the work.

## Organization layout

One Organization record for the company. Locations under it. Everything else related back to those two objects.

| Record type | What lives here | Example (sanitized) |
|-------------|-----------------|---------------------|
| Organization | Legal name, business hours, IT contacts, key vendor and support contracts | Lakeside Professional Group |
| Locations | Physical / logical sites with address and timezone | LPG-DC1: primary office / server room |
| Configurations | Servers, firewalls, switches, APs, UPS, workstations of record | LPG-HV01 (Hyper-V host) |
| Asset records | Repeatable stacks: M365, backup, antivirus, ISP, licensing | M365 tenant summary; backup schedule |
| Passwords | Vaulted secrets with owner + rotation notes, never in a document body | Domain Admin (break-glass) |
| Documents | SOPs, runbooks, diagrams, change history | SOP-INF-004 Hyper-V VM unavailable |
| Related items | Links between configs, docs, assets, and contacts | HV01 related to backup FA + runbook |

## Asset record set for day one

| Asset record | Required fields | Why it matters |
|----------------|-----------------|----------------|
| Internet / WAN | ISP, circuit ID, public IP, gateway, support number | First call on an outage |
| Firewall / VPN | Make/model, firmware, management URL, VPN type | Remote access and perimeter |
| Active Directory / Entra | Domain FQDN, DC names, Entra tenant ID, sync method | Identity is the blast radius |
| Microsoft 365 | Tenant name, licensed SKUs, admin portal, MFA posture | Email / identity incidents |
| Backup | Product, what is protected, schedule, last test restore date | DR is not a checkbox |
| Antivirus / EDR | Product, policy name, exclusions, console URL | Containment and noise control |
| Monitoring / ticketing | Device naming standard, alert policies, ticket queue | How monitoring becomes work |

## Document types

- **SOP**: repeatable how-to (onboarding a user, imaging a PC, approving a patch window)
- **Runbook**: incident path with decision points (VM down, M365 compromise, VLAN internal-only outage)
- **As-built**: what was actually installed, not the proposal
- **Network / identity diagram**: one page, current, dated
- **Change note**: short record linked to the ticket and the Configuration it touched

## Naming and hygiene

- Documents: `SOP-AREA-### Title`, for example `SOP-INF-004 Hyper-V VM Unavailable`
- Configurations: `SITE-ROLE-##`: `LPG-HV01`, `LPG-DC01`, `LPG-FW01`
- Every Configuration has an owner contact, warranty / lifecycle note, and at least one related Document
- Passwords live only in the password vault. Documents say *where* the secret is, never the secret
- Review dates on Asset records (quarterly for backup test restore; after every major change)
- If the help desk cannot work the ticket from the documentation, the local record is incomplete

## Minimum viable documentation (first 30 days)

1. Organization + Locations + primary contacts
2. Configurations for every server, firewall, and core switch
3. Asset records: WAN, firewall, identity, M365, backup, AV/EDR
4. Two runbooks: after-hours host/VM down, and identity/M365 containment
5. One current network sketch and a device-naming standard

## Related samples in this repo

- [`sop-inf-004-hyperv-vm-unavailable.md`](./sop-inf-004-hyperv-vm-unavailable.md) is the Document record
- [`invoke-windows-healthcheck.ps1`](./invoke-windows-healthcheck.ps1) is the scheduled detector that feeds operational visibility
