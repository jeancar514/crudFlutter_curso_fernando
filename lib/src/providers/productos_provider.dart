import 'dart:convert';
import 'dart:io';
import 'package:formvalidation/src/preferencias_usuario/preferencias_usuario.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:http_parser/http_parser.dart';
import '../models/product_model.dart';
import 'package:http/http.dart' as http;

class ProductosProvider {
  final String _url = "flutter-varios-fc384-default-rtdb.firebaseio.com";
  final _prefs = new PreferenciasUsuario();

  Future<bool?> crearProducto(ProductoModel producto) async {
    final urlUri = Uri.https(_url, 'productos.json', {'auth': _prefs.token});
    final response =
        await http.post(urlUri, body: productoModelToJson(producto));
    final decodedData = json.decode(response.body);
    return true;
  }

  Future<List<ProductoModel>> cargarProductos() async {
    final urlUri = Uri.https(_url, 'productos.json', {'auth': _prefs.token});
    final response = await http.get(urlUri);
    final Map<String, dynamic> decodedData = json.decode(response.body);
    final List<ProductoModel> productos = [];

    if (decodedData == null) return [];
    if (decodedData['error'] != null) return [];

    decodedData.forEach(
      (id, prod) {
        final prodTem = ProductoModel.fromJson(prod);
        prodTem.id = id;
        productos.add(prodTem);
      },
    );
    return productos;
  }

  Future<int> borrarProducto(String? id) async {
    String patch = 'productos/' + id! + '.json';
    final urlUri = Uri.https(_url, patch, {'auth': _prefs.token});
    final response = await http.delete(urlUri);
    return 1;
  }

  Future<bool> editarProducto(ProductoModel producto) async {
    String patch = 'productos/' + producto.id! + '.json';
    final urlUri = Uri.https(_url, patch, {'auth': _prefs.token});
    final response =
        await http.put(urlUri, body: productoModelToJson(producto));
    final decodedData = json.decode(response.body);
    return true;
  }

  Future<String?> subirImage(XFile? image) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dgfd6vt0s/image/upload?upload_preset=m57xr3pb');

    final mimeType = mime(image?.name)!.split('/'); // image/jpg

    final imageUploadRequest = http.MultipartRequest('POST', url);
    final urlImg = image?.path ?? "";
    print(urlImg);
    final file = await http.MultipartFile.fromPath(
      'file',
      urlImg,
      contentType: MediaType(mimeType[0], mimeType[1]),
    );

    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salio mal');
      print(resp.body);
      return null;
    }

    final respData = json.decode(resp.body);
    print("respData");
    print(respData);
    return respData['secure_url'];
  }
}
