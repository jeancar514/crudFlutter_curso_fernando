//import 'dart:io';
import 'package:flutter/material.dart';
import 'package:formvalidation/src/providers/productos_provider.dart';
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
  ProductosProvider productoProvider = new ProductosProvider();
  ProductoModel producto = new ProductoModel();
  bool _guardando = false;
  XFile? image;

  @override
  Widget build(BuildContext context) {
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
    bool? valide = formKey.currentState?.validate();
    if (valide == null) return;
    if (!valide) return;

    formKey.currentState?.save();

    setState(() {
      _guardando = true;
    });

    if (image != null) {
      print(image);
      producto.fotoUrl = await productoProvider.subirImage(image!);
    }

    if (producto.id == null) {
      productoProvider.crearProducto(producto);
    } else {
      productoProvider.editarProducto(producto.id, producto);
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
      return Container();
    } else {
      print('direccion de la foto');
      ImageProvider pathImage(String fotoPath) {
        print(fotoPath);
        if (fotoPath != 'assets/no-image.png') {
          String path = 'assets/${fotoPath}';
          //String path = 'assets/no-image.png';
          print(path);
          return AssetImage(path);
        } else {
          return AssetImage(fotoPath);
        }
      }

      return Image(
        image: pathImage(image?.name ?? 'hola.png'),
        height: 300.0,
        fit: BoxFit.cover,
      );
    }
  }

  Future _seleccionarFoto() async {
    _procesarImagen(ImageSource.gallery);
  }

  void _tomarFoto() async {
    _procesarImagen(ImageSource.camera);
  }

  _procesarImagen(ImageSource tipo) async {
    image = await ImagePicker().pickImage(source: tipo);
    if (image != null) {}
    setState(() {});
  }
}
