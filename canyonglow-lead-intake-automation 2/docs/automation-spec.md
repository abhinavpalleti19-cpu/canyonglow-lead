# CanyonGlow Lead Intake Automation Specification

## Purpose

Build a production-style demonstration that captures fictional HVAC service enquiries, applies reliable business rules, uses an LLM only for suitable language tasks, keeps customer communication under human control, and records enough evidence to explain successful and failed executions.

## Recommended MVP stack

- Landing page and inquiry form
- n8n workflow orchestration
- Google Sheets lead register and audit log
- Gmail for internal alerts and approved test responses
- OpenAI or Claude for structured extraction and draft generation
- Email, Slack, or Telegram for error alerts
- GitHub for sanitized documentation and workflow exports
- Loom or YouTube for the portfolio walkthrough

Use only test accounts and fictional records. Do not publish credentials, OAuth tokens, webhook secrets, or real customer data.

## End-to-end flow

1. The landing page posts the form to an authenticated n8n webhook.
2. n8n creates a submission ID and records the received timestamp.
3. A normalization step trims text, standardizes the email and phone, and rejects unexpected fields.
4. Validation checks required fields, consent, formats, and description length.
5. Duplicate protection searches recent records using normalized email, normalized phone, and a time window.
6. A deterministic ZIP-code rule marks the lead as inside or outside the demo service area.
7. Deterministic rules assign the initial priority.
8. An LLM extracts symptoms, equipment clues, requested outcome, and a short internal summary into a strict JSON schema.
9. The workflow combines the rule result and LLM extraction without allowing the LLM to override service-area or safety rules.
10. The lead is written to the register with its status, priority, and timestamps.
11. Acknowledgement text is generated from an approved template. The LLM may personalize non-sensitive wording.
12. High-priority, uncertain, incomplete, or outside-area cases enter manual review.
13. An authorized reviewer approves, edits, or rejects the response.
14. Approved test responses are sent only to allow-listed test addresses.
15. The result is logged, including execution ID, reviewer action, delivery status, and processing duration.
16. Failures enter a recovery queue and trigger an internal alert.

## Deterministic priority rules

Apply the highest matching priority.

### High

- `serviceType` is `no_cooling`
- Reported indoor temperature is greater than or equal to 90°F
- `urgency` is `today`
- More than one residential unit is affected

### Medium

- `urgency` is `within_3_days`
- AC repair, thermostat, ductwork, or air-quality service
- Reduced cooling, airflow issue, unusual noise, or thermostat failure is mentioned

### Low

- Routine tune-up
- Maintenance-plan enquiry
- Planning or pricing enquiry more than two weeks away

Priority is an operational routing label, not a medical or safety diagnosis.

## Lead states

Primary path:

`New -> Validated -> Qualified -> Awaiting Approval -> Contacted -> Appointment Scheduled -> Closed Won or Closed Lost`

Exception path:

`Incomplete | Duplicate | Outside Service Area | Automation Failed | Manual Review`

## Duplicate rule

Flag a record as a probable duplicate when either condition is true:

- Normalized email and ZIP code match a lead received within the previous seven days.
- Normalized phone number matches a lead received within the previous seven days.

Never delete a duplicate automatically. Retain it, link it to the earlier submission, and require staff review before any response.

## LLM extraction contract

The model must return valid JSON containing:

- `issue_summary`: maximum 240 characters
- `symptoms`: array of short strings
- `equipment_or_system`: string or null
- `requested_outcome`: string or null
- `missing_information`: array of field names
- `language`: ISO language code
- `confidence`: number from 0 to 1
- `manual_review_reason`: string or null

If JSON parsing fails, confidence is below 0.75, or the message contains conflicting information, route the lead to manual review. The model must not diagnose equipment, promise availability, quote an unapproved repair price, or determine whether an address is serviceable.

## Approval policy

Human approval is mandatory for:

- High-priority leads
- Outside-service-area leads
- Incomplete or uncertain enquiries
- Messages containing a complaint, refund request, threat, or unusual safety concern
- Any response containing a price other than approved starting prices
- Any appointment confirmation

For the public demo, all outbound messages must be restricted to allow-listed test email addresses.

## Failure handling

- Retry transient API failures up to three times using increasing delays.
- Do not retry validation failures or rejected authentication.
- Use an idempotency key based on submission ID so retries cannot create multiple leads or messages.
- Write failed items to a recovery queue with the last completed step and error summary.
- Alert the operator when a lead cannot be recorded or a message cannot be delivered.
- Provide a manual reprocess action after the underlying problem is fixed.
- Run a daily reconciliation comparing received submissions, lead-register rows, and final statuses.

## Security and privacy

- Store credentials only in the platform credential manager.
- Protect the webhook with a secret or signed request and apply rate limiting.
- Validate input length and reject unexpected fields.
- Use fictional test data only.
- Do not log API keys or full authorization headers.
- Sanitize workflow exports before publishing them.
- Limit spreadsheet and workflow access to the project account.
- Define a test-data deletion process after the portfolio demonstration.

## Metrics

Track:

- Submissions received
- Valid, incomplete, duplicate, and outside-area leads
- Priority distribution
- Time to acknowledgement
- Manual review rate
- LLM JSON validity rate
- Reviewer edit rate
- Successful and failed deliveries
- Automation execution time
- Recovery time after an injected failure

Do not describe simulated targets as real results. Report measured values from controlled test runs separately.

## Required test cases

1. Valid routine tune-up
2. Valid urgent no-cooling request
3. Duplicate email and ZIP
4. Duplicate phone number
5. Missing required field
6. Invalid email or phone format
7. Outside service area
8. Ambiguous problem description
9. Invalid LLM JSON
10. Low LLM confidence
11. Temporary Gmail or API failure
12. Permanent authentication failure
13. Approval accepted without edits
14. Approval edited
15. Approval rejected
16. Duplicate webhook delivery

## Portfolio deliverables

- Before-and-after process map
- Architecture diagram
- Sanitized n8n JSON export
- Lead-register field dictionary
- Test-case results
- One-page operator runbook
- Failure and recovery demonstration
- Measured test metrics
- GitHub README
- Three-to-five-minute walkthrough video
