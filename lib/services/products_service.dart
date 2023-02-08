import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:productos_app/model/product.dart';
import 'package:http/http.dart' as http;

class ProductsService extends ChangeNotifier {
  final String _baseUrl = 'flutter-varios-60b53-default-rtdb.firebaseio.com';
  final List<Product> products = [];
  bool isLoading = true;
  bool isSaving = false;
  late Product selectedproduct;
  File? newPictureFile;
  final storage = const FlutterSecureStorage();

  ProductsService() {
    loadProducts();
  }
  //* <List<Product>>
  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();
    final Uri url = Uri.https(_baseUrl, 'products.json',
        {'auth': await storage.read(key: 'token') ?? ''});
    final resp = await http.get(url);
    final Map<String, dynamic> productsMap = json.decode(resp.body);
    productsMap.forEach((key, value) {
      //print('$key - $value');
      final tempProduct = Product.fromJson(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });
    //print(productsMap);
    isLoading = false;
    notifyListeners();
    return products; //* Puede estar de más porque se llama en el Provider
  }

  Future saveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();
    if (product.id == null) {
      //Es necesario crear
      await createProduct(product);
    } else {
      //Actualizar
      await updateProduct(product);
    }
    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    //Petición al back-end
    final Uri url = Uri.https(_baseUrl, 'products/${product.id}.json',
        {'auth': await storage.read(key: 'token') ?? ''});
    final resp =
        await http.put(url, body: product.toRawJson()); //put para actualizar
    final decodedData = resp.body;
    //print(decodedData);
    //* Actualizar la lista de productos
    final index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;
    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    //Petición al back-end
    final Uri url = Uri.https(_baseUrl, 'products.json',
        {'auth': await storage.read(key: 'token') ?? ''});
    final resp =
        await http.post(url, body: product.toRawJson()); //post para crear
    final decodedData = json.decode(resp.body);
    //print(decodedData['name']);
    product.id = decodedData['name'];
    products.add(product);
    return product.id!;
  }

  void updateSelectedProductImage(String path) {
    selectedproduct.picture = path;
    newPictureFile = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (newPictureFile == null) return null;
    isSaving = true;
    notifyListeners();
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dmf6vr5fq/image/upload?upload_preset=wdvccozz');
    final imageUploadRequest =
        http.MultipartRequest('POST', url); //Crear petición
    final file = await http.MultipartFile.fromPath(
        'file', newPictureFile!.path); //Adjuntar el file
    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      //print('Algo salió mal');
      //print(resp.body);
      return null;
    }
    newPictureFile = null;
    final decodedData = json.decode(resp.body);
    return decodedData['secure_url'];
  }
}
