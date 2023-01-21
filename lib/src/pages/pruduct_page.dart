import 'dart:io';

import 'package:flutter/material.dart';
import 'package:formvalidation/src/bloc/provider.dart';
import 'package:formvalidation/src/utils/utils.dart' as utils;
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';

class ProductPage extends StatefulWidget {
  ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  ProductosBloc? productosBloc;
  ProductoModel producto = new ProductoModel();
  bool _guardando = false;
  XFile? image;

  @override
  Widget build(BuildContext context) {
    productosBloc = Provider.productosBloc(context);
    final ProductoModel? prodData =
        ModalRoute.of(context)?.settings.arguments as ProductoModel?;
    if (prodData != null) {
      producto = prodData;
    }
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text('Producto'),
        actions: <Widget>[
          IconButton(
            onPressed: _seleccionarFoto,
            icon: Icon(Icons.photo_size_select_actual),
          ),
          IconButton(
            onPressed: _tomarFoto,
            icon: Icon(Icons.camera_alt),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _mostrarFoto(),
                _crearNombre(),
                _crearPrecio(),
                _crearDisponible(),
                SizedBox(
                  height: 10.0,
                ),
                _crearBoton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearNombre() {
    return TextFormField(
      initialValue: producto.titulo,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: 'Producto',
      ),
      onSaved: (value) => producto.titulo = value,
      validator: (value) {
        int valueLength = (value == null) ? 0 : value.length;
        return (valueLength < 3) ? 'Ingrese el nombre del producto' : null;
      },
    );
  }

  Widget _crearPrecio() {
    return TextFormField(
      initialValue: producto.valor.toString(),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Precio',
      ),
      onSaved: (value) => producto.valor = double.parse(value!),
      validator: (value) {
        if (utils.isNumeric(value!)) {
          return null;
        } else {
          return 'Solo numeros';
        }
      },
    );
  }

  Widget _crearBoton(BuildContext context) {
    ButtonStyle _styleButton() {
      return ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: 35.0,
          vertical: 15.0,
        ),
        textStyle: TextStyle(
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      );
    }

    return ElevatedButton.icon(
      style: _styleButton(),
      onPressed: (_guardando) ? null : _submit,
      icon: Icon(Icons.save),
      label: Text('Guardar'),
    );
  }

  void _submit() async {
    print("hola");
    bool? valide = formKey.currentState?.validate();
    print('validate ${valide}');
    if (valide == null) return;
    if (!valide) return;

    formKey.currentState?.save();

    setState(() {
      _guardando = true;
    });
    if (image != null) {
      // ignore: await_only_futures
      producto.fotoUrl = await productosBloc?.subirFoto(image);
    }

    if (producto.id == null) {
      productosBloc?.agregarProducto(producto);
    } else {
      productosBloc?.editarProducto(producto);
    }
    mostrarSnackbar('Registro guardado');
    Navigator.pop(context);
  }

  void mostrarSnackbar(String mensaje) {
    final snackbar = SnackBar(
      content: Text(mensaje),
      duration: Duration(milliseconds: 1500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Widget _crearDisponible() {
    return SwitchListTile(
      value: producto.disponible,
      title: Text('Disponible'),
      activeColor: Colors.deepPurple,
      onChanged: (bool value) => setState(() {
        producto.disponible = value;
      }),
    );
  }

  Widget _mostrarFoto() {
    // TODO: tengo que hecer esto
    if (producto.fotoUrl != null) {
      return FadeInImage(
        placeholder: AssetImage('assets/jar-loading.gif'),
        image: imagenNetwork(producto.fotoUrl),
      );
    } else {
      return Image(
        image: obtenerImage(image?.path ?? 'assets/no-image.png'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  imagenNetwork(imagenUrl) {
    if (imagenUrl == null) {
      return AssetImage('assets/no-image.png');
    } else {
      return NetworkImage(imagenUrl);
    }
  }

  obtenerImage(imagePath) {
    print(imagePath);
    return (imagePath == 'assets/no-image.png')
        ? AssetImage(imagePath)
        : FileImage(File(image?.path ?? 'assets/no-image.png'));
  }

  Future _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
  }

  void _tomarFoto() async {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource tipo) async {
    image = await ImagePicker().pickImage(source: tipo);
    if (image != null) {
      //limpieza
      producto.fotoUrl = null;
    }
    setState(() {});
  }
}
