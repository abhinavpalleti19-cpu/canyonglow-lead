# CanyonGlow Lead Intake & Approval Automation

A portfolio prototype that captures **fictional HVAC service enquiries**, triages them with deterministic business rules, uses an LLM only for language tasks, and keeps customer communication under **human approval**. Built with **n8n**, Google Sheets, Gmail and OpenRouter.

> **Status: working prototype.** All data is fictional. Metrics below come from controlled test runs, not real customers.

## What it does

1. A form posts to an n8n webhook, which creates a submission ID.
2. Input is normalized and validated (required fields, formats, consent, length).
3. Duplicate protection checks recent records. Duplicates are retained and flagged, never deleted.
4. **Deterministic rules** set the service-area result and priority (high / medium / low).
5. An **LLM** extracts a summary, missing information, confidence and a manual-review reason as strict JSON. It cannot override service-area or safety rules.
6. The lead is written to a Google Sheets register (30 fields) and an audit log.
7. A reviewer receives an approval email with **one-time approve/reject links**.
8. The approval workflow validates the token, updates the lead, logs the decision (no PII), and invalidates the link.
9. Failures go to an error queue.

See [`docs/architecture.md`](docs/architecture.md) for the diagram and [`docs/automation-spec.md`](docs/automation-spec.md) for the full specification.

## Design decisions

- **Rules decide, the LLM assists.** Priority and service area are never delegated to the model.
- **Human in the loop.** High-priority, uncertain, incomplete, outside-area and price/appointment messages require approval.
- **Safe fallback.** If the model call fails or returns invalid JSON, the lead is routed to manual review.
- **One-time tokens.** Approval links work once; reuse returns "Link not found or expired".
- **Test-only outbound mail** is restricted to allow-listed addresses.

## Stack

| Layer | Tool |
|---|---|
| Orchestration | n8n (Cloud or self-hosted) |
| Data store | Google Sheets (tabs: `Leads`, `Audit Log`, `Error Queue`) |
| Email | Gmail |
| LLM | OpenRouter (`google/gemma-4-26b-a4b-it:free`, `json_object` output) |

## Verified so far

Evidence is in [`docs/test-results.md`](docs/test-results.md).

- End-to-end runs: HTTP 202 response, classification, 30-field Sheet append, audit log, approval email.
- AI fallback path and successful AI parsing (isolated checks).
- Approval workflow: approve, token cleared, audit entry, reused link rejected (two leads).

### Coverage of the 16 required test cases

| # | Case | Status |
|---|---|---|
| 1-2 | Routine tune-up / urgent no-cooling | Priority classification exercised on 2 leads; case-level detail to add |
| 3-4, 16 | Duplicate email+ZIP / phone / webhook | Dedup path exercised; case-level detail to add |
| 5-8 | Missing field / bad format / outside area / ambiguous | Not yet documented |
| 9-10 | Invalid JSON / low confidence | Fallback path observed; dedicated tests not documented |
| 11-12 | Temporary / permanent API failure | Not yet documented |
| 13 | Approval accepted | Verified (2 leads) |
| 14-15 | Approval edited / rejected | Not yet documented |

`data/sample-leads.csv` contains 10 fictional inputs covering these scenarios.

## Repository structure

```
README.md
LICENSE
.gitignore
data/sample-leads.csv        fictional test inputs
docs/
  architecture.md            diagram and flow
  automation-spec.md         full specification
  field-dictionary.md        input and register fields
  runbook.md                 operator one-pager
  test-results.md            sanitized test evidence
workflows/                   sanitized n8n exports (see workflows/README.md)
scripts/check-secrets.sh     pre-commit secret scan
```

## Setup

1. **n8n:** import `workflows/canyonglow-lead-intake-triage.json` (and the Approval workflow when added). Credentials are not included.
2. **Google Sheet:** create tabs `Leads` (header row matching the register fields, A1 = `lead_id`), `Audit Log`, `Error Queue`. Paste your sheet ID into every Google Sheets node (placeholder: `YOUR_GOOGLE_SHEET_ID`).
3. **Credentials** (create in n8n): Google Sheets OAuth2, Gmail OAuth2, OpenRouter API. Re-select each credential on its nodes.
4. In the **Workflow Configuration** node set:
   - `openrouter_model` (default `google/gemma-4-26b-a4b-it:free`)
   - `approval_recipient_email` (your test mailbox)
   - `approval_webhook_base_url` (`https://<your-n8n-host>/webhook/canyon-glow-lead-approval`)
   - `allowed_origin` (your landing-page origin) and optionally `require_origin_header = true`
5. Publish the Approval workflow first, then Intake.
6. Test (use `/webhook-test/...` before publishing):

```bash
curl -X POST https://<your-n8n-host>/webhook/canyon-glow-lead \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Demo User","email":"demo@example.com","phone":"480-555-0123","zipCode":"85201","serviceType":"no_cooling","urgency":"today","propertyType":"single_family","preferredContactMethod":"phone","problemDescription":"AC blowing warm air, house is 94F inside.","contactConsent":true,"demoDataConfirmation":true,"source":"website"}'
```

Expect HTTP 202 with `lead_id` and `status`. Extra fields or a bad ZIP return 400; a wrong Origin returns 403.

## Security

- Credentials live only in n8n's credential manager. No keys, tokens, webhook secrets or real data in this repo.
- Run `scripts/check-secrets.sh` before every commit.
- Workflow IDs, hosts and message IDs are redacted in published docs.

## Known limitations / next steps

- Landing page and live-site form submission are not yet connected to the production webhook.
- The error-queue branch has not been exercised deliberately.
- The webhook is protected by an Origin allow-list and bot filtering, not a signed secret (the spec recommends one). Origin headers can be spoofed outside browsers, so add a shared secret or signature for production.
- Free-tier models can rate-limit or change.
- Several test cases, metrics and the walkthrough video are still to be completed.

## License

MIT. See `LICENSE`.

## Author

Abhinav Palleti
