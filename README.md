# FITPRO

Native Flutter fitness app: local-first encrypted health vault, dynamic AI coach, unified logging, and a hybrid freemium paywall that keeps core tracking free.

## Product principles

- **Retention** — daily readiness + a one-tap workout that actually changes with sleep and fatigue.
- **Subscription fatigue** — lifts, runs, calories, mobility, and the base AI workout stay free. **AI Pro ($4.99/mo)** only unlocks predictive injury analysis and clinician export.
- **Privacy** — onboarding states **Zero Data Selling** and **End-to-End Encryption**. AES-256 key in Keystore/Keychain; SQLite stores ciphertext.

## Run

```bash
flutter pub get
flutter run
```

Dark-mode first. Bottom tabs: Coach · Log · Rehab · You.

## Architecture

| Layer | Choice |
| --- | --- |
| UI | Flutter, Material 3, Outfit via Google Fonts, neon electric blue + lime |
| State | Riverpod (`AppSessionController`) |
| Navigation | go_router + `StatefulShellRoute` |
| Local DB | sqflite (`fitpro_encrypted.db`) |
| Secrets | `flutter_secure_storage` (AES key) |
| Crypto | `encrypt` AES-256-CBC |
| AI | `AiCoachService` simulated latency + rules (swap for a real model) |
| Cloud | Optional — schema in `backend/supabase` and `backend/firebase` |

```
lib/
  main.dart                 boot, overrides
  app.dart                  router + theme host
  core/                     encryption + sqlite
  data/models|repositories|services
  state/app_session.dart    single app state surface
  features/                 onboarding, home, workout, telehealth, paywall, profile
  widgets/                  neon buttons, glass cards, readiness ring
```

## Cloud (optional)

Local SQLite is authoritative. If you later enable sync:

1. Apply `backend/supabase/schema.sql` **or** `backend/firebase/firestore.rules`.
2. Upload **ciphertext only**. Do not add plaintext sleep/weight/calorie columns.
3. Keep the AES key on device (envelope encryption if you introduce a wrapping key).

## Monetization

| Free | AI Pro $4.99/mo |
| --- | --- |
| Logging + readiness | Predictive injury flags |
| Encrypted vault | Secure PT export |
| Guided mobility | Telehealth placeholder |
| Custom AI workout |  |

IAP is simulated in `activateAiPro()`. Wire StoreKit / Play Billing to SKU `ai_pro_monthly`.
