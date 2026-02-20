import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'paymentapi.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';


class ConfirmPaymentButtonComponent extends StatefulWidget {
  final bool isFormValid;
  final String amount;
  final String productId;

  const ConfirmPaymentButtonComponent({Key? key, required this.isFormValid, required this.amount, required this.productId}) : super(key: key);

  @override
  State<ConfirmPaymentButtonComponent> createState() => _ConfirmPaymentButtonComponentState();
}

class _ConfirmPaymentButtonComponentState extends State<ConfirmPaymentButtonComponent> {
  late PaymentApiService _paymentService;
  bool _isLoading = false;
  String _paymentStatus = '';
  String? paymentIntent; // Nullable String

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentApiService(); // Initialize the payment service
  }


Future<bool> displayPaymentSheet() async {
  try {
    await Stripe.instance.presentPaymentSheet();
    print("Payment successful!");
    return true; // Return true if payment succeeds
  } on StripeException catch (e) {
    print('Stripe error: $e');
    return false; // Return false if user cancels or payment fails
  } catch (e) {
    print('Error displaying payment sheet: $e');
    return false;
  }
}




Future<void> _confirmPayment() async {
  if (!widget.isFormValid) {
    print('Form is not valid: ${widget.amount}');
    return;
  }
    print('*** widget amount received = ${widget.amount}');
  int stripeAmount = (double.parse(widget.amount) * 100).toInt();

  setState(() {
    _isLoading = true;
    _paymentStatus = '';
  });

  try {
    print('######### stripeamount $stripeAmount');

    var response = await _paymentService.createPaymentIntent(amount: stripeAmount, currency: 'USD');
    print('Payment Intent Response: $response');

    if (response['success']) {
      var clientSecret = response['data']['clientSecret'];
      var paymentIntentId = response['data']['paymentIntentId'];

      print('   paymentIntentIdpaymentIntentId $paymentIntentId ');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.light,
          merchantDisplayName: 'CRAZII',
        ),
      );

      // Show the payment sheet and check if payment was completed
      bool paymentSuccess = await displayPaymentSheet();

      if (paymentSuccess) {
        // Only proceed if payment was successful
        int statusCode = await _paymentService.completeOrder(
          paymentIntentId: paymentIntentId,
          amount: stripeAmount,
          productType: 'physical',
          productId: widget.productId,
        );

        print('Order completion status code: $statusCode');

        setState(() {
          _paymentStatus = 'payment_completed'.tr;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('payment_completed'.tr),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          _paymentStatus = 'Payment was not completed.';
        });
      }
    } else {
      setState(() {
        _paymentStatus = '${'payment_failed'.tr}: ${response['message']}';
      });

      // Show failure message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'payment_failed'.tr}: ${response['message']}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    print('error $e');
    setState(() {
      _paymentStatus = '${'error'.tr}: $e';
    });

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${'error'.tr}: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  } finally {
     final ApiService apiService = ApiService();
    apiService.getRemainingCredits();
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      constraints: const BoxConstraints(minWidth: 335, minHeight: 38),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB38F3F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ).copyWith(
          overlayColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return const Color(0xFFB38F3F).withOpacity(0.8);
            }
            if (states.contains(MaterialState.pressed)) {
              return const Color(0xFFB38F3F).withOpacity(0.7);
            }
            return null;
          }),
        ),
        onPressed: _isLoading ? null : _confirmPayment,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Confirm Payment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Exo',
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
