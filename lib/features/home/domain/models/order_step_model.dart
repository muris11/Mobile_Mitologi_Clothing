import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class OrderStepModel {
  final int id;
  final int stepNumber;
  final String title;
  final String description;
  final String type; // 'langsung' | 'ecommerce'
  final int sortOrder;

  const OrderStepModel({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.type,
    required this.sortOrder,
  });

  factory OrderStepModel.fromJson(Map<String, dynamic> json) {
    return OrderStepModel(
      id: ParserUtils.parseInt(json['id']),
      stepNumber: ParserUtils.parseInt(
          json['stepNumber'] ?? json['step_number']),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'langsung',
      sortOrder: ParserUtils.parseInt(json['sortOrder'] ?? json['sort_order']),
    );
  }
}
