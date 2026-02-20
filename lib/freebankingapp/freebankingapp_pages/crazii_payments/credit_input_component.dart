import 'package:flutter/material.dart';

class CreditInputComponent extends StatefulWidget {
  final int initialAmount;
  final double initialTotal;
  final Function(double) onAmountChanged; // Callback for amount change

  const CreditInputComponent({
    Key? key,
    this.initialAmount = 100,
    this.initialTotal = 1.00,
    required this.onAmountChanged,
  }) : super(key: key);

  @override
  _CreditInputComponentState createState() => _CreditInputComponentState();
}

class _CreditInputComponentState extends State<CreditInputComponent> {
  late TextEditingController _amountController;
  late double _total;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.initialAmount.toString());
    _total = widget.initialTotal;
    _amountController.addListener(_updateTotal);
    print('initialacount ${widget.initialAmount}');
  }

  void _updateTotal() {
    final input = _amountController.text;
    final amount = double.tryParse(input);

    setState(() {
      // Validation logic
      print('setstate1 $amount');
      if (amount == null || amount <= 0) {
        _errorText = 'Enter a valid amount greater than zero';
        _total = 0.0;
      } else {
        _errorText = null;
        _total = amount /100;
        widget.onAmountChanged(_total); // Call the callback with new amount
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth * 0.9,
            minHeight: 110,
          ),
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFD9D9D9),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontFamily: 'Neue Haas Grotesk Display Pro',
                    fontSize: 24,
                    color: Color(0xFF141527),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: InputBorder.none,
                    hintText: '0',
                    errorText: _errorText, // Display error message
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontFamily: 'Neue Haas Grotesk Display Pro',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_total.toStringAsFixed(2)}USD',
                    style: const TextStyle(
                      fontFamily: 'Neue Haas Grotesk Display Pro',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
