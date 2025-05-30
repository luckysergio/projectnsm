import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
    "Background message: ${message.notification?.title}, ${message.notification?.body}",
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoAnimation;
  late AnimationController _opacityController;
  late Animation<double> _opacityAnimation;
  String? fcmToken;

  @override
  void initState() {
    super.initState();

    // Saat aplikasi dalam keadaan foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        "Pesan diterima saat aplikasi terbuka: ${message.notification?.title}, ${message.notification?.body}",
      );

      if (message.notification != null && mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(message.notification?.title ?? 'No Title'),
                content: Text(message.notification?.body ?? 'No Body'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    });

    // Saat aplikasi dibuka dari notifikasi (background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
        "Pesan dibuka dari background: ${message.notification?.title}, ${message.notification?.body}",
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });

    // Saat aplikasi dibuka dari notifikasi dalam keadaan terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null && mounted) {
        print(
          "Pesan dari terminated: ${message.notification?.title}, ${message.notification?.body}",
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });

    // Pasang background handler (harus top-level)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Animasi + Init token
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _opacityController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _opacityController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    _opacityController.forward();

    _getFCMToken();
    _checkPermissions();
  }

  Future<void> _getFCMToken() async {
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      print('FCM Token: $fcmToken');
    } catch (e) {
      print('Gagal mendapatkan FCM Token: $e');
    }
  }

  Future<void> _checkPermissions() async {
    List<Permission> permissions = [
      Permission.camera,
      Permission.storage,
      Permission.photos,
      Permission.notification,
    ];

    await permissions.request();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  // Fungsi ini HARUS berada di luar class (top-level function)
  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    print(
      "Pesan diterima di background (top-level): ${message.notification?.title}, ${message.notification?.body}",
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoAnimation,
                child: Image.asset(
                  'assets/images/logo-CV.png',
                  width: 200,
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _opacityController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: const Text(
                      "Aplikasi Sales CV. Niaga Solusi Mandiri",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _opacityController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 10,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.black45,
                      ),
                      child: const Text(
                        "Mulai",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
