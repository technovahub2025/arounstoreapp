import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../service/authservice.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialPhone = ''});
  final String initialPhone;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  late final _phone = TextEditingController(text: widget.initialPhone);
  final _otp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _verificationId;
  int? _resendToken;
  PhoneAuthCredential? _automaticCredential;
  ConfirmationResult? _webConfirmation;
  int _generation = 0;
  bool _sent = false;
  bool _busy = false;
  String? _message;
  DateTime? _resendAt;
  Timer? _timer;

  int get _seconds => _resendAt == null
      ? 0
      : _resendAt!.difference(DateTime.now()).inSeconds.clamp(0, 600);

  String get _normalizedPhone {
    final digits = _phone.text.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length == 10 ? '+91$digits' : '+$digits';
  }

  String _authError(FirebaseAuthException error) => switch (error.code) {
    'invalid-verification-code' => 'Incorrect SMS code. Please try again.',
    'session-expired' => 'This code expired. Request a new SMS code.',
    'too-many-requests' =>
      'Too many attempts. Please wait before trying again.',
    'quota-exceeded' =>
      'SMS delivery is temporarily unavailable. Please try later.',
    'invalid-phone-number' => 'Enter a valid phone number.',
    'operation-not-allowed' =>
      'Phone verification is not available yet. Please contact support.',
    _ => 'Phone verification failed. Please try again.',
  };

  void _codeSent() {
    _resendAt = DateTime.now().add(const Duration(seconds: 60));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
      if (_seconds == 0) _timer?.cancel();
    });
    setState(() {
      _sent = true;
      _busy = false;
      _message = 'Enter the six-digit SMS code and your new password.';
    });
  }

  Future<void> _submit({bool resend = false}) async {
    if (_busy || (!resend && !_form.currentState!.validate())) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    final requesting = !_sent || resend;
    try {
      if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
        setState(
          () => _message =
              'Use the Android app or website for phone verification.',
        );
        return;
      }
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      if (!mounted) return;
      final auth = FirebaseAuth.instance;
      if (requesting) {
        final generation = ++_generation;
        _automaticCredential = null;
        _otp.clear();
        if (kIsWeb) {
          _webConfirmation = await auth.signInWithPhoneNumber(_normalizedPhone);
          if (mounted && generation == _generation) _codeSent();
        } else {
          final ready = Completer<void>();
          void complete() {
            if (!ready.isCompleted) ready.complete();
          }

          await auth.verifyPhoneNumber(
            phoneNumber: _normalizedPhone,
            forceResendingToken: resend ? _resendToken : null,
            verificationCompleted: (credential) {
              complete();
              if (!mounted || generation != _generation) return;
              setState(() {
                _automaticCredential = credential;
                _sent = true;
                _busy = false;
                _message =
                    'Phone verified. Enter and confirm your new password.';
              });
            },
            verificationFailed: (error) {
              complete();
              if (mounted && generation == _generation) {
                setState(() {
                  _busy = false;
                  _message = _authError(error);
                });
              }
            },
            codeSent: (id, token) {
              complete();
              if (!mounted || generation != _generation) return;
              _verificationId = id;
              _resendToken = token;
              _codeSent();
            },
            codeAutoRetrievalTimeout: (id) {
              complete();
              if (!mounted || generation != _generation) return;
              _verificationId = id;
              if (_busy) setState(() => _busy = false);
            },
          );
          await ready.future.timeout(const Duration(seconds: 90));
        }
        return;
      }
      final UserCredential verified;
      if (kIsWeb) {
        verified = await _webConfirmation!.confirm(_otp.text.trim());
      } else {
        final credential =
            _automaticCredential ??
            PhoneAuthProvider.credential(
              verificationId: _verificationId!,
              smsCode: _otp.text.trim(),
            );
        verified = await auth.signInWithCredential(credential);
      }
      if (!mounted) {
        await auth.signOut();
        return;
      }
      final idToken = await verified.user?.getIdToken(true);
      if (idToken == null) throw StateError('No phone verification token');
      final response = await ApiService.resetPassword(idToken, _password.text);
      if (!mounted) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && data['success'] == true) {
        Navigator.pop(context, true);
      } else {
        setState(
          () => _message =
              data['message']?.toString() ?? 'Unable to update password.',
        );
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _message = _authError(error));
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'Could not complete verification. Please try again.',
        );
      }
    } finally {
      if (!requesting && Firebase.apps.isNotEmpty) {
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {
          /* Backend login is separate. */
        }
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in [_phone, _otp, _password, _confirm]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Forgot password')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Receive a six-digit SMS code on your registered mobile number. Google processes your phone number to prevent abuse. SMS charges may apply.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _phone,
                  enabled: !_sent && !_busy,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Registered phone number',
                  ),
                  validator: (value) =>
                      RegExp(r'^(?:91)?[6-9]\d{9}$').hasMatch(
                        (value ?? '').replaceAll(RegExp(r'[\s+()-]'), ''),
                      )
                      ? null
                      : 'Enter a valid Indian mobile number',
                ),
                if (_sent) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _otp,
                    enabled: !_busy,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Six-digit OTP',
                    ),
                    validator: (value) =>
                        (_automaticCredential != null ||
                            RegExp(r'^\d{6}$').hasMatch(value ?? ''))
                        ? null
                        : 'Enter all six digits',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    enabled: !_busy,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'New password',
                    ),
                    validator: (value) => (value ?? '').length < 8
                        ? 'Use at least 8 characters'
                        : utf8.encode(value!).length > 72
                        ? 'Password is too long'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirm,
                    enabled: !_busy,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Confirm new password',
                    ),
                    validator: (value) => value == _password.text
                        ? null
                        : 'Passwords do not match',
                  ),
                ],
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(_message!, key: const Key('reset-message')),
                  ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : () => _submit(),
                  child: Text(
                    _busy
                        ? 'Please wait…'
                        : _sent
                        ? 'Update password'
                        : 'Send SMS code',
                  ),
                ),
                if (_sent)
                  TextButton(
                    onPressed: _busy || _seconds > 0
                        ? null
                        : () => _submit(resend: true),
                    child: Text(
                      _seconds > 0
                          ? 'Request another code in ${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}'
                          : 'Resend code',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
