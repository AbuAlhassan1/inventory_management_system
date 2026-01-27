import 'package:flutter/material.dart';

enum AppRoute {
  dashboard,
  inventory,
  inventoryHistory,
  pos,
  salesHistory,
  debts,
  settings;

  String get path {
    switch (this) {
      case AppRoute.dashboard:
        return '/dashboard';
      case AppRoute.inventory:
        return '/inventory';
      case AppRoute.inventoryHistory:
        return '/inventory/history';
      case AppRoute.pos:
        return '/pos';
      case AppRoute.salesHistory:
        return '/pos/history';
      case AppRoute.debts:
        return '/debts';
      case AppRoute.settings:
        return '/settings';
    }
  }

  String get arabicLabel {
    switch (this) {
      case AppRoute.dashboard:
        return 'لوحة التحكم';
      case AppRoute.inventory:
        return 'المخزن';
      case AppRoute.inventoryHistory:
        return 'سجل المخزن';
      case AppRoute.pos:
        return 'نقطة البيع';
      case AppRoute.salesHistory:
        return 'سجل المبيعات';
      case AppRoute.debts:
        return 'الديون';
      case AppRoute.settings:
        return 'الإعدادات';
    }
  }

  String get englishLabel {
    switch (this) {
      case AppRoute.dashboard:
        return 'Dashboard';
      case AppRoute.inventory:
        return 'Inventory';
      case AppRoute.inventoryHistory:
        return 'Inventory History';
      case AppRoute.pos:
        return 'POS';
      case AppRoute.salesHistory:
        return 'Sales History';
      case AppRoute.debts:
        return 'Debts';
      case AppRoute.settings:
        return 'Settings';
    }
  }

  IconData get icon {
    switch (this) {
      case AppRoute.dashboard:
        return Icons.dashboard;
      case AppRoute.inventory:
        return Icons.inventory_2;
      case AppRoute.inventoryHistory:
        return Icons.history;
      case AppRoute.pos:
        return Icons.point_of_sale;
      case AppRoute.salesHistory:
        return Icons.receipt_long;
      case AppRoute.debts:
        return Icons.account_balance_wallet;
      case AppRoute.settings:
        return Icons.settings;
    }
  }
}
