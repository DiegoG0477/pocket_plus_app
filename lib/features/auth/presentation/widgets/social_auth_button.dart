import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Si usas un SVG para el logo de Google

class SocialAuthButton extends StatelessWidget {
  final String text;
  final String iconAsset; // ej: 'assets/icons/google_logo.svg'
  final VoidCallback onPressed;
  final bool isGoogleIcon; // Para renderizar el logo de Google de forma especial si es necesario

  const SocialAuthButton({
    super.key,
    required this.text,
    required this.iconAsset, // O IconData si prefieres
    required this.onPressed,
    this.isGoogleIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: isGoogleIcon
          // ? SvgPicture.asset(iconAsset, height: 20) // Ejemplo con SVG
          ? Image.asset(iconAsset, height: 20) // Ejemplo con PNG/JPG (necesitarás el asset)
          : Icon(Icons.error), // Placeholder si no es Google y no tienes asset específico
      label: Text(text, style: TextStyle(color: Colors.grey[700])),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[700],
        side: BorderSide(color: Colors.grey[400]!),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}