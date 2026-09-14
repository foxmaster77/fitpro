class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.onboardingComplete,
    required this.acceptedPrivacy,
    required this.localEncryptionEnabled,
    this.userXp = 0,
    this.userLevel = 1,
    this.heightCm,
    this.weightKg,
    this.age,
    this.gender,
    this.fitnessGoal,
    this.injuryHistory = const [],
  });

  final String displayName;
  final bool onboardingComplete;
  final bool acceptedPrivacy;
  final bool localEncryptionEnabled;
  final int userXp;
  final int userLevel;
  final int? heightCm;
  final double? weightKg;
  final int? age;
  final String? gender;
  final String? fitnessGoal;
  final List<String> injuryHistory;

  factory UserProfile.guest() => const UserProfile(
    displayName: 'Athlete',
    onboardingComplete: false,
    acceptedPrivacy: false,
    localEncryptionEnabled: true,
    userXp: 0,
    userLevel: 1,
    heightCm: null,
    weightKg: null,
    age: null,
    gender: null,
    fitnessGoal: null,
    injuryHistory: [],
  );

  Map<String, dynamic> toJson() => {
    'displayName': displayName,
    'onboardingComplete': onboardingComplete,
    'acceptedPrivacy': acceptedPrivacy,
    'localEncryptionEnabled': localEncryptionEnabled,
    'userXp': userXp,
    'userLevel': userLevel,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'age': age,
    'gender': gender,
    'fitnessGoal': fitnessGoal,
    'injuryHistory': injuryHistory,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    displayName: json['displayName'] as String? ?? 'Athlete',
    onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    acceptedPrivacy: json['acceptedPrivacy'] as bool? ?? false,
    localEncryptionEnabled: json['localEncryptionEnabled'] as bool? ?? true,
    userXp: json['userXp'] as int? ?? 0,
    userLevel: json['userLevel'] as int? ?? 1,
    heightCm: json['heightCm'] as int?,
    weightKg: (json['weightKg'] as num?)?.toDouble(),
    age: json['age'] as int?,
    gender: json['gender'] as String?,
    fitnessGoal: json['fitnessGoal'] as String?,
    injuryHistory: (json['injuryHistory'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList(),
  );

  UserProfile copyWith({
    String? displayName,
    bool? onboardingComplete,
    bool? acceptedPrivacy,
    bool? localEncryptionEnabled,
    int? userXp,
    int? userLevel,
    int? heightCm,
    double? weightKg,
    int? age,
    String? gender,
    String? fitnessGoal,
    List<String>? injuryHistory,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      acceptedPrivacy: acceptedPrivacy ?? this.acceptedPrivacy,
      localEncryptionEnabled:
          localEncryptionEnabled ?? this.localEncryptionEnabled,
      userXp: userXp ?? this.userXp,
      userLevel: userLevel ?? this.userLevel,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      injuryHistory: injuryHistory ?? this.injuryHistory,
    );
  }
}
