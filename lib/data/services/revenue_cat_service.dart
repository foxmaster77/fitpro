import 'dart:async';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/constants.dart';

class RevenueCatService {
  static const String _apiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: 'YOUR_REVENUECAT_API_KEY',
  );
  static const String entitlementId = AppConstants.premiumSku;

  bool _isInitialized = false;
  StreamController<CustomerInfo>? _customerInfoController;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Purchases.configure(PurchasesConfiguration(_apiKey));
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize RevenueCat: $e');
    }
  }

  Future<EntitlementInfos> getEntitlements() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements;
    } catch (e) {
      throw Exception('Failed to get entitlements: $e');
    }
  }

  static bool isAiProEntitlementActive(CustomerInfo info) {
    return info.entitlements.all[entitlementId]?.isActive ?? false;
  }

  Future<bool> isProSubscriber() async {
    try {
      final entitlements = await getEntitlements();
      return entitlements.all[entitlementId]?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Emits the current `ai_pro_monthly` status, then live Purchases updates.
  Stream<bool> watchAiProEntitlement() async* {
    yield await isProSubscriber();
    yield* customerInfoStream.map(isAiProEntitlementActive);
  }

  Future<void> purchaseProSubscription() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final offerings = await Purchases.getOfferings();
      final monthlyOffering = offerings.current?.monthly;

      if (monthlyOffering == null) {
        throw Exception('Monthly offering not available');
      }

      await Purchases.purchasePackage(monthlyOffering);
    } catch (e) {
      throw Exception('Failed to purchase subscription: $e');
    }
  }

  Future<void> restorePurchases() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await Purchases.restorePurchases();
    } catch (e) {
      throw Exception('Failed to restore purchases: $e');
    }
  }

  Stream<CustomerInfo> get customerInfoStream {
    final existing = _customerInfoController;
    if (existing != null) return existing.stream;

    late final CustomerInfoUpdateListener listener;
    final controller = StreamController<CustomerInfo>.broadcast(
      onCancel: () {
        Purchases.removeCustomerInfoUpdateListener(listener);
        _customerInfoController = null;
      },
    );
    listener = (info) {
      if (!controller.isClosed) controller.add(info);
    };
    Purchases.addCustomerInfoUpdateListener(listener);
    _customerInfoController = controller;
    return controller.stream;
  }
}
