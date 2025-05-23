import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthenticationPage extends ConsumerStatefulWidget {
  const AuthenticationPage({super.key});

  @override
  ConsumerState<AuthenticationPage> createState() => _AuthenticatioPageState();
}

class _AuthenticatioPageState extends ConsumerState<AuthenticationPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
