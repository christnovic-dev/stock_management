import '../../../core/constants/supabase_client.dart';

class DashboardService {
  Future<Map<String, dynamic>> getStats() async {
    final products = await supabase.from('products').select();

    final totalProducts = products.length;

    int totalQuantity = 0;
    double stockValue = 0;

    for (final product in products) {
      final quantity = product['quantity'] ?? 0;

      final price = (product['purchase_price'] ?? 0).toDouble();

      totalQuantity += quantity as int;
      stockValue += quantity * price;
    }

    return {
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
      'stockValue': stockValue,
    };
  }

  Future<List<Map<String, dynamic>>> getLowStockProducts() async {
    return await supabase
        .from('products')
        .select()
        .lte('quantity', 5)
        .order('quantity');
  }

  Future<List<Map<String, dynamic>>> getLatestProducts() async {
    return await supabase
        .from('products')
        .select()
        .order('created_at', ascending: false)
        .limit(5);
  }

  Future<List<Map<String, dynamic>>> getTopProducts() async {
    return await supabase
        .from('products')
        .select()
        .order('quantity', ascending: false)
        .limit(5);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final response = await supabase.from('products').select();

    return List<Map<String, dynamic>>.from(response);
  }
}
