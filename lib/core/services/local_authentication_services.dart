import 'package:finman/ui/shared/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

class LocalAuthenticationService {
  final _authentication = LocalAuthentication();

  bool isProtectionEnabled = false;
  bool isAuthenticated = false;

  Future<bool> canAuthenticate() async {
    final bool canAuthenticateWithBiometrics =
        await _authentication.canCheckBiometrics;
    if (!canAuthenticateWithBiometrics ||
        !await _authentication.isDeviceSupported()) {
      return false;
    }
    try {
      _authentication.authenticate(localizedReason: "");
    } catch (e) {
      return false;
    }
    _authentication.stopAuthentication();
    return true;
  }

  Future<bool> authenticate(BuildContext context) async {
    try {
      return _authentication.authenticate(
          localizedReason: getAppLocalizations(context)!.authenticationRequired,
          options: const AuthenticationOptions(useErrorDialogs: false));
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        return true;
      }
      return false;
    }
  }
}
