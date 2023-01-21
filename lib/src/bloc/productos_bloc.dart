import 'package:formvalidation/src/models/product_model.dart';
import 'package:formvalidation/src/providers/productos_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

class ProductosBloc {
  final _productosController = BehaviorSubject<List<ProductoModel>>();
  final _cargandoController = BehaviorSubject<bool>();

  final _productosProvider = ProductosProvider();
  Stream<List<ProductoModel>> get productosStream =>
      _productosController.stream;

  Stream<bool> get cargando => _cargandoController.stream;

  void cargarProductos() async {
    final productos = await _productosProvider.cargarProductos();
    _productosController.sink.add(productos);
  }

  void agregarProducto(ProductoModel producto) async {
    _cargandoController.sink.add(true);
    await _productosProvider.crearProducto(producto);
    _cargandoController.sink.add(false);
  }

  Future<String?> subirFoto(XFile? foto) async {
    _cargandoController.sink.add(true);
    final fotoUrl = await _productosProvider.subirImage(foto);
    _cargandoController.sink.add(false);

    return fotoUrl;
  }

  void editarProducto(ProductoModel producto) async {
    _cargandoController.sink.add(true);
    await _productosProvider.editarProducto(producto);
    _cargandoController.sink.add(false);
  }

  void borrarProducto(String id) async {
    final fotoUrl = await _productosProvider.borrarProducto(id);
  }

  dispose() {
    _productosController?.close();
    _cargandoController?.close();
  }
}
