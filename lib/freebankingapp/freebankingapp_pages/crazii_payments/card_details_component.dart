import 'package:flutter/material.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:flutter/services.dart';  
import 'package:flutter_stripe/flutter_stripe.dart';

class CardDetailsComponent extends StatefulWidget {
  final Function(bool)? onValidationChanged;
  
  final String cardNumber;
  final String cvv;
  final String expiry;

  const CardDetailsComponent({
    Key? key,
    this.onValidationChanged,
    this.cardNumber = '',    // Default to empty if not provided
    this.cvv = '',
    this.expiry = '',
  }) : super(key: key);

  @override
  _CardDetailsComponentState createState() => _CardDetailsComponentState();
}

class _CardDetailsComponentState extends State<CardDetailsComponent> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  

  String _cardImage = FreeBankingAppPngimage.visa;
  String? _errorText;  // For card number error
  String? _expiryErrorText;  // For expiry date error
  String? _cvvErrorText;  // For CVV error

  bool _isCardNumberValid = false;
  bool _isExpiryDateValid = false; 
  bool _isCvvValid = false;
  CardDetails _card = CardDetails();


  @override
  void initState() {
    super.initState();
    _cardNumberController.text = widget.cardNumber;
    _expiryDateController.text = widget.expiry;
    _cvvController.text = widget.cvv;

    _cardNumberController.addListener(() {
      _updateCardImage();
      _validateCardDetails();
    });

    _expiryDateController.addListener(() {
      _validateCardDetails();
    });

    _cvvController.addListener(() {
      _validateCardDetails();
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _updateCardImage() {
    String cardNumber = _cardNumberController.text;
    if (cardNumber.startsWith('4')) {
      setState(() {
        _cardImage = FreeBankingAppPngimage.visa;
      });
    } else if (cardNumber.startsWith('5')) {
      setState(() {
        _cardImage = FreeBankingAppPngimage.mastercard;
      });
    } else if (cardNumber.startsWith('3')) {
      setState(() {
        _cardImage = FreeBankingAppPngimage.mastercard;
      });
    } else {
      setState(() {
        _cardImage = FreeBankingAppPngimage.visa;
      });
    }
  }

  void _validateCardDetails() {
    String cardNumber = _cardNumberController.text;
    String expiryDate = _expiryDateController.text;
    String cvv = _cvvController.text;
    print('validating card details $cardNumber $expiryDate $cvv');

    // Validate Card Number
    if (cardNumber.length == 16 && RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
      setState(() {
        _errorText = null;
        _isCardNumberValid = true;
      });
    } else {
      setState(() {
        _errorText = 'Card number must be 16 digits';
        _isCardNumberValid = false;
      });
    }

     print('validating card details $cardNumber $_isCardNumberValid cardnumber $expiryDate $cvv'); 

    // Validate Expiry Date (MM/YY format)
    _isExpiryDateValid = RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(expiryDate);
    if (!_isExpiryDateValid) {
      setState(() {
         _isExpiryDateValid=false;
        _expiryErrorText = 'Enter valid Expiry Date';
      });
    } else {
      setState(() {
        _isExpiryDateValid=true;
        _expiryErrorText = null;
      });
    }


     print('validating card details $cardNumber $_isExpiryDateValid exp $expiryDate $cvv');

    // Validate CVV
    _isCvvValid = cvv.length == 3 && RegExp(r'^\d{3}$').hasMatch(cvv);
    if (!_isCvvValid) {
      setState(() {
        _cvvErrorText = 'Enter valid CVV';
         _isCvvValid=false;
      });
    } else {
      setState(() {
        _isCvvValid=true;
        _cvvErrorText = null;
      });
    } 
    print('validating card details $cardNumber $_isCvvValid cvv $expiryDate $cvv');
    _notifyValidation();
  }

  void _notifyValidation() {
    print('** notifyvalidation..');
    if (widget.onValidationChanged != null) {
      print('notifying $_isCardNumberValid $_isExpiryDateValid  $_isCvvValid');
      widget.onValidationChanged!(
          _isCardNumberValid && _isExpiryDateValid && _isCvvValid);
    }else{
      print('nullllllllllllllll*******');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minWidth: 335,
        minHeight: 200,
      ),
      margin: EdgeInsets.symmetric(vertical: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Number',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Exo',
            ),
          ),
          SizedBox(height: 8),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _errorText == null ? 46 : 66,
            child: TextField(
              controller: _cardNumberController,
              style: TextStyle(
                color: Color(0xFF141527),
                fontSize: 20,
                fontFamily: 'Neue Haas Grotesk Display Pro',
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFD9D9D9),
                hintText: ' ',
                hintStyle: TextStyle(
                  color: Color(0xFF141527),
                  fontSize: 20,
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image.asset(
                    _cardImage,
                    width: 67,
                    height: 27,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _isCardNumberValid ? Colors.grey : Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _isCardNumberValid ? Color(0xFFB38F3F) : Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                errorText: _errorText,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
            ),
          ),
          SizedBox(height: 16),
           Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expiration Date',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Exo',
            ),
          ),
          SizedBox(height: 8),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _expiryErrorText == null ? 46 : 66, // Ensuring consistent height
            child: TextField(
              controller: _expiryDateController,
              style: TextStyle(
                color: Color(0xFF141527),
                fontSize: 20,
                fontFamily: 'Neue Haas Grotesk Display Pro',
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFD9D9D9),
                hintText: 'MM/YY',
                hintStyle: TextStyle(
                  color: Color(0xFF141527),
                  fontSize: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _isExpiryDateValid ? Colors.grey : Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _isExpiryDateValid ? Color(0xFFB38F3F) : Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                errorText: _expiryErrorText,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  var text = newValue.text;
                  if (text.length == 2 && !text.contains('/')) {
                    text += '/';
                  } else if (text.length > 2 && !text.contains('/')) {
                    text = text.substring(0, 2) + '/' + text.substring(2);
                  } else if (text.length == 3 && text[2] != '/') {
                    text = text.substring(0, 2) + '/' + text[2];
                  }
                  if (text.length > 5) {
                    text = text.substring(0, 5);
                  }
                  return TextEditingValue(
                    text: text,
                    selection: TextSelection.fromPosition(
                      TextPosition(offset: text.length),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security Code',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: 'Exo',
            ),
          ),
          SizedBox(height: 8),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _cvvErrorText == null ? 46 : 66, // Ensuring consistent height
            child: TextField(
              controller: _cvvController,
              style: TextStyle(
                color: Color(0xFF141527),
                fontSize: 20,
                fontFamily: 'Neue Haas Grotesk Display Pro',
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFD9D9D9),
                hintText: 'CVV',
                hintStyle: TextStyle(
                  color: Color(0xFF141527),
                  fontSize: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _isCvvValid ? Colors.grey : Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _isCvvValid ? Color(0xFFB38F3F) : Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                errorText: _cvvErrorText,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
            ),
          ),
        ],
      ),
    ),
  ],
),

        ],
      ),
    );
  }
}
