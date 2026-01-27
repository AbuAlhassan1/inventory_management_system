import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router/app_router.dart';
import 'core/database/database.dart';
import 'core/repositories/product_repository.dart';
import 'core/repositories/sale_repository.dart';
import 'core/repositories/sale_item_repository.dart';
import 'core/repositories/customer_repository.dart';
import 'core/repositories/exchange_rate_repository.dart';
import 'core/repositories/category_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const LIPSApp());
}

class LIPSApp extends StatelessWidget {
  const LIPSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AppDatabase>(
          create: (_) => AppDatabase(),
        ),
        RepositoryProvider<ProductRepository>(
          create: (context) => ProductRepository(
            RepositoryProvider.of<AppDatabase>(context),
          ),
        ),
        RepositoryProvider<SaleRepository>(
          create: (context) => SaleRepository(
            RepositoryProvider.of<AppDatabase>(context),
          ),
        ),
        RepositoryProvider<SaleItemRepository>(
          create: (context) => SaleItemRepository(
            RepositoryProvider.of<AppDatabase>(context),
          ),
        ),
        RepositoryProvider<CustomerRepository>(
          create: (context) => CustomerRepository(
            RepositoryProvider.of<AppDatabase>(context),
          ),
        ),
        RepositoryProvider<ExchangeRateRepository>(
          create: (context) => ExchangeRateRepository(
            RepositoryProvider.of<AppDatabase>(context),
          ),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(
            RepositoryProvider.of<AppDatabase>(context),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'LIPS - Local Inventory & POS System',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ar', 'IQ'), // Arabic (Iraq) - Primary
          Locale('en', 'US'), // English (US) - Secondary
        ],
        locale: const Locale('ar', 'IQ'), // Default to Arabic RTL
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: GoogleFonts.cairo().fontFamily,
          textTheme: GoogleFonts.cairoTextTheme(),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          fontFamily: GoogleFonts.cairo().fontFamily,
          textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
          brightness: Brightness.dark,
        ),
        themeMode: ThemeMode.system,
      ),
    );
  }
}
