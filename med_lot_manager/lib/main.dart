import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/config/config.dart';
import 'src/config/app_theme.dart';
import 'src/services/api_service.dart';
import 'src/services/notification_service.dart';
import 'src/repositories/auth_repository.dart';
import 'src/repositories/lot_repository.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/lot_provider.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  // Configure environment here
  // Pour utiliser le backend réel, changez useMock à false
  final config = Config.production(); // ou Config.development() pour les mocks
  // Alternative: Config(useMock: false, baseUrl: 'http://localhost:8888')

  final apiService = ApiService(config: config);

  // Repositories (choose mock implementations when useMock=true)
  final authRepo =
      AuthRepository.create(config: config, apiService: apiService);
  final lotRepo = LotRepository.create(config: config, apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        Provider<Config>(create: (_) => config),
        Provider<ApiService>(create: (_) => apiService),
        Provider<AuthRepository>(create: (_) => authRepo),
        Provider<LotRepository>(create: (_) => lotRepo),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(authRepository: authRepo),
        ),
        ChangeNotifierProxyProvider<AuthProvider, LotProvider>(
          create: (ctx) => LotProvider(lotRepository: lotRepo),
          update: (ctx, auth, lotProv) => lotProv!..updateAuth(auth),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'ClinChain - Gestion des lots',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: auth.isAuthenticated ? HomeScreen() : LoginScreen(),
            routes: {
              LoginScreen.routeName: (_) => LoginScreen(),
              HomeScreen.routeName: (_) => HomeScreen(),
            },
          );
        },
      ),
    ),
  );
}
