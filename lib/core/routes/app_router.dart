import 'package:go_router/go_router.dart';
import 'package:stock_management/features/clients/pages/client_pages.dart';
import 'package:stock_management/features/commandes/pages/commande_page.dart';

import '../../features/categories/pages/category_page.dart';
import '../../features/dashboard/pages/dashboard_page.dart';
import '../../features/employes/pages/employes_pages.dart';
import '../../features/products/pages/products_pages.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const DashboardPage();
      },
    ),

    GoRoute(
      path: '/products',
      builder: (context, state) {
        return const ProductsPage();
      },
    ),

    GoRoute(
      path: '/categories',
      builder: (context, state) {
        return const CategoriesPage();
      },
    ),

    GoRoute(
      path: '/commandes',
      builder: (context, state) {
        return const OrdersPage();
      },
    ),

    GoRoute(
      path: '/clients',
      builder: (context, state) {
        return const ClientPage();
      },
    ),

    GoRoute(
      path: '/employes',
      builder: (context, state) {
        return const EmployesPage();
      },
    ),
  ],
);
