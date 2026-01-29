import 'package:go_router/go_router.dart';
import '../../screens/dashboard_screen.dart';
import '../../screens/inventory_screen.dart';
import '../../screens/inventory_history_screen.dart';
import '../../screens/product_detail_screen.dart';
import '../../screens/pos_screen.dart';
import '../../screens/sales_history_screen.dart';
import '../../screens/debts_screen.dart';
import '../../screens/settings_screen.dart';
import '../../widgets/app_layout.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/inventory',
          name: 'inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/inventory/history',
          name: 'inventoryHistory',
          builder: (context, state) => const InventoryHistoryScreen(),
        ),
        GoRoute(
          path: '/inventory/product/:id',
          name: 'productDetail',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ProductDetailScreen(productId: id);
          },
        ),
        GoRoute(
          path: '/pos',
          name: 'pos',
          builder: (context, state) => const POSScreen(),
        ),
        GoRoute(
          path: '/pos/history',
          name: 'salesHistory',
          builder: (context, state) => const SalesHistoryScreen(),
        ),
        GoRoute(
          path: '/debts',
          name: 'debts',
          builder: (context, state) => const DebtsScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
