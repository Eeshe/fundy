import 'package:fundy/ui/shared/localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

class LocalAuthenticationService {
  final _authentication = LocalAuthentication();

  bool isProtectionEnabled = false;
  bool isAuthenticated = false;

  Future<bool> canAuthenticate() async {
    return _authentication.isDeviceSupported();
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
