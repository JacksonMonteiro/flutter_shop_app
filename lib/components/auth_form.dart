import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/providers/auth.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm>
    with SingleTickerProviderStateMixin {
  final Map<String, dynamic> _authData = {
    'email': '',
    'password': '',
  };
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AuthMode _authMode = AuthMode.login;

  bool _isLogin() => _authMode == AuthMode.login;
  bool _isSignup() => _authMode == AuthMode.signup;
  bool _isLoading = false;

  AnimationController? _controller;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(
          milliseconds: 250,
        ));

    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.linear));

    _slideAnimation = Tween(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.linear));
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      if (_isLogin()) {
        _authMode = AuthMode.signup;
        _controller?.forward();
      } else {
        _authMode = AuthMode.login;
        _controller?.reverse();
      }
    });
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: (context),
      builder: (context) => AlertDialog(
        title: const Text('Ocurred an error'),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    _formKey.currentState?.save();
    Auth auth = Provider.of(context, listen: false);

    try {
      if (_isLogin()) {
        await auth.login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        await auth.singup(
          _authData['email']!,
          _authData['password']!,
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog('Ocurred an unespected error');
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.linear,
        padding: const EdgeInsets.all(16),
        height: _isLogin() ? 310 : 400,
        width: mQuery.size.width * 0.75,
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (em) {
                    final email = em ?? '';

                    if (email.trim().isEmpty || !email.contains('@')) {
                      return 'Insert a valid email (Not empty and have the structure name@domain.com)';
                    }

                    return null;
                  },
                  onSaved: (email) => _authData['email'] = email ?? '',
                ),
                TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    keyboardType: TextInputType.emailAddress,
                    obscureText: true,
                    controller: passwordController,
                    onSaved: (password) =>
                        _authData['password'] = password ?? '',
                    validator: (pass) {
                      final password = pass ?? '';

                      if (password.isEmpty || password.length < 6) {
                        return 'Insert a valid password (Not empty and at least 6 characters)';
                      }

                      return null;
                    }),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _isLogin() ? 0 : 60,
                    maxHeight: _isLogin() ? 0 : 120,
                  ),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.linear,
                  child: FadeTransition(
                    opacity: _opacityAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Confirm Password'),
                        keyboardType: TextInputType.emailAddress,
                        obscureText: true,
                        validator: _isLogin()
                            ? null
                            : (pass) {
                                final password = pass ?? '';

                                if (password != passwordController.text) {
                                  return 'Password can\'t be different';
                                }

                                return null;
                              },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 8,
                      ),
                      primary: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      _authMode == AuthMode.login ? 'Login' : 'Signup',
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                const Spacer(),
                TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(_isLogin()
                        ? 'Don\'t have an account? Click here to create'
                        : 'Have an account? Click here to login'))
              ],
            )),
      ),
    );
  }
}

enum AuthMode { signup, login }
