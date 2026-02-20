import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
 import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_color.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_fontstyle.dart';

 import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';

import 'package:get/get.dart'; 
import 'package:flutter/gestures.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_authentication/crazii_signup_details.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_authentication/crazii_signin.dart';

 import 'dart:convert';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:google_sign_in/google_sign_in.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_home.dart';
import 'package:email_validator/email_validator.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/UserSignupData.dart'; 
import 'package:adoptive_calendar/adoptive_calendar.dart';
import 'authapi.dart';

class CraziiSignup extends StatefulWidget {
  const CraziiSignup({Key? key}) : super(key: key);

  @override
  _CraziiSignupState createState() => _CraziiSignupState();
}
class _CraziiSignupState extends State<CraziiSignup> {
  // Controllers for capturing input data
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();


    final AuthService authService=AuthService();

    String? _errorMessage;
ApiService apiService = ApiService();
  DateTime? pickedDate;

 


 


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 390,
        height: 844,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(FreeBankingAppPngimage.background),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 120),
                Image.asset(
                  FreeBankingAppPngimage.crazii,
                  width: 98,
                  height: 22,
                ),
                const SizedBox(height: 14),
                const Text(
                  'CREATE AN ACCOUNT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Exo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 30),
               _buildInputField('Email', 'Enter your email', controller: emailController),
                const SizedBox(height: 14),
                _buildInputField('Password', 'Enter your password', isPassword: true, controller: passwordController),
                const SizedBox(height: 14),
                _buildInputField('Birth Date', 'Select your birth date',
                    controller: birthDateController, isDateField: true),
                if (_errorMessage != null) // Display error message if present
                  Text(
                    _errorMessage!,
                     textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'EXO',
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 24),
                _buildSignUpButton(), 
               
                
                const SizedBox(height: 15),
                _buildTermsText(),
                const SizedBox(height: 20),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
  DateTime? selectedDate = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AdoptiveCalendar(
        initialDate: pickedDate ?? DateTime.now(),
        datePickerOnly: true,
         action: true,
        minYear: 1900,
        maxYear: 2024,
      );
    },
  );

  if (selectedDate != null && selectedDate.isBefore(DateTime.now())) {
    // Ensuring the user selects a past date
    setState(() {
      pickedDate = selectedDate;
      birthDateController.text =
          "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
    });
  } else {
    // Show error if user picks a future date
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Please select a valid past date")),
    );
  }
}




  Widget _buildInputField(String label, String hint,
    {bool isPassword = false, TextEditingController? controller, bool isDateField = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Exo',
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: isDateField ? () => _selectBirthDate(context) : null,
        child: Container(
          height: 42, // Slightly increased for better touch target
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: AbsorbPointer(
              absorbing: isDateField, // prevent typing in date field
              child: TextField(
                controller: controller,
                obscureText: isPassword,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Exo',
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: const Color(0xFF141527).withOpacity(0.5),
                    fontSize: 16,
                    fontFamily: 'Exo',
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

  
 
 

  Widget _buildSignUpButton()  {

      setState(() {
            _errorMessage = "";
          });

    return GestureDetector(
      onTap: () async{  
        final email = emailController.text.trim();
        final password = passwordController.text.trim();
        final birthDate = birthDateController.text.trim();  


        // Input validation
        if (email.isEmpty || password.isEmpty || birthDate.isEmpty) {
         setState(() {
            _errorMessage = 'All fields are required.';
          });
          return; 
        }
        if (password.length < 8) {
          setState(() {
            _errorMessage = "Password shall be atleast 8  characters.";
          });
          return;
        }
        if (!EmailValidator.validate(email)) {
          setState(() {
            _errorMessage = "Invalid Email.";
          });
          return;
        }


      final birthDateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (!birthDateRegex.hasMatch(birthDate)) {
        setState(() {
          _errorMessage = 'Birthdate must be in the format yyyy-mm-dd.';
        });
        return;
      }

 
       UserSignupData userData = UserSignupData(
          email: email,
          password: password,
          birthDate: birthDate,
          fullName: 'TBD',
          phoneNumber: '9999999999',
          location:'TBD',
          job: 'TBD',
          address: 'TBD',
          accountType: 'FREE',
          );  

         Map<String, dynamic> response  = await apiService.registerUser(userData);

         print('* registering user response $response');
         
        if (response['success'] != true) {
          
           if (response['message'] is String) {
                try {
                  final Map<String, dynamic> errorMap = jsonDecode(response['message']);
                   setState(() {
                        _errorMessage = errorMap.values.first; 
                      });
                  
                } catch (e) {
                  _errorMessage = response['message']; // Fallback in case of decoding error
                }
              } else if (response['message'] is Map) {
                _errorMessage = response['message'].values.first;
              } else {
                _errorMessage = "An unexpected error occurred."; // Fallback for other types
              }
           print('*** response after registering email : $_errorMessage');
          return;
        } 

      Get.to(() => UserSignupDetails(
        email: email,
        password: password,
        birthDate: birthDate,));
      },
      child: Container(
        width: 304,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFB38F3F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Sign Up',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Exo',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    emailController.dispose();
    passwordController.dispose();
    birthDateController.dispose();
    super.dispose();
  }
 


 

  Widget _buildTermsText() {
    return const Text(
      'By continuing, you agree to Crazii\'s Terms of Service\nand acknowledge you\'ve read our Privacy Policy',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontFamily: 'Exo',
        fontWeight: FontWeight.w700,
      ),
    );
  }

Widget _buildLoginLink() {
  return RichText(
    text: TextSpan(
      text: 'Already a member? ',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Exo',
        fontWeight: FontWeight.w700,
      ),
      children: [
        TextSpan(
          text: 'Log in',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Exo',
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              
                Get.to(() => CraziiAppSignIn());
            },
        ),
      ],
    ),
  );
}

}

