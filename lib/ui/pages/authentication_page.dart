import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fundy/core/services/local_authentication_services.dart';
import 'package:fundy/ui/pages/overview_page.dart';
import 'package:fundy/ui/shared/localization.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<StatefulWidget> createState() => AuthenticationPageState();
}

class AuthenticationPageState extends State<AuthenticationPage> {
  void _handleAuthentication() async {
    bool result = await LocalAuthenticationService().authenticate(context);
    if (!result) return;
    if (!context.mounted) return;

    Navigator.pushNamed(context, '/overview');
  }

  Widget _createAuthenticateButton() {
    return ElevatedButton(
        onPressed: () => _handleAuthentication(),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(const CircleBorder()),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
        ),
        child: const Icon(
          Icons.lock,
          size: 30,
        ));
  }

  Widget _createAuthenticationWidget() {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              getAppLocalizations(context)!.authenticate,
            style: const TextStyle(fontSize: 30),
            ),
          ),
          _createAuthenticateButton()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LocalAuthenticationService().canAuthenticate(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error is! PlatformException) {
            return _createAuthenticationWidget();
          }
          PlatformException error = snapshot.error as PlatformException;
          if (error.code == auth_error.notAvailable) {
            return const OverviewPage();
          } else {
            return _createAuthenticationWidget();
          }
        }
        if (snapshot.hasData && snapshot.data!) {
          _handleAuthentication();
          return _createAuthenticationWidget();
        }
        return const OverviewPage();
      },
    );
  }
}
