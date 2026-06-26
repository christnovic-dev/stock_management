import '../../../core/constants/supabase_client.dart';

class OrderService {
  Future<void> createOrder({
    required String productId,
    required String productName,
    required String clientName,
    required String sellerName,
    required int quantity,
    required double unitPrice,
  }) async {
    final total = quantity * unitPrice;

    await supabase.from('orders').insert({
      'product_id': productId,
      'product_name': productName,
      'client_name': clientName,
      'seller_name': sellerName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': total,
    });
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final response = await supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
