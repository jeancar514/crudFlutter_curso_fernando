import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:formvalidation/src/bloc/login_bloc.dart';

class Provider extends InheritedWidget {
  static Provider? _instancia;
  factory Provider({Key? key, required Widget child}) =>
      _instancia ??= new Provider._internal(
        key: key,
        child: child,
      );

  final loginBloc = LoginBloc();

  Provider._internal({super.key, required super.child});

  static Provider? providerOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>();
  }

  static LoginBloc of(BuildContext context) {
    return providerOf(context)!.loginBloc;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Provider>('_instancia', _instancia));
  }
}
