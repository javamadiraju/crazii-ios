import 'package:flutter/material.dart';

class CreditInfoComponent extends StatelessWidget {
  final String creditText;
  final int creditValue;

  const CreditInfoComponent({
    Key? key,
    this.creditText = 'Credit',
    this.creditValue = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 80, // Minimum width to ensure content fits
        maxHeight: 60, // Fixed height based on content
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            creditText,
            style: TextStyle(
              fontFamily: 'Exo',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            creditValue.toString(),
            style: const TextStyle(
              fontFamily: 'Exo',
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

