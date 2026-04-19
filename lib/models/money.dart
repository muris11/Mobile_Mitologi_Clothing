/// Money/Price model
class Money {
  final double amount;
  final String currencyCode;
  final String? currencySymbol;

  Money({required this.amount, this.currencyCode = 'IDR', this.currencySymbol});

  factory Money.fromJson(dynamic json) {
    // Handle direct number
    if (json is num) {
      return Money(amount: json.toDouble());
    }

    // Handle string that represents a number
    if (json is String) {
      final parsed = double.tryParse(json);
      if (parsed != null) {
        return Money(amount: parsed);
      }
    }

    // Handle Map structure
    if (json is Map<String, dynamic>) {
      // Parse amount safely
      double amount = 0;
      final amountData = json['amount'];
      if (amountData is num) {
        amount = amountData.toDouble();
      } else if (amountData is String) {
        amount = double.tryParse(amountData) ?? 0;
      }

      return Money(
        amount: amount,
        currencyCode: json['currency_code']?.toString() ?? 'IDR',
        currencySymbol: json['currency_symbol']?.toString(),
      );
    }

    return Money(amount: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
    };
  }

  /// Format as currency string (IDR)
  String get formatted {
    final symbol = currencySymbol ?? 'Rp';
    final formattedAmount = amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$symbol $formattedAmount';
  }

  @override
  String toString() => formatted;
}
