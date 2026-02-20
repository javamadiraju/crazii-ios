import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'paymentapi.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_authentication/signupsuccess.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_home.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/User.dart';

class PayProductPurchase extends StatefulWidget {
  final String amount;
  final String product;
  final String fullname;
  final String productId;
  const PayProductPurchase({Key? key,required this.fullname,required this.product, required this.amount,required this.productId}) : super(key: key);

  @override
  State<PayProductPurchase> createState() => _PayProductPurchaseState();
}

class _PayProductPurchaseState extends State<PayProductPurchase> {
  bool _isLoading = false;
  late Future<User> userData;
late PaymentApiService _paymentService;
 final ApiService apiService = ApiService();
  @override
  void initState() {
    super.initState();
      _paymentService = PaymentApiService(); 
      userData = apiService.getUserData();
    _confirmPayment(); // Automatically start payment when page loads 
   
  }

void showCustomToast(String message) {
  FToast fToast = FToast();
  fToast.init(context);  // Use `context` instead of `navigatorKey.currentContext`

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: Colors.green,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 30),
        const SizedBox(height: 8),
        Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.CENTER, 
    toastDuration: const Duration(seconds: 3),
  );
}
 


Future<void> _completePayment(String paymentIntentId, int stripeAmount, String currency,String productId) async {
  try {
    final user = await userData;

    int statusCode = await _paymentService.completeOrder(
      paymentIntentId: paymentIntentId,
      amount: stripeAmount,
      productType: widget.product,
      productId: widget.productId,
    );

    if (statusCode == 200) {
      print('✅ Order completed successfully.');
    } else {
      print('❌ Failed to complete the order. Status code: $statusCode');
    }
  } catch (e) {
    print('Error in _completePayment: $e');
  }
}






 Future<void> _confirmPayment() async {
  setState(() => _isLoading = true);

  try {
    int stripeAmount = (double.parse(widget.amount) * 100).toInt();

    var response = await _createPaymentIntent(stripeAmount, 'USD');
    if (response['success']) {
      String clientSecret = response['data']['clientSecret'];
      String paymentIntentId = response['data']['paymentIntentId'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Crazii',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      int stripeAmount1 = (double.parse(widget.amount) ).toInt();
      // ✅ Complete the payment using the captured paymentIntentId
      await _completePayment(paymentIntentId, stripeAmount1, 'USD',widget.productId);

      // ✅ Show confirmation toast
      String message = "Thank You! for purchasing the \n"
          "Name: ${widget.fullname} \n"
          "Purchased Product: ${widget.product} \n"
          "Amount Paid: \$${widget.amount}";

      showCustomToast(message);

      await Future.delayed(const Duration(seconds: 3));
      Navigator.pop(context, true); // success
    } else {
      throw Exception('Payment creation failed');
    }
  } catch (e) {
    print('Error in _confirmPayment: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('payment_failed'.tr, style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pop(context, false); // failure
  } finally {
    setState(() => _isLoading = false);
  }
}


Future<Map<String, dynamic>> _createPaymentIntent(int amount, String currency) async {
  var response = await _paymentService.createPaymentIntent(amount: amount, currency: currency);
  if (response['success']) {
    return {
      'success': true,
      'data': {
        'clientSecret': response['data']['clientSecret'],
        'paymentIntentId': response['data']['paymentIntentId'],
      }
    };
  } else {
    return {'success': false};
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading ? const CircularProgressIndicator() : Text('processing_payment'.tr),
      ),
    );
  }
}
