// lib/service/auth_service.dart
import 'package:lazyreader/utils/local_storage_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:lazyreader/utils/http_util.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;
        return user;
      }
    } catch (error) {
      print("登录错误: $error");
      return null;
    }
    return null;
  }

  Future<User?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      final User? user = authResult.user;
      return user;
    } catch (error) {
      print("Apple登录错误: $error");
      return null;
    }
  }

  Future<bool> sendSignInLinkToEmail(String email) async {
    try {
      final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
          url: 'https://ailazyreader.page.link/qL6j?email=$email',
          handleCodeInApp: true,
          iOSBundleId: 'com.futurelabs.lazyreader',
          androidPackageName: 'com.futurelabs.lazyreader',
          androidInstallApp: true,
          androidMinimumVersion: '12',
          dynamicLinkDomain: "ailazyreader.page.link");

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      await LocalStorageUtil.setString('emailForSignIn', email);
      return true;
    } catch (error) {
      print('发送验证链接失败: $error');
      throw Exception('发送验证链接失败: $error');
    }
  }

  Future<User?> signInWithEmailLink(String email, String link) async {
    if (_auth.isSignInWithEmailLink(link)) {
      try {
        final userCredential =
            await _auth.signInWithEmailLink(email: email, emailLink: link);
        final User? user = userCredential.user;
        return user;
      } catch (error) {
        print('邮箱链接登录失败: $error');
        throw Exception('邮箱链接登录失败: $error');
      }
    } else {
      throw Exception('邮箱验证链接无效');
    }
  }
  
  Future<void> logout() async {
    try {
      await HttpUtil.request('/api/client/v1/auth/logout', method: 'POST');
      await _auth.signOut();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await LocalStorageUtil.remove('customUser');
      await LocalStorageUtil.remove('token');
    } catch (e) {
      print('登出失败: $e');
      throw Exception('登出失败: $e');
    }
  }
}