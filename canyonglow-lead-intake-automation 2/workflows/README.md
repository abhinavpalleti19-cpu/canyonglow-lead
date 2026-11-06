# Workflows

| File | Status |
|---|---|
| `canyonglow-lead-intake-triage.json` | Included, sanitized |
| `canyonglow-lead-approval.json` | **Add after sanitizing** (see below) |

## What was sanitized in the Intake export

- Credential IDs replaced with `REPLACE_WITH_YOUR_CREDENTIAL_ID` (no tokens are ever in exports).
- Google Sheet ID, approver email, landing-page origin and n8n host replaced with placeholders.
- `pinData` (captured test requests with headers and host names) emptied.
- Instance ID, version ID, webhook IDs and workflow ID removed; `active` set to `false`.

## Sanitizing the Approval workflow

1. n8n: workflow menu, **Download**.
2. Replace credential IDs, sheet ID, hostnames and emails; set `pinData` to `{}`; delete `meta`, `versionId` and `webhookId` fields.
3. Run `bash scripts/check-secrets.sh` from the repo root.
