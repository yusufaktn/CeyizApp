import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_constants.dart';
import 'constants/app_theme.dart';
import 'screens/bohca_screen.dart';
import 'screens/category_screen.dart';
import 'screens/ceyiz_screen.dart';
import 'screens/home_screen.dart';
import 'services/bohca_service.dart';
import 'services/ceyiz_service.dart';
import 'services/local_storage_service.dart';
import 'services/photo_service.dart';
import 'viewmodels/bohca_view_model.dart';
import 'viewmodels/ceyiz_view_model.dart';
import 'viewmodels/home_view_model.dart';
import 'viewmodels/theme_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Servisleri oluştur
  final localStorageService = LocalStorageService();
  final ceyizService = CeyizService(storage: localStorageService);
  final bohcaService = BohcaService(storage: localStorageService);
  final photoService = PhotoService();

  runApp(MyApp(
    ceyizService: ceyizService,
    bohcaService: bohcaService,
    photoService: photoService,
  ));
}

class MyApp extends StatelessWidget {
  final CeyizService ceyizService;
  final BohcaService bohcaService;
  final PhotoService photoService;

  const MyApp({
    super.key,
    required this.ceyizService,
    required this.bohcaService,
    required this.photoService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            ceyizService: ceyizService,
            bohcaService: bohcaService,
            photoService: photoService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CeyizViewModel(
            ceyizService: ceyizService,
            photoService: photoService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BohcaViewModel(
            bohcaService: bohcaService,
            photoService: photoService,
          ),
        ),
        Provider<PhotoService>(
          create: (_) => photoService,
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeViewModel(),
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeViewModel.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              AppConstants.ceyizRoute: (context) => const CeyizScreen(),
              AppConstants.bohcaRoute: (context) => const BohcaScreen(),
              AppConstants.categoryRoute: (context) => const CategoryScreen(),
            },
          );
        },
      ),
    );
  }
}
