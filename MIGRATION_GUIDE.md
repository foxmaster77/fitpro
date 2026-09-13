# FITPRO Database Migration & Production API Integration Guide

## 1. SQLite Database Migration (Version 1 → 2)

### Migration Strategy
The database migration has been implemented with **transactional safety** to prevent data corruption. The `sqflite` package does not automatically wrap upgrade logic in transactions, so we explicitly wrap the migration in a transaction.

### Key Changes in `lib/core/local_database.dart`

```dart
onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 2) {
    await db.transaction((txn) async {
      await _createGamificationTables(txn);
      await _createExerciseTables(txn);
    });
  }
},
```

### New Tables Created
1. **`daily_quests`** - Stores gamification quest data with encrypted payloads
2. **`exercises`** - Exercise library with premium flags and media URLs
3. **`routines`** - User-created workout routines
4. **`routine_exercises`** - Junction table for routine-exercise relationships

### Data Safety
- All existing tables (`kv`, `encrypted_events`) remain untouched
- No data loss for existing users
- Atomic transaction ensures either all tables are created or none are

## 2. Google Generative AI Integration

### AI Coach Service Enhancement
The `AiCoachService` has been upgraded to use Google's Gemini API for real AI-powered workout generation.

### Key Features
- **Dynamic Prompting**: Constructs context-aware prompts using user's BMR, TDEE, readiness scores, and fitness goals
- **JSON Parsing**: Extracts structured workout plans from AI responses
- **Fallback Logic**: Maintains existing rule-based plans if AI fails
- **Profile Integration**: Passes user biometrics and XP level for personalized recommendations

### Configuration Required
Update the API key in `lib/data/services/ai_coach_service.dart`:
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY';
```

### Usage Example
```dart
final plan = await aiCoachService.generate(
  readiness: current.readiness,
  profile: current.profile, // Now includes biometrics and XP
);
```

## 3. RevenueCat Integration

### Subscription Management
RevenueCat has been integrated for production-ready subscription management.

### Key Components
1. **`RevenueCatService`** - Handles purchase flow and entitlement verification
2. **`SubscriptionState`** - Enhanced to support RevenueCat entitlements
3. **Real-time Updates** - Listens to purchase state changes

### Configuration Required
Update the API key in `lib/data/services/revenue_cat_service.dart`:
```dart
static const String _apiKey = 'YOUR_REVENUECAT_API_KEY';
```

### Entitlement Setup
Ensure RevenueCat dashboard has:
- Product ID: `ai_pro_monthly`
- Entitlement ID: `ai_pro_monthly`

### Usage in UI
```dart
final isPro = await revenueCatService.isProSubscriber();
// Automatically updates exercise locks and premium features
```

## 4. Production Checklist

### Before Deployment
- [ ] Set Google Gemini API key in `ai_coach_service.dart`
- [ ] Set RevenueCat API key in `revenue_cat_service.dart`
- [ ] Configure RevenueCat products and entitlements in dashboard
- [ ] Test database migration on existing user data
- [ ] Verify transaction safety with interrupted migrations
- [ ] Test AI fallback behavior when API fails
- [ ] Validate subscription state persistence

### API Rate Limits
- **Gemini API**: Monitor usage and implement rate limiting if needed
- **RevenueCat**: Built-in rate limiting, but monitor purchase failures

### Error Handling
- AI failures fall back to rule-based plans
- RevenueCat failures default to local subscription state
- Database migration failures prevent app startup (safe failure)

## 5. Testing Strategy

### Database Migration Tests
```dart
// Test migration preserves existing data
final oldVersion = 1;
final newVersion = 2;
// Verify existing logs are accessible after migration
// Verify new tables are created
```

### AI Integration Tests
```dart
// Test with mock API responses
// Test JSON parsing with various response formats
// Test fallback behavior when API is unavailable
```

### RevenueCat Tests
```dart
// Test purchase flow with sandbox
// Test entitlement verification
// Test subscription state updates
// Test restore purchases functionality
```

## 6. Architecture Compliance

### Riverpod State Management
- All services follow existing provider pattern
- No breaking changes to `AppSessionController`
- State updates remain atomic and predictable

### Navigation
- All new routes follow `go_router` patterns
- Bottom navigation (72px) preserved
- Deep linking support maintained

### UI Consistency
- Glassmorphism cards with neon accents preserved
- 48-56px touch targets maintained
- Google Fonts 'Outfit' throughout
- Dark-mode-first aesthetic respected

## 7. Next Steps

1. **API Key Setup**: Replace placeholder keys with production credentials
2. **RevenueCat Configuration**: Set up products in RevenueCat dashboard
3. **Beta Testing**: Test migration with real user data
4. **Monitoring**: Set up error tracking for AI and payment failures
5. **Documentation**: Update user-facing help content for new features

## 8. Rollback Plan

If issues arise:
1. Database: Revert to version 1 (no data loss, new features disabled)
2. AI: API calls fall back to rule-based logic automatically
3. RevenueCat: Local subscription state remains functional

The migration is designed to be safe and reversible at each layer.