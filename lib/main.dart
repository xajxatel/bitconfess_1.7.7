import 'package:bitsconfess/firebase_service/repo/auth.dart';
import 'package:bitsconfess/firebase_service/screens/landing.dart';
import 'package:bitsconfess/firebase_options.dart';
import 'package:bitsconfess/helpers/loader.dart';
import 'package:bitsconfess/models/user_model.dart';

import 'package:bitsconfess/interaction_screens/nav_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (_) {
      runApp(
        const ProviderScope(
          child: MyApp(),
        ),
      );
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MaterialApp(
      title: 'bitsconfess',
      debugShowCheckedModeBanner: false,
      home: Consumer(
        builder: (context, ref, child) {
          // Access the stream from the authStreamProvider
          final AsyncValue<User?> userState = ref.watch(authStreamProvider);

          // Process the stream state
          return userState.when(
            data: (user) {
              if (user == null) {
                // If the user is not authenticated, show the landing screen.
                return const LandingScreen();
              } else {
                // If the user is authenticated, fetch the user data from Firestore.
                return FutureBuilder<UserModel?>(
                  future: ref.watch(authServiceProvider).getCurrentUserData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While fetching data, display a loading indicator or any other UI you want.
                      return const MainLoader();
                    }

                    final userModel = snapshot.data;
                    if (userModel == null) {
                      // If user data not found, display an error message or handle it accordingly.
                      return const Text('Error: User data not found');
                    }

                    // If user data is fetched successfully, navigate to NavScreen and pass the username.
                    return NavScreen(
                        username: userModel.username,
                        currentUserId: userModel.uid);
                  },
                );
              }
            },
            loading: () {
              // While the stream is loading, display a loading indicator
              return const MainLoader();
            },
            error: (error, stack) {
              // Handle any error that occurred during stream processing.
              return Text('Error: $error');
            },
          );
        },
      ),
    );
  }
}
