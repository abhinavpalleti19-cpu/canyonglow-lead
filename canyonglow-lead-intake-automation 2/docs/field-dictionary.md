# Field Dictionary

## Form input fields (16)

| Field | Description |
|---|---|
| submission_id | Unique submission identifier (idempotency key) |
| submitted_at | ISO 8601 timestamp |
| full_name | Customer name |
| email | Normalized to lowercase |
| phone | Normalized format |
| zip_code | Used for service-area rule |
| service_type | e.g. ac_tuneup, no_cooling, ac_repair, thermostat, ductwork, maintenance_plan, multi_unit, other |
| urgency | today, within_3_days, within_2_weeks, planning_only |
| preferred_appointment_date | Optional date |
| property_type | single_family, condo, townhome, small_multi_unit |
| unit_count | Residential units affected |
| indoor_temperature_f | Optional; >= 90 triggers high priority |
| problem_description | Free text |
| preferred_contact_method | email, phone, text |
| lead_source | website, search, social_ad, referral, property_manager |
| expected_outcome | Test label used for verification |

## Register fields documented in test evidence

`lead_id` (format `CGL-YYYYMMDD-XXXXXX`), `status`, `approval_status`, `preferred_contact`, `service_area`, `ai_summary`, `missing_information`, `confidence`, `manual_review_reason`, one-time approval token (cleared after use), execution ID, timestamps, error/fallback fields.

> TODO: replace this section with the full list of all 30 register columns from your `Leads` sheet header row.

## Lead states

Primary: `New -> Validated -> Qualified -> Awaiting Approval -> Contacted -> Appointment Scheduled -> Closed Won | Closed Lost`
Exception: `Incomplete | Duplicate | Outside Service Area | Automation Failed | Manual Review`
