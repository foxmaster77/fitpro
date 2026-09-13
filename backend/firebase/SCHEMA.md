# Firebase document shapes (ciphertext only)

## users/{uid}
```
{
  displayName: string,
  onboardingComplete: boolean,
  acceptedPrivacyAt: timestamp,
  zeroDataSellingAck: true
}
```

## users/{uid}/events/{eventId}
```
{
  kind: "lift" | "run" | "calorie" | "readiness" | "plan",
  createdAt: timestamp,
  ciphertext: string,          // AES-256-CBC payload from the device
  clientSchemaVersion: 1
}
```

## users/{uid}/subscription/current
```
{
  tier: "core" | "ai_pro",
  sku: "ai_pro_monthly",
  priceUsd: 4.99,
  renewsAt: timestamp | null,
  provider: "app_store" | "play"
}
```

Never store sleepScore, muscleFatigue, sets, reps, or calories in plaintext fields.
Sync is opt-in. Local SQLite remains the source of truth.
