class Product {
  final String id;
  final String name;
  final String categoryId;
  final String? categoryName;
  final String reference;
  final int quantity;
  final double purchasePrice;
  final double sellingPrice;

  Product({
    required this.id,
    required this.name,
    required this.reference,
    required this.categoryName,
    required this.quantity,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      reference: json['reference'],
      categoryId: json['category_id'],
      categoryName: json['categories'] != null
          ? json['categories']['name']
          : null,
      quantity: json['quantity'],
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'reference': reference,
      'category_id': categoryId,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
    };
  }
}
