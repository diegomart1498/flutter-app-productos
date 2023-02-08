import 'package:flutter/material.dart';

class NotificationsService {
  static GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
    messengerKey.currentState!.showSnackBar(snackBar);
  }
}
//*Tiene relación directa con el MaterialApp en el main
