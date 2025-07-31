import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_plus/core/router/app_routes.dart'; // Ajusta ruta
import 'package:pocket_plus/core/utils/validators.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/presentation/widgets/auth_text_field.dart'; // Ajusta ruta
// import 'package:pocket_plus/features/auth/presentation/widgets/social_auth_button.dart'; // Para botón Google

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
            nombre: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Color(0xFFF2C94C); // Color amarillo del botón

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
          } else if (state is AuthSuccess) {
            // Navegar al dashboard o pantalla principal
            context.go(AppRoutes.dashboard); // O la ruta que definas para post-login
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Crear cuenta',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Únete y comienza a organizar tu contenido favorito',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  Text('Nombre completo', style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _nameController,
                    hintText: 'Tu nombre',
                    prefixIcon: Icons.person_outline,
                    validator: (value) => Validators.requiredField(value, 'Nombre completo'),
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocusNode),
                  ),
                  const SizedBox(height: 20),
                  Text('Email', style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    hintText: 'tu@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
                  ),
                  const SizedBox(height: 20),
                  Text('Contraseña', style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: Validators.password,
                    onFieldSubmitted: (_) => _submitForm(),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: state is AuthLoading ? null : _submitForm,
                    child: state is AuthLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black54))
                        : const Text('Crear cuenta', style: TextStyle(color: Colors.black87)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text('o continúa con', style: TextStyle(color: Colors.grey[600])),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // SocialAuthButton(
                  //   text: 'Google',
                  //   iconAsset: 'assets/icons/google_logo.png', // Asegúrate de tener este asset
                  //   onPressed: () {
                  //     // TODO: Implementar login con Google
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('Login con Google no implementado')),
                  //     );
                  //   },
                  //   isGoogleIcon: true,
                  // ),
                  // const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: '¿Ya tienes cuenta? ',
                        style: TextStyle(color: Colors.grey[700], fontSize: 15),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Inicia sesión',
                            style: TextStyle(
                              color: primaryColor, // O theme.primaryColor
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                if (context.canPop()) {
                                  context.pop(); // Vuelve a Login si vino de ahí
                                } else {
                                  context.go(AppRoutes.login); // Va a Login
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                   const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}