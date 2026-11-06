# Live Test Results

Date: 2026-11-05

## Current workflow

- Name: CanyonGlow Lead Intake and Triage
- Workflow ID: `<INTAKE_WORKFLOW_ID>`
- State: inactive and unpublished
- Webhook path: `canyon-glow-lead`
- OpenRouter model: `google/gemma-4-26b-a4b-it:free`
- OpenRouter output mode: `json_object`

## End-to-end tests

### Execution 36 — Maya Rodriguez

- Response path: HTTP 202
- Lead ID: `CGL-20261105-PKX2NS`
- Classification: high priority, manual review
- Leads append: succeeded
- Audit Log append: succeeded
- Error Queue: no write
- Approval email: delivered to the internal test mailbox
- AI result: fallback used because the original free router exhausted its output budget on reasoning

### Execution 37 — Daniel Kim

- Response: HTTP 202
- Lead ID: `CGL-20261105-XGQZ7G`
- Classification: medium priority, manual review
- Exact 30-field Sheet mapping: produced successfully
- Leads append: succeeded
- Audit Log append: succeeded
- Error Queue: no write
- Approval email: delivered; Gmail message ID `<redacted>`
- AI result: fallback used because `openrouter/free` rejected `reasoning.enabled=false`

## Repairs and verification

- Replaced the malformed Leads A1 value with exactly `lead_id`; clipboard verification returned `"lead_id"` with no hidden line breaks.
- Added an explicit 30-field mapping before the Leads append.
- Added `preferred_contact`, `service_area`, timestamps, execution ID, and consistent error/fallback fields.
- Replaced the unstable router with `google/gemma-4-26b-a4b-it:free`.
- Removed the reasoning parameter.
- Changed OpenRouter response format to `json_object`; the prompt and parser still enforce the four expected fields.

### Isolated AI verification — executions 39 and 40

- OpenRouter HTTP status: 200
- Model: `google/gemma-4-26b-a4b-it:free`
- Cost reported by OpenRouter: $0
- Parsed fields: `ai_summary`, `missing_information`, `confidence`, `manual_review_reason`
- Confidence: 1.0
- Parser result: valid, no AI error, no manual review, status `pending_approval`
- No Google Sheets, Gmail, Audit Log, Error Queue, webhook, or response node ran during this isolated check.

## Verified behavior

- Validation, service-area logic, priority assignment, deduplication path, 30-field mapping, Sheet append, Audit Log append, Gmail approval notification, safe 202 response, AI fallback, and successful AI parsing have all been exercised.
- The workflow remains inactive and unpublished.

## Remaining before production activation

- Connect the landing-page form to the production webhook.
- Run one post-publish form submission from the live website.
- Exercise the HTTP 500/Error Queue branch deliberately.
- Optionally remove the two test Sheet rows and two test emails after portfolio evidence is captured.

## Approval workflow verification

- Workflow: `CanyonGlow Lead Approval`
- Workflow ID: `<APPROVAL_WORKFLOW_ID>`
- Production URL: `https://<YOUR-N8N-HOST>/webhook/canyon-glow-lead-approval`
- State: published and active
- Test link: Daniel Kim approval link from the existing email
- Browser result: `Lead approved`
- Leads row: `status=approved`, `approval_status=approved`
- One-time token: cleared after use
- Audit Log: `lead_approved` entry created
- Reused link: returned `Link not found or expired`

The approval workflow validates `decision`, `lead_id`, and a long one-time token; looks up by exact token; updates the matching row; logs the decision without PII; and returns no-store HTML responses.

### Repeat approval test — Maya Rodriguez

- Browser result: `Lead approved`
- Lead ID: `CGL-20261105-PKX2NS`
- Leads row: `status=approved`, `approval_status=approved`
- One-time token: cleared
- Audit Log: second `lead_approved` event verified
- Reused link: returned `Link not found or expired`
- New email sent: no
