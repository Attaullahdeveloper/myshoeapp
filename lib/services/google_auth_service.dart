import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleAuthService {
  static Future<AuthResponse?> continueWithGoogle() async {
    try {
      final webClientId = dotenv.env['WEB_CLIENT'] ??
          dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
          '601981642978-3qh7tifercjk5qrvqdq28otpuahaph3a.apps.googleusercontent.com';
      final iosClientId = dotenv.env['IOS_CLIENT'] ??
          dotenv.env['GOOGLE_IOS_CLIENT_ID'] ??
          '601981642978-a91v174uddp1t0fh6hhs8c0po2genf6b.apps.googleusercontent.com';

      // ── Web Platform ──────────────────────────────────────────
      if (kIsWeb) {
        // Native Supabase OAuth flow for Web
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
        );
        return null;
      }

      // ── Mobile Platforms (Android / iOS) ──────────────────────
      final GoogleSignIn signIn = GoogleSignIn.instance;
      final isAndroid = defaultTargetPlatform == TargetPlatform.android;

      await signIn.initialize(
        serverClientId: webClientId,
        clientId: isAndroid ? null : iosClientId,
      );

      final GoogleSignInAccount account = await signIn.authenticate();
      final String idToken = account.authentication.idToken ?? '';
      final authorization = await account.authorizationClient
              .authorizationForScopes(['email', 'profile']) ??
          await account.authorizationClient.authorizeScopes(['email', 'profile']);

      final result = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );
      return result;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
