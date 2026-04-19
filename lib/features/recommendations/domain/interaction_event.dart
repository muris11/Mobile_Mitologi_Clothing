class InteractionEvent {
  final String type;
  final int productId;
  final String source;

  const InteractionEvent({
    required this.type,
    required this.productId,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'product_id': productId,
      'source': source,
    };
  }
}
