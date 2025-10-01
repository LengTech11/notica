import 'package:flutter/material.dart';

/// Model class representing an onboarding page
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color? color;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.color,
  });
}
