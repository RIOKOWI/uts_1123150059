import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;


  const GoogleSignInButton({
    super.key,
    this.onPressed, 
    this.isLoading = false
  });

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}