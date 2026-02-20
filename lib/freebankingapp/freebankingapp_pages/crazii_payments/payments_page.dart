import 'package:flutter/material.dart'; 
import 'credit_input_component.dart';
import 'card_details_component.dart';
import 'confirm_payment.dart'; 
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
	import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';

class TopUpCredits extends StatefulWidget {
  @override
  _TopUpCreditsState createState() => _TopUpCreditsState();
}

class _TopUpCreditsState extends State<TopUpCredits> {
  final ValueNotifier<String> _enteredAmountNotifier = ValueNotifier<String>("1.0");
  bool _isCardValid = false;

  void _onAmountChanged(double amount) { 
    _enteredAmountNotifier.value = amount.toString(); // Update only the notifier
  }

  void _onCardValidationChanged(bool isValid) { 
    setState(() {
      _isCardValid = isValid;
    });
  }

  @override
  void dispose() {
    _enteredAmountNotifier.dispose(); // Dispose of the notifier
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          CraziiHeader(productName: 'Top-up Credits'), // This will NOT rebuild
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CreditInputComponent(onAmountChanged: _onAmountChanged),
                  ValueListenableBuilder<String>(
                    valueListenable: _enteredAmountNotifier,
                    builder: (context, amount, child) {
                      return ConfirmPaymentButtonComponent(
                        isFormValid: amount.isNotEmpty,
                        amount: amount,
                        productId: '0',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CraziiFooter(selectedIndex: 2),
    );
  }
}

 
