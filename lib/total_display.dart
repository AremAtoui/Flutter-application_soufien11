import 'package:flutter/material.dart';

class TotalDisplay extends StatelessWidget {
  final String baseCurrency;
  final double total;

  TotalDisplay({required this.baseCurrency, required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text(
          'Total in $baseCurrency : ${total.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
