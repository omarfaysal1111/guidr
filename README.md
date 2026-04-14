# Guider — Intelligent Guidance Platform


> workflows through smart, context-aware recommendations.

Guider is the flagship project of this profile — a full-stack platform
built from scratch, combining a Flutter mobile client, a Java/Spring Boot
microservices backend, and an AI recommendation engine into a single
cohesive product ecosystem.

---

## System Architecture
┌─────────────────────────────────────────────────────┐
│                  Guider Platform                     │
├──────────────────┬──────────────────────────────────┤
│   Flutter Client │      Admin / Web Portal           │
│  (iOS + Android) │       (Angular / TypeScript)      │
└────────┬─────────┴────────────┬────────────────────┘
│                      │
▼                      ▼
┌─────────────────────────────────────────────────────┐
│           API Gateway  (Spring Boot)                 │
├──────────────┬──────────────┬───────────────────────┤
│  Auth Service│ Guidance     │  FitCoach Sub-System  │
│  (JWT/RBAC)  │ Engine       │  (Workout + Nutrition)│
└──────┬───────┴──────┬───────┴──────────┬────────────┘
│              │                  │
▼              ▼                  ▼
┌──────────┐  ┌──────────────┐  ┌──────────────────┐
│PostgreSQL│  │Recommendation│  │  LLM Integration  │
│   (JPA)  │  │   Engine     │  │  (OpenAI / Local) │
└──────────┘  └──────────────┘  └──────────────────┘
│
▼
┌─────────────────┐
│  Docker + CI/CD │
│ (GitHub Actions)│
└─────────────────┘

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Client | Flutter · Dart · Clean Architecture |
| Backend | Java · Spring Boot · Spring Security |
| Auth | JWT · Role-Based Access Control (RBAC) |
| Recommendation | Custom guidance engine · LLM integration |
| Database | PostgreSQL · Hibernate / JPA |
| DevOps | Docker · GitHub Actions CI/CD |
| Sub-system | [FitCoach Pro Backend](https://github.com/omarfaysal1111/fitcoach) |

---

## Key Features

- **Context-aware guidance engine** — analyzes user state and workflow
  position to deliver relevant, personalized next-step recommendations
- **FitCoach integration** — embedded fitness coaching sub-system
  delivering workout plans and nutrition guidance (see
  [fitcoach](https://github.com/omarfaysal1111/fitcoach))
- **Role-based multi-tenant architecture** — supports User, Coach, and
  Admin roles with fine-grained permission control
- **Server-Driven UI** — backend controls mobile screen composition,
  enabling dynamic content updates without app store releases
- **Real-time notification system** — high-throughput push delivery via
  background queue management
- **LLM-powered recommendations** — OpenAI integration for intelligent,
  conversational guidance responses

---

## Architecture Decisions

**Why Clean Architecture?**
Separating Domain, Data, and Presentation layers allows the mobile client
and backend to evolve independently. New guidance modules can be added
as Use Cases without touching UI or infrastructure code.

**Why Server-Driven UI?**
Guidance workflows change frequently based on business logic. SDUI lets
the backend define screen structure, removing the need for app releases
every time a workflow step changes.

**Why a dedicated FitCoach sub-system?**
Fitness coaching has its own domain model (exercises, muscle groups,
nutrition macros) that is complex enough to warrant service isolation.
It communicates with the core Guider API via internal REST contracts,
keeping concerns cleanly separated.

---

## Repositories in This Ecosystem

| Repo | Description |
|---|---|
| `guider` | This repo — platform overview and Flutter mobile client |
| [`fitcoach`](https://github.com/omarfaysal1111/fitcoach) | Spring Boot backend for the FitCoach sub-system |

---

## Running the Mobile Client

```bash
git clone https://github.com/omarfaysal1111/guider.git
cd guider
flutter pub get
flutter run
```

> Backend setup: see the
> [fitcoach repo](https://github.com/omarfaysal1111/fitcoach) for API
> configuration and Docker setup.

---

## Status

actively maintained · production-ready architecture · open to collaboration
