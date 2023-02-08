import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _isLoading = false;
  //* La propiedad _isLoading es privada para que ningún otro desarrollador vaya
  //* a cambiarla, por eso se hace un get, para conseguir ese valor
  bool get isLoading => _isLoading;
  //* Cuando se establezca un nuevo valor al isLoading, el set se dispara para notificar
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool isValidForm() {
    //print('$email - $password');
    //print(formKey.currentState?.validate());
    return formKey.currentState?.validate() ?? false;
  }
}
