class VoicePurchaseParser {
  static Map<String, dynamic> parse(String input) {
    final text = input.toLowerCase();

    final litersMatch = RegExp(r'(\d+(?:\.\d+)?)\s*lit').firstMatch(text);
    final densityMatch = RegExp(r'density\s*(\d+)').firstMatch(text);
    final rateMatch = RegExp(r'rate\s*(\d+(?:\.\d+)?)').firstMatch(text);

    String status = text.contains('paid') ? 'Paid' : 'Not Paid';

    String sellerName = 'Unknown Seller';
    final words = input.trim().split(' ');
    if (words.isNotEmpty) {
      sellerName = words.first;
    }

    return {
      'sellerName': sellerName,
      'liters': litersMatch != null
          ? double.tryParse(litersMatch.group(1) ?? '0') ?? 0
          : 0,
      'density': densityMatch != null
          ? int.tryParse(densityMatch.group(1) ?? '0') ?? 0
          : 0,
      'rate': rateMatch != null
          ? double.tryParse(rateMatch.group(1) ?? '0') ?? 0
          : 0,
      'status': status,
    };
  }
}
