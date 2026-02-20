import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
 import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_color.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_fontstyle.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
 import 'package:get/get.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/UserSignupData.dart'; 
import 'package:flutter/gestures.dart'; 
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_home.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';


 
class UserGSignupDetails extends StatefulWidget {
  final String email;
  final String displayName; 

  const UserGSignupDetails({
    Key? key,
    required this.email,
    required this.displayName, 
  }) : super(key: key);

  @override
  _UserGSignupDetailsState createState() => _UserGSignupDetailsState();
}

class _UserGSignupDetailsState extends State<UserGSignupDetails> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController; 
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
 String? _errorMessage;
  final ApiService apiService = ApiService();



  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.displayName);
    _emailController = TextEditingController(text: widget.email);
  }


  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _locationController.dispose();
    _jobController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

Future<void> _validateAndSignUp() async {
  setState(() {
    _errorMessage = null;
  });

  if (_formKey.currentState!.validate()) {
    UserSignupData userData = UserSignupData(
      email: widget.email.trim(),
      password: _fullNameController.text.trim(),
      birthDate: _fullNameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      location: _locationController.text.trim(),
      job: _jobController.text.trim(),
    );

    try {
      Map<String, dynamic> response  = await apiService.registerUserDetails(userData);
        
      if (response['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CraziiHome()),
        );
      } else {
        setState(() {
          _errorMessage = "User not registered- ${response['message']}";
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "An error occurred: $error";
      });
    }
  } else {
    setState(() {
      _errorMessage = "Please fix the errors above before signing up.";
    });
  }
}




  
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return "Full Name is required.";
    } else if (value.length < 3) {
      return "Full Name must be at least 3 characters.";
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return "Phone Number is required.";
    } else if (!RegExp(r'^\d+$').hasMatch(value)) {
      return "Phone Number must contain only digits.";
    } else if (value.length != 10) {
      return "Phone Number must be exactly 10 digits.";
    }
    return null;
  }

    String? _validateEmail(String? value) {
     
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return "Location is required.";
    }
    return null;
  }

  String? _validateJob(String? value) {
    if (value == null || value.isEmpty) {
      return "Job is required.";
    }
    return null;
  }

  String? _validateBirthDate(String? value) {
    if (value == null || value.isEmpty) {
      return "Birth Date is required.";
    } else if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return "Birth Date must be in the format YYYY-MM-DD.";
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 390,
        height: 844,
        decoration:   BoxDecoration(
           image: DecorationImage(
            image: AssetImage(FreeBankingAppPngimage.background),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
          key: _formKey,
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
                // Email (Read-Only)
                  _buildInputField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController, 
                    validator: _validateEmail,
                    readOnly: true
                  ),
                  const SizedBox(height: 10),

                  // Full Name (Read-Only)
                  _buildInputField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _fullNameController, 
                    validator: _validateFullName,
                    readOnly:true
                  ),
                  
                
                  const SizedBox(height: 10),
                  _buildInputField(
                    label: 'Phone Number',
                    hint: 'Enter your Phone Number',
                    controller: _phoneNumberController,
                    validator: _validatePhoneNumber,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    label: 'Location',
                    hint: 'Enter your Location',
                    controller: _locationController,
                    validator: _validateLocation,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    label: 'Job',
                    hint: 'Enter your job',
                    controller: _jobController,
                    validator: _validateJob,
                  ), 
                  const SizedBox(height: 24),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                   
                const SizedBox(height: 24),
                _buildSignUpButton( ), 
                const SizedBox(height: 10),  
                _buildTermsText(),
                const SizedBox(height: 20), 
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }


 
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 35,
          decoration: BoxDecoration(
            color: readOnly ? Colors.grey[300] : const Color(0xFFD9D9D9), // Different shade for read-only
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            readOnly: readOnly,
            style: TextStyle(
              color: readOnly ? Colors.black54 : Colors.black, // Slightly faded color for read-only
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF141527),
                fontSize: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

 Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: _validateAndSignUp,
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
 
 

  Widget _buildTermsText() {
    return const Text(
      'By continuing, you agree to Crazii\'s Terms of Service\nand acknowledge you\'ve read our Privacy Policy',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Exo',
        fontWeight: FontWeight.w700,
      ),
    );
  }
 

}

