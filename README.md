# Work samples

Sanitized examples of in-house systems and infrastructure work: documentation structure, incident runbooks, PowerShell health automation, escalation writing, and case studies.

All content is fictionalized or generalized. No real organization data, credentials, internal host names, production IPs, or proprietary logs.

## What this shows

- **Documentation discipline:** structure that a help desk or the next admin can use without a handoff call
- **Method-first troubleshooting:** isolate guest vs host vs DNS vs site before changing anything
- **Operational automation:** scheduled health checks that log exceptions instead of hoping someone notices
- **Clear communication:** escalation summaries and user-facing updates written for action

## Samples

### Infrastructure operations

| File | Purpose |
|------|---------|
| [`samples/documentation-system-structure.md`](samples/documentation-system-structure.md) | How I organize internal IT documentation in a central system of record |
| [`samples/sop-inf-004-hyperv-vm-unavailable.md`](samples/sop-inf-004-hyperv-vm-unavailable.md) | Incident runbook: Hyper-V guest unavailable (guest vs host vs storage vs DNS) |
| [`samples/invoke-windows-healthcheck.ps1`](samples/invoke-windows-healthcheck.ps1) | Scheduled Windows / Hyper-V health check (disk, services, VM state, optional cluster, JSON log, optional email) |

### Support, escalation, and case studies

| File | Purpose |
|------|---------|
| [`samples/tsm-restore-failure-case-study.md`](samples/tsm-restore-failure-case-study.md) | Restore failure that exposed backup platform misconfiguration |
| [`samples/escalation-summary-template.md`](samples/escalation-summary-template.md) | Escalation summary format for engineering / senior support handoff |
| [`samples/customer-facing-technical-update.md`](samples/customer-facing-technical-update.md) | Stakeholder-facing update in plain technical language |
| [`samples/post-remediation-runbook.md`](samples/post-remediation-runbook.md) | Runbook created after remediation to prevent repeat incidents |
| [`samples/national-support-desk-standup-case-study.md`](samples/national-support-desk-standup-case-study.md) | Standing up a 12-person program support desk under a compliance deadline |
| [`samples/hl7-interface-escalation-summary.md`](samples/hl7-interface-escalation-summary.md) | Intermittent clinical interface issue during hospital go-live |
| [`samples/storage-and-ha-design-case-study.md`](samples/storage-and-ha-design-case-study.md) | Storage isolation and HA design for a multi-tier deployment |
| [`samples/implementation-lifecycle-case-study.md`](samples/implementation-lifecycle-case-study.md) | End-to-end multi-site implementation ownership through go-live and turnover |

## How to read the Hyper-V set

1. **Documentation structure:** where the runbook and the host record live
2. **SOP-INF-004:** the human path after an alert
3. **`Invoke-WindowsHealthCheck.ps1`:** the scheduled detector that raises the alert in the first place

The script uses built-in Windows / Hyper-V / FailoverClusters cmdlets only. It is a sample, not production tooling. Review before any use.

## About the author

Sean Rector, systems / infrastructure engineer (Windows Server, Hyper-V failover clustering, Active Directory / Entra, documentation, L3 escalation). Hampton Roads, Virginia.

- GitHub: [SeanRinVA](https://github.com/SeanRinVA)

## License note

Samples are shared for evaluation of documentation quality and technical reasoning. Reuse patterns freely; do not treat the fictional organization details as real environments.
