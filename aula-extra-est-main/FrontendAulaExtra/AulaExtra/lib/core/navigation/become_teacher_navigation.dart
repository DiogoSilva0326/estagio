import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void navigateToBecomeTeacherFlow(BuildContext context) {
  final user = context.read<UserProvider>();
  final targetRoute = user.isLoggedIn
      ? Routes.becomeTeacher
      : Routes.registerStudent;

  Navigator.of(context).pushNamed(targetRoute);
}