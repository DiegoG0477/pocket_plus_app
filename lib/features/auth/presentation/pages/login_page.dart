import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_plus/core/router/app_routes.dart'; // Ajusta ruta
import 'package:pocket_plus/core/utils/validators.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Ajusta ruta
import 'package:pocket_plus/features/auth/presentation/widgets/auth_text_field.dart'; // Ajusta ruta
// import 'package:pocket_plus/features/auth/presentation/widgets/social_auth_button.dart'; // Para botón Google

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // TODO: Manejar lógica de "Recordarme" si es necesario (ej. guardar email)
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
          onPressed: () => context.pop(), // Asumiendo que llega desde Overview
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
            print(
              "🟢 LOGIN_PAGE LISTENER: AuthSuccess detectado. Intentando navegar a ${AppRoutes.dashboard}",
            );
            context.go(AppRoutes.dashboard); // Navegar al dashboard
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
                    'Bienvenido de vuelta',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia sesión para continuar organizando tu contenido',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Email',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'tu@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Contraseña',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
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
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 24, // Para alinear el checkbox con el texto
                            height: 24,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: primaryColor, // Color del check
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Recordarme',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implementar recuperación de contraseña
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Recuperación de contraseña no implementada',
                              ),
                            ),
                          );
                        },
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: state is AuthLoading ? null : _submitForm,
                    child: state is AuthLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black54,
                            ),
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(color: Colors.black87),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: <Widget>[
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'o continúa con',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
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
                  //      ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('Login con Google no implementado')),
                  //     );
                  //   },
                  //   isGoogleIcon: true,
                  // ),
                  // const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: '¿No tienes cuenta? ',
                        style: TextStyle(color: Colors.grey[700], fontSize: 15),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Regístrate',
                            style: TextStyle(
                              color: primaryColor, // O theme.primaryColor
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.push(
                                AppRoutes.register,
                              ), // Usa push para poder volver
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
