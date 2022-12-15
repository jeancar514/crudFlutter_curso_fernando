import 'package:flutter/material.dart';
import 'package:formvalidation/src/bloc/login_bloc.dart';
import 'package:formvalidation/src/models/product_model.dart';
import 'package:formvalidation/src/providers/productos_provider.dart';

import '../bloc/provider.dart';

class HomePage extends StatelessWidget {
  final productosProvider = ProductosProvider();

  HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    LoginBloc bloc = Provider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: [],
        title: Text('Home'),
      ),
      body: _crearListado(),
      floatingActionButton: _crearBoton(context),
    );
  }

  Widget _crearListado() {
    return FutureBuilder(
      future: productosProvider.cargarProductos(),
      builder:
          (BuildContext context, AsyncSnapshot<List<ProductoModel>> snapshot) {
        if (snapshot.hasData) {
          final productos = snapshot.data;
          return ListView.builder(
            itemCount: productos?.length,
            itemBuilder: (BuildContext context, int index) =>
                _crearItem(productos![index], context),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _crearItem(ProductoModel producto, BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        color: Colors.deepPurple[100],
      ),
      onDismissed: (direccion) {
        //borrar producto
        String? productoId = (producto.id == null) ? "" : producto.id;
        productosProvider.borrarProducto(productoId);
      },
      child: ListTile(
        title: Text('${producto.titulo} - ${producto.valor}'),
        subtitle: Text('${producto.id}'),
        onTap: () =>
            Navigator.pushNamed(context, 'producto', arguments: producto),
      ),
    );
  }

  _crearBoton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () => Navigator.pushNamed(context, 'producto'),
      child: Icon(Icons.add),
    );
  }
}
