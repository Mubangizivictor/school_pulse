import 'package:google_sign_in/google_sign_in.dart';

/// Every `GoogleSignIn` instance used for owner authentication (first-factor
/// login, provider linking, and step-up reauthentication) must go through
/// this factory rather than constructing `GoogleSignIn(scopes: ...)`
/// directly. Without `serverClientId` set to the Firebase project's web
/// OAuth client ID (from `google-services.json`'s `client_type: 3` entry),
/// `GoogleSignInAuthentication.idToken` can come back null on Android while
/// `accessToken` is still populated - and passing a null idToken into
/// `GoogleAuthProvider.credential()` crashes the whole process with a
/// native `IllegalArgumentException: Given String is empty or null` deep in
/// firebase-auth's Android SDK, uncatchable from Dart.
GoogleSignIn ownerGoogleSignIn() => GoogleSignIn(
  scopes: const ['email'],
  serverClientId:
      '925585407650-qp8pkr96018bo4ccb5uk0shc05r8o8vn.apps.googleusercontent.com',
);
