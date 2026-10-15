import 'dart:convert';

import 'package:arunstore/screen/loginscreen.dart';
import 'package:arunstore/service/authservice.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _message;
  bool _success = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final response = await ApiService.forgotPassword(_emailController.text.trim());
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _success = true;
          _message = 'If an account exists for that email, a password reset link has been sent.';
        });
      } else {
        setState(() {
          _success = false;
          _message = _serverMessage(response.body) ?? 'We couldn’t send the reset link. Please try again.';
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _success = false;
        _message = 'Unable to reach the server. Check your connection and try again.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RecoveryScaffold(
        title: 'Forgot password?',
        subtitle: 'Enter your account email and we’ll send you a reset link.',
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _loading ? null : _submit(),
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty || !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            _FeedbackMessage(message: _message!, success: _success),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send reset link'),
            ),
          ),
          _BackToLogin(onPressed: () => Navigator.pop(context)),
        ],
      );
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.token});
  final String token;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _complete = false;
  String? _message;

  Future<void> _submit() async {
    if (!widget.token.trim().isNotEmpty) {
      setState(() => _message = 'This reset link is missing its token. Request a new link.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _message = null; });
    try {
      final response = await ApiService.resetPassword(widget.token, _passwordController.text);
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() { _complete = true; _message = 'Your password has been reset. You can now log in.'; });
      } else {
        setState(() => _message = _serverMessage(response.body) ?? 'The reset link may have expired. Request a new one and try again.');
      }
    } catch (_) {
      if (mounted) setState(() => _message = 'Unable to reach the server. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _returnToLogin() => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RecoveryScaffold(
        title: 'Reset password',
        subtitle: 'Choose a new password for your account.',
        children: [
          if (!_complete) Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                validator: (value) => (value?.length ?? 0) < 6 ? 'Password must be at least 6 characters' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm new password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                validator: (value) => value != _passwordController.text ? 'Passwords do not match' : null,
                onFieldSubmitted: (_) => _loading ? null : _submit(),
              ),
            ]),
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            _FeedbackMessage(message: _message!, success: _complete),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _loading ? null : (_complete ? _returnToLogin : _submit),
              child: _loading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_complete ? 'Return to login' : 'Reset password'),
            ),
          ),
          if (!_complete) _BackToLogin(onPressed: _returnToLogin),
        ],
      );
}

class _RecoveryScaffold extends StatelessWidget {
  const _RecoveryScaffold({required this.title, required this.subtitle, required this.children});
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(subtitle),
                    const SizedBox(height: 24),
                    ...children,
                  ]),
                ),
              ),
            ),
          ),
        ),
      );
}

class _FeedbackMessage extends StatelessWidget {
  const _FeedbackMessage({required this.message, required this.success});
  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: success ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(message, style: TextStyle(color: success ? Colors.green.shade900 : Colors.red.shade900)),
      );
}

class _BackToLogin extends StatelessWidget {
  const _BackToLogin({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(onPressed: onPressed, child: const Text('Back to login'));
}

String? _serverMessage(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message'] ?? decoded['error'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
  } catch (_) {}
  return null;
}
