import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:formvalidation/src/bloc/login_bloc.dart';
export 'package:formvalidation/src/bloc/login_bloc.dart';
import 'package:formvalidation/src/bloc/productos_bloc.dart';
export 'package:formvalidation/src/bloc/productos_bloc.dart';

class Provider extends InheritedWidget {
  final loginBloc = LoginBloc();
  final _productosBloc = ProductosBloc();

  static Provider? _instancia;
  factory Provider({Key? key, required Widget child}) =>
      _instancia ??= new Provider._internal(
        key: key,
        child: child,
      );

  Provider._internal({super.key, required super.child});

  static Provider? providerOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Provider>();
  }

  static LoginBloc of(BuildContext context) {
    return providerOf(context)!.loginBloc;
  }

  static ProductosBloc productosBloc(BuildContext context) {
    return providerOf(context)!._productosBloc;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Provider>('_instancia', _instancia));
  }
}
