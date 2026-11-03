# Job Search Operating System

A version-controlled way to run a job search so the resume stays honest, the process stays consistent, and an AI assistant does the repetitive work without inventing experience.

Everything here is generalized. No real employers, no real outcomes, no identifying details. The patterns are free to reuse. The fictional examples are not real environments.

## Why this exists

Most job searches drift. The same role gets reviewed twice. A bullet sounds good in the moment and then falls apart in an interview. An assistant drafts something that cannot be defended. This system treats the search like any other operational process: one source of truth, explicit rules, and a human gate before anything leaves the building.

The core rule is simple. Every bullet on a resume must be something the person can defend in an interview. If it cannot be explained with a real example, it does not go on the page.

## How it is organized

The private repo holds the real records, the decision rules, and the tracker. An AI assistant can read those files, score postings, and draft materials. It cannot submit applications, email anyone, or change the rules without approval.

Public samples in this folder show the shape of the system without the private data:

- Decision table (what gets pursued, what gets passed)
- Claim boundary method (what can be said and what cannot)
- Pre-build gate checklist
- Tracker validator script

## Architecture

One repository is the source of truth. Verified career records sit in one place. A decision table and a set of gates sit in front of every resume. The tracker records every posting reviewed so nothing is evaluated twice. Changes go through a branch, a check, and a merge. The AI assistant is given the current rules at the start of each session and is not allowed to invent facts.

## Pipeline

1. Find postings from employer career pages.
2. Deduplicate against the tracker.
3. Score against the decision table and compensation rules.
4. Run the pre-build gate.
5. Draft materials from verified records only.
6. Human review and approval.
7. Log the outcome.

Most postings stop at step 3. That is intentional.

## Guardrails

The rules below came from long working sessions. The excerpts are cleaned up so they read clearly, but the trade-offs are the ones that actually got discussed.

### Truth in experience

The standing rule is that a bullet must survive an interview. If the person cannot walk through the work with a concrete example, the bullet does not belong on the resume.

Early drafts sometimes added language that sounded stronger than the actual work. Those got pulled. The test became: could this be explained in the first five minutes of a screen without hedging? If not, rewrite it or drop it.

### Compensation framing

The discussion centered on what number to put on a form and what never to volunteer. The final rule was to aim at a target figure and treat lower bands as private math. Recruiters and application forms only ever see the target. The lower numbers stay internal so the conversation does not start from a floor.

One session spent time on contract rates. The decision was to annualize at a standard hour count and then apply the same target. No separate "contract rate" language goes to a recruiter.

### Claim boundaries

A claim boundary library was built so the assistant cannot invent tools or depth. Each area has a short statement of what was actually done and a clear line for what was not.

The long discussion was about edge cases. Something used once on a project is not the same as ownership. Something learned on the job is not the same as a prior specialty. The library records the distinction so later drafts do not drift.

Example from the working notes: a tool used for a single restore test is not listed as a primary skill. The restore itself can be described. The product name stays out unless the work was repeated and owned.

### Decision table

The Stretch / Pass table started simple and grew as patterns repeated. Roles that require daily ownership of a tool the person has only fundamentals for became a Stretch or a Pass depending on how hard the screen would test that skill. Roles that require an active clearance the person did not want to obtain became a hard Pass.

The discussion that took the longest was around database work. Admin and operations tasks stayed in scope. Writing stored procedures or owning data modeling did not. The line was drawn after a screen where the questions went deeper than the verified work. The table was updated the same day.

### Approval levels

External actions stay with the person. The assistant can hunt, score, and draft. It cannot submit an application or send a message. That split came from early tests where a draft was almost sent before the person had reviewed the claims.

The rule is written as levels. Read and draft are automatic. Anything that leaves the system needs an explicit yes.

### Screening and volume

A cap on cold applications through the same vendor was added after the tracker showed repeated screens from one source with no movement. “Same vendor” means the same staffing firm, recruiting agency, or application platform (for example, one RPO, one Dice account, or one company career-site vendor that processes many employers). The discussion was whether the cap would slow the process too much. The final version allows a small number per vendor per week and requires a human-door contact in the mix so the search does not become pure volume.

## What the AI assistant does and does not do

The assistant reads the current rules, scores postings, drafts from the verified records, and keeps the tracker consistent. It does not answer attestation questions, solve CAPTCHAs, or decide whether a gap is acceptable. Those stay with the person.

Sessions start by loading the rule files. If the rules and the memory disagree, the rules win.

## What is left out

Private career records, the full tracker, compensation numbers, any real employer names, and any specific outcomes. The samples use fictional postings and a fictional tool so the method is visible without the data.

## License note

Patterns are free to reuse. Fictional details are not real environments. Review and adapt before use.
