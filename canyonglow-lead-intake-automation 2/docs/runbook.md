# Operator Runbook (draft)

1. **New lead:** a row appears in `Leads` and an approval email arrives at the test mailbox.
2. **Review:** read the summary, priority and manual-review reason.
3. **Decide:** click Approve or Reject in the email. Each link works once; a reused link shows "Link not found or expired".
4. **Verify:** `Leads` shows `approval_status` updated and the token cleared; `Audit Log` has a decision entry.
5. **Failures:** check `Error Queue` and n8n Executions for the last completed step. Fix the cause, then reprocess manually.
6. **If the AI step fails:** the lead falls back to manual review; no action needed beyond normal approval.
7. **Cleanup:** after demos, delete test rows and test emails.

> TODO: add alert channel, reprocess steps and daily reconciliation once implemented.
