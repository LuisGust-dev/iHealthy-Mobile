import 'package:flutter/material.dart';
import 'package:ihealthy/features/auth/presentation/widgets/register_form.dart';

/// Página de cadastro do usuário.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const String _title = 'Cadastro';
  static const double _defaultPadding = 16.0;

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(_title),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(_defaultPadding),
        child: SingleChildScrollView(
          child: RegisterForm(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }
}
