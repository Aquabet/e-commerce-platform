class Review {
  final int? id;
  final int productId;
  final String reviewText;
  final int rating;

  Review({
    this.id,
    required this.productId,
    required this.reviewText,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'review_text': reviewText,
      'rating': rating,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      productId: map['product_id'],
      reviewText: map['review_text'],
      rating: map['rating'],
    );
  }
}
