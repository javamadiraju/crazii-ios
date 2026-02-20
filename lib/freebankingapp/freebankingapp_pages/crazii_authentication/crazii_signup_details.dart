import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
 import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_color.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_fontstyle.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:get/get.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/UserSignupData.dart'; 
import 'package:freebankingapp/freebankingapp/freebankingapp_model/Product.dart';
import 'package:flutter/gestures.dart'; 
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_home.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_payments/paysignup.dart';
import 'signupsuccess.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:collection/collection.dart';

class UserSignupDetails extends StatefulWidget {
  final String email;
  final String password;
  final String birthDate;

  const UserSignupDetails({
    Key? key,
    required this.email,
    required this.password,
    required this.birthDate,
  }) : super(key: key);

  @override
  _UserSignupDetailsState createState() => _UserSignupDetailsState();
}

class _UserSignupDetailsState extends State<UserSignupDetails> {
  List<Product> _productList = [];
String? selectedProductId;


  final _formKey = GlobalKey<FormState>();
 final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _jobController = TextEditingController(); 
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
 String? _errorMessage;
  final ApiService apiService = ApiService();
  bool _isLoading=false;
String? _selectedOption;
  List<String> _options = [];
@override
void initState() {
  print('init ******');
  super.initState();
  _loadProducts();
}


Future<void> _loadProducts() async {
  try {
    print('Loading products..');

    List<Product> products = await apiService.fetchProducts();
    print('Loading products.. $products');
    if (mounted) {
      setState(() {
        _productList = products;
        _options = ["Free"];
        _options.addAll(products.map((product) =>
            "${product.name} - \$${product.price}"));
        _isLoading = false;
      });
    }
  } catch (e) {
    print("Error fetching products: $e");
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}



Future<void> _validateAndSignUp() async {
  setState(() {
    _errorMessage = null;
  });

  if (_formKey.currentState!.validate()) {
    UserSignupData userData = UserSignupData(
      email: widget.email.trim(),
      password: widget.password,
      birthDate: widget.birthDate,
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      location: _locationController.text.trim(),
      job: _jobController.text.trim(),
      address: _addressController.text.trim(),
      accountType: 'Free',
    );

    try {
      print('_selectedOption $_selectedOption');

      String? selectedPrice;
      String? selectedProductName;
     
     if (_selectedOption != null) {
        List<String> parts = _selectedOption!.split(" - ");
        if (parts.isNotEmpty) {
          selectedProductName = parts[0];
          selectedPrice = parts.last.replaceAll("\$", "");
          // Find product by name
          final selectedProduct = _productList.firstWhereOrNull((product) => product.name == selectedProductName);
          selectedProductId = selectedProduct?.id.toString(); // Assuming id is int or dynamic
        }
      }


      Map<String, dynamic> response  = await apiService.registerUserDetails(userData);
      print('** response recieved in update daetails $response');
      if (response['success'] == true) {
         if (_selectedOption?.toLowerCase() == 'free'.toLowerCase()) { 
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupSuccess()),
            );
          }else{
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaySignupPackage(
                  fullname: _fullNameController.text.trim(),
                  product: selectedProductName ?? '',
                  amount: selectedPrice ?? '10',
                  productId: selectedProductId ?? '',
                ),
              ),
            );

          }
        
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



    String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return "Address is required.";
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
                const SizedBox(height: 30),
                 _buildInputField(
                    label: 'Full Name',
                   // hint: 'Enter your full name',
                    hint: '',
                    controller: _fullNameController,
                    validator: _validateFullName,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    label: 'Phone Number',
                   // hint: 'Enter your Phone Number',
                   hint: '',
                    controller: _phoneNumberController,
                    validator: _validatePhoneNumber,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    label: 'Location',
                   // hint: 'Enter your Location',
                   hint: '',
                    controller: _locationController,
                    validator: _validateLocation,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    label: 'Job',
                   // hint: 'Enter your job',
                   hint: '',
                    controller: _jobController,
                    validator: _validateJob,
                  ), 
                   const SizedBox(height: 10),
                  _buildInputField(
                    label: 'Address',
                    //hint: 'Enter your address',
                    hint: '',
                    controller: _addressController,
                    validator: _validateAddress,
                  ), 
                   const SizedBox(height: 10),
                  _buildDropdownField(
                    label: 'Account type',
                    //hint: 'Choose Product',
                    hint: '',
                    options: _options,
                    selectedValue: _selectedOption,
                    onChanged: (value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
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
  required String? Function(String?) validator,
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
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            if (_errorMessage != null) {
              setState(() {
                _errorMessage = null;
              });
            }
          },
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




  Widget _buildDropdownField({
  required String label,
  required String hint,
  required List<String> options,
  required String? selectedValue,
  required void Function(String?) onChanged,
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonFormField<String>(
          value: selectedValue,
          hint: Text(
            hint,
            style: const TextStyle(
              color: Color(0xFF141527),
              fontSize: 16,
            ),
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: onChanged,
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
        fontSize: 12,
        fontFamily: 'Exo',
        fontWeight: FontWeight.w700,
      ),
    );
  }
 

}

