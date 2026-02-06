class Product {
  final String id;
  final String name;
  final String? image;
  final String? price;
  final String? status;

  Product({
    required this.id,
    required this.name,
    this.image,
    this.price,
    this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      // image: json['image'] ?? json['thumbnail'],
      price: json['price']?.toString(),
      status: json['status'],
    );
  }
}

class ProductsResponse {
  final ProductsPagination products;

  ProductsResponse({required this.products});

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      products: ProductsPagination.fromJson(json['products'] ?? {}),
    );
  }
}

class ProductsPagination {
  final List<Product> data;
  final int total;

  ProductsPagination({required this.data, required this.total});

  factory ProductsPagination.fromJson(Map<String, dynamic> json) {
    return ProductsPagination(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}

class SingleProductResponse {
  final Product product;

  SingleProductResponse({required this.product});

  factory SingleProductResponse.fromJson(Map<String, dynamic> json) {
    return SingleProductResponse(
      product: Product.fromJson(json['product'] ?? {}),
    );
  }
}
