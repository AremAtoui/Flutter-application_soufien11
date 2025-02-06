class Expense {
  final String title;
  final double amount;
  final String category;
  final String currency;
  final DateTime date;

  Expense({
    required this.title,
    required this.amount,
    required this.category,
    required this.currency,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'currency': currency,
      'date': date.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      title: json['title'],
      amount: json['amount'],
      category: json['category'],
      currency: json['currency'],
      date: DateTime.parse(json['date']),
    );
  }
}
