import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'core/config/environment.dart';
import 'core/services/auth_service.dart';
import 'core/services/socket_service.dart';
import 'core/services/webrtc_service.dart';
import 'core/services/media_service.dart';
import 'core/services/call_manager.dart';
import 'core/models/user.dart';
import 'core/models/call_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/chat/screens/chat_list_screen.dart';
import 'features/chat/screens/chat_screen.dart';
import 'features/chat/screens/media_viewer_screen.dart';
import 'features/calls/screens/incoming_call_screen.dart';
import 'features/calls/screens/active_call_screen.dart';
import 'features/contacts/screens/contacts_screen.dart';
import 'features/contacts/screens/qr_scanner_screen_stub.dart'
    if (dart.library.io) 'features/contacts/screens/qr_scanner_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Print environment configuration for debugging
  Environment.printConfig();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Service
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        
        // Socket Service
        Provider<SocketService>(
          create: (_) => SocketService(),
        ),
        
        // WebRTC Service
        ProxyProvider<SocketService, WebRTCService>(
          update: (_, socketService, previous) {
            if (previous != null) {
              return previous;
            }
            return WebRTCService(socketService);
          },
          dispose: (_, service) => service.dispose(),
        ),
        
        // Media Service
        ProxyProvider<AuthService, MediaService>(
          update: (_, authService, __) => MediaService(authService),
        ),
        
        // Call Manager
        ProxyProvider<WebRTCService, CallManager>(
          update: (_, webrtcService, previous) {
            if (previous != null) {
              return previous;
            }
            return CallManager(webrtcService, navigatorKey);
          },
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'WebRTC Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryCyan,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primaryCyan,
            primary: AppColors.primaryCyan,
            secondary: AppColors.darkCyan,
          ),
          scaffoldBackgroundColor: AppColors.white,
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          return _generateRoute(settings);
        },
        home: const SplashScreen(),
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case '/chat':
        final contact = settings.arguments as User;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(contact: contact),
        );
      case '/contacts':
        return MaterialPageRoute(builder: (_) => const ContactsScreen());
      case '/qr-scanner':
        return MaterialPageRoute(builder: (_) => const QRScannerScreen());
      case '/incoming-call':
        final callState = settings.arguments as CallState;
        return MaterialPageRoute(
          builder: (_) => IncomingCallScreen(callState: callState),
          fullscreenDialog: true,
        );
      case '/active-call':
        return MaterialPageRoute(
          builder: (_) => const ActiveCallScreen(),
          fullscreenDialog: true,
        );
      case '/media-viewer':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MediaViewerScreen(
            mediaUrl: args['url'],
            isVideo: args['isVideo'] ?? false,
          ),
        );
      default:
        return null;
    }
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Initialize auth service
    final isAuthenticated = await authService.init();
    
    // Wait a bit for splash screen
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      if (isAuthenticated && authService.token != null) {
        // Connect to socket
        final socketService = Provider.of<SocketService>(context, listen: false);
        await socketService.connect(authService.token!);
        
        // Initialize call manager (sets up listeners)
        Provider.of<CallManager>(context, listen: false);
        
        // Navigate to home
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        // Navigate to login
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryCyan,
              AppColors.darkCyan,
              AppColors.lightCyan,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.video_call_rounded,
                  size: 100,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'WebRTC Chat',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Secure voice and video calls',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
