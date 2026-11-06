# Architecture

```mermaid
flowchart TD
  A[Landing page form] -->|authenticated POST| B[n8n Intake webhook]
  B --> C[Submission ID + timestamp]
  C --> D[Normalize + validate]
  D -->|invalid| X[Incomplete / reject]
  D --> E[Duplicate check]
  E --> F[Service-area rule]
  F --> G[Priority rules]
  G --> H[LLM extraction - strict JSON]
  H -->|bad JSON / low confidence| M[Manual review]
  H --> I[Write lead to Sheets register]
  M --> I
  I --> J[Audit log]
  I --> K[Approval email with one-time links]
  K --> L[Approval workflow webhook]
  L --> N[Validate token, update lead, log decision]
  N --> O[Token cleared; reuse rejected]
  B -. failure .-> Q[Error queue + alert]
```

## Two workflows

| Workflow | Role |
|---|---|
| CanyonGlow Lead Intake and Triage | Receive, validate, classify, store, notify |
| CanyonGlow Lead Approval | Handle approve/reject links, update the register, audit |

## Trust boundaries

- **Deterministic:** validation, duplicates, service area, priority.
- **LLM:** summary, missing information, confidence, review reason only.
- **Human:** every high-priority, uncertain, outside-area or pricing/appointment message.
