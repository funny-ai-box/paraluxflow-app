import 'package:lazyreader/utils/local_storage_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      print("obj2ect-----$googleSignInAccount");
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
      print("errorle---$error");
      return null;
    }
    return null;
  }

  Future<User?> signInWithApple() async {
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

    // 使用Firebase Auth进行登录
    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User? user = authResult.user;
    print(user);
    return user;
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

      print("send email了");
      await LocalStorageUtil.setString('emailForSignIn', email);

      // 发送链接成功
      return true;
    } catch (error) {
      // 打印错误信息
      print('Failed to send verification link: $error');
      // TODO: Handle errors (e.g., show error message)

      // 抛出异常，包含错误信息
      throw Exception('Failed to send verification link: $error');
    }
  }

  Future<User?> signInWithEmailLink(String email, String link) async {
    if (FirebaseAuth.instance.isSignInWithEmailLink(link)) {
      try {
        // The client SDK will parse the code from the link for you.
        final userCredential =
            await _auth.signInWithEmailLink(email: email, emailLink: link);

        // You can access the new user via userCredential.user.

        final User? user = userCredential.user;
        print("uuuuuuuu");
        return user;
      } catch (error) {
        print('Failed to sign in with email link: $error');
        throw Exception('Failed to sign in with email link: $error');
      }
    } else {
      print('Failed to sign in with email invalid');
      throw Exception('verify email link is invalid');
    }
  }
}
