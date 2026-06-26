import '../../../core/constants/supabase_client.dart';
import '../models/product_model.dart';

class ProductService {
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    final response = await supabase
        .from('products')
        .select('*, categories(name)')
        .eq('category_id', categoryId);

    return response.map<Product>((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> getProducts() async {
    final response = await supabase
        .from('products')
        .select('*, categories(name)');

    return response.map<Product>((json) => Product.fromJson(json)).toList();
  }

  Future<void> addProduct({
    required String name,
    required String category,
    required String reference,
    required int quantity,
    required double purchasePrice,
    required double sellingPrice,
  }) async {
    await supabase.from('products').insert({
      'name': name,
      'category_id': category,
      'reference': reference,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
    });
  }

  Future<void> deleteProduct(String id) async {
    await supabase.from('products').delete().eq('id', id);
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String categoryId,
    required String reference,
    required int quantity,
    required double purchasePrice,
    required double sellingPrice,
  }) async {
    await supabase
        .from('products')
        .update({
          'name': name,
          'category_id': categoryId,
          'reference': reference,
          'quantity': quantity,
          'purchase_price': purchasePrice,
          'selling_price': sellingPrice,
        })
        .eq('id', id);
  }
}
