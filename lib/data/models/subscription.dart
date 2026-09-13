import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionState {
  const SubscriptionState({
    required this.isAiPro,
    this.renewsAt,
    this.entitlements,
  });

  final bool isAiPro;
  final DateTime? renewsAt;
  final EntitlementInfos? entitlements;

  static const free = SubscriptionState(isAiPro: false);

  factory SubscriptionState.fromRevenueCat(EntitlementInfos entitlements) {
    final aiProEntitlement = entitlements.all['ai_pro_monthly'];
    final isActive = aiProEntitlement?.isActive ?? false;
    
    return SubscriptionState(
      isAiPro: isActive,
      renewsAt: DateTime.tryParse(
        aiProEntitlement?.expirationDate ??
            aiProEntitlement?.latestPurchaseDate ??
            '',
      ),
      entitlements: entitlements,
    );
  }

  Map<String, dynamic> toJson() => {
        'isAiPro': isAiPro,
        'renewsAt': renewsAt?.toIso8601String(),
      };

  factory SubscriptionState.fromJson(Map<String, dynamic> json) =>
      SubscriptionState(
        isAiPro: json['isAiPro'] as bool? ?? false,
        renewsAt: DateTime.tryParse(json['renewsAt'] as String? ?? ''),
      );
}

class MobilityRoutine {
  const MobilityRoutine({
    required this.id,
    required this.title,
    required this.area,
    required this.minutes,
    required this.cues,
  });

  final String id;
  final String title;
  final String area;
  final int minutes;
  final List<String> cues;
}

const guidedRoutines = [
  MobilityRoutine(
    id: 'hips',
    title: '90/90 Hip Reset',
    area: 'Hips',
    minutes: 8,
    cues: [
      'Sit tall, both knees at 90°',
      'Switch sides every 45 seconds',
      'Breathe into the trailing hip',
    ],
  ),
  MobilityRoutine(
    id: 'tspine',
    title: 'Open-Book Thoracic Flow',
    area: 'Spine',
    minutes: 6,
    cues: [
      'Side-lying, knees stacked',
      'Reach the top arm in a slow arc',
      'Pause 2 seconds at end range',
    ],
  ),
  MobilityRoutine(
    id: 'ankles',
    title: 'Ankle Rocks + Calf Bias',
    area: 'Lower leg',
    minutes: 5,
    cues: [
      'Knee tracks over mid-foot',
      '10 slow rocks each side',
      'Keep heel glued to the floor',
    ],
  ),
];
