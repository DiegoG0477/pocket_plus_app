import 'package:intl/intl.dart'; // Añade intl a pubspec.yaml si no está

class Formatters {
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  // Más formateadores según necesites
}