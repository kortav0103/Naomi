# Grading Rubric — Mobile Development Course Project

**Date:** 29 September 2026  
**Instructor:** Minh Khuê PHAN TRAN  

---

## Overview

* **Course Project Grade:** 50% Assignment 01 (Specification) + 50% Assignment 02 (Implementation).
* Each assignment is scored out of 100 points and converted to a 10-point scale.
* Assignment 02 is assessed directly against the team's own Assignment 01 specification; the spec must be specific enough to serve as the acceptance baseline.

| Level | Share of criterion points | Meaning |
| :--- | :---: | :--- |
| **Excellent** | 90–100% | Complete, justified, at a professional document/product standard |
| **Good** | 75–89% | All main components present, minor gaps |
| **Satisfactory** | 60–74% | Basic components present but thin or unjustified |
| **Unsatisfactory** | 0–59% | Key components missing or seriously flawed |

---

## Assignment 01 Rubric — Comprehensive Specification Document (100 points)

*The deliverable is a single consolidated document covering everything from requirements elicitation to system architecture and UI mockups.*

| # | Criterion | Max | Excellent (90–100%) | Satisfactory (60–74%) | Unsatisfactory (<60%) |
| :-: | :--- | :-: | :--- | :--- | :--- |
| **1.1** | **Problem analysis & requirements elicitation** | 15 | Clear problem statement; stakeholders and personas; evidence of real elicitation (interviews, surveys, competitor app analysis) | Problem and users described, but mostly assumed | Vague problem; unclear who the users are or why the app is needed |
| **1.2** | **Functional requirements specification** | 20 | Use case diagram + use case specs / user stories with testable acceptance criteria; MoSCoW prioritisation | Use cases and feature list present, but acceptance criteria or priorities missing | Disconnected features that cannot be verified |
| **1.3** | **Non-functional requirements & mobile constraints** | 10 | Measurable NFRs: response time, offline behaviour, security, permissions, platform/OS versions, battery/network | Generic NFRs (*"the app must be fast"*) | Missing or not mobile-relevant |
| **1.4** | **System architecture design** | 20 | Overall architecture (app ↔ backend ↔ external services) and in-app architecture (MVVM/Clean…); sequence diagrams for main flows; justified technology choices | Architecture diagram present but lacks justification or in-app detail | Technology names only, no design |
| **1.5** | **Data & API design** | 10 | ERD/data model, local storage strategy, API contract (endpoints, request/response, error codes) | Data model present, API only sketched | Missing or inconsistent with the features |
| **1.6** | **UI/UX design & mockups** | 15 | Complete user flows; consistent hi-fi mockups following Material/HIG; loading/empty/error states; clickable prototype; accessibility considered | Main screens covered, some inconsistency or missing secondary states | Rough wireframes, key screens missing |
| **1.7** | **Traceability & document quality** | 10 | Traceability matrix (Requirement → Use case → Screen → Architecture component); consistent, professional presentation | Reasonable structure but sections cannot be traced to each other | Fragmented, many contradictions |
| | **Total** | **100** | | | |

---

## Assignment 02 Rubric — Application Implementation (100 points)

*The application is accepted against the acceptance criteria and architecture defined in Assignment 01.*

| # | Criterion | Max | Excellent (90–100%) | Satisfactory (60–74%) | Unsatisfactory (<60%) |
| :-: | :--- | :-: | :--- | :--- | :--- |
| **2.1** | **Completeness against the spec** | 25 | 100% of Must-have and most Should-have features pass the acceptance criteria from A01 | Most Must-have features done; some incomplete | Many core features missing |
| **2.2** | **Architecture compliance & code quality** | 20 | Follows the designed architecture, clear layering, sound state management; clean code; steady Git history with branches/PRs | Minor deviation from the design; works but has duplication | Code lumped together, ignores the design; commits dumped at the end |
| **2.3** | **Implemented UI/UX** | 15 | Matches the mockups; handles loading/empty/error states; works well across screen sizes | Main screens resemble the mockups, minor display bugs | Deviates heavily from the mockups, broken layouts |
| **2.4** | **Data, integration & error handling** | 10 | Real backend/API integration; handles network loss, input validation, cache/offline where specified | Integrated, but error handling is thin | Hard-coded data, crashes on network errors |
| **2.5** | **Testing** | 10 | Unit tests for core logic + manual test cases mapped to acceptance criteria, with a results report | Some tests, not mapped to the spec | No testing |
| **2.6** | **Security & performance** | 5 | Tokens/keys stored securely, permissions requested at the right time, no secrets in the repo; smooth interaction | Basic precautions | Exposed API keys, excessive permissions |
| **2.7** | **Build, deployment & documentation** | 5 | Installable build (APK/TestFlight/Expo); clear README with run instructions | Runs, but configuration must be fixed manually | Cannot be built from the repo |
| **2.8** | **Demo & oral defence** | 10 | Smooth scripted demo; every member can explain the code they wrote | Demo works, answers are hesitant | Team cannot explain its own code |
| | **Total** | **100** | | | |

---

## Additional Rules

| Rule | Description | Effect on grade |
| :--- | :--- | :--- |
| **Change log against the spec** | Every design change in A02 must be logged with its rationale | Unexplained changes are penalised under criteria 2.1 and 2.2 |
| **Gate condition** | The app must build and run from the repo following the README | Does not build → A02 capped at 40/100 |
| **Individual factor** | Based on peer review, Git contribution, and oral defence | Individual grade = $\text{team grade} \times (0.8\text{ to }1.2)$ |
| **Use of AI tools** | Permitted to the extent stated in the assignment brief; must be declared | Undeclared use or inability to explain code → penalised under 2.8 and individual factor |
| **Late submission** | Deduction per day late | Proposed 10% per day, maximum 3 days |
| **A02 mid-term review** | Teams present progress and a preliminary build | Not graded; used for early feedback |