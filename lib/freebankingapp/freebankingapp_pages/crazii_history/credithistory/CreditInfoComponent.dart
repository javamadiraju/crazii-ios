import 'package:flutter/material.dart';

class CreditInfoComponent extends StatelessWidget {
  final int creditAmount;
  final VoidCallback onCreditTap;

  const CreditInfoComponent({
    Key? key,
    this.creditAmount = 10, // Default value
    this.onCreditTap = _defaultOnTap,
  }) : super(key: key);

  static void _defaultOnTap() {
    // Default empty callback
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: 80,
        minHeight: 48,
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent, // Inherit background color from parent
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onCreditTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Credit',
                      style: TextStyle(
                        fontFamily: 'Exo',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$creditAmount',
                style: TextStyle(
                  fontFamily: 'Exo',
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

