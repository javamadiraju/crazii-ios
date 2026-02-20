import 'package:flutter/material.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_color.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:get/get.dart';
import 'package:email_validator/email_validator.dart';
import 'authapi.dart';
import 'crazii_signin.dart';

class CraziiForgotPassword extends StatefulWidget {
  const CraziiForgotPassword({Key? key}) : super(key: key);

  @override
  State<CraziiForgotPassword> createState() => _CraziiForgotPasswordState();
}

class _CraziiForgotPasswordState extends State<CraziiForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController(); // OTP
  final TextEditingController _newPasswordController = TextEditingController();
   final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  String? _errorMessage;
  bool _isLoading = false;
  bool _showOtp = false;
 bool _showPassword = false;
  bool _isOtpObscured = true;
  bool _isPasswordObscured = true;
    bool _completed = false;

Future<void> _submitForgotPassword() async {
  final String email = _emailController.text.trim(); 
  final String newPassword = _newPasswordController.text.trim();
  final String confirmPassword = _confirmPasswordController.text.trim();

  // Validation checks
  if (newPassword.length < 8) {
    setState(() {
      _errorMessage = "Password must be at least 8 characters long.";
    });
    return;
  }

  if (newPassword != confirmPassword) {
    setState(() {
      _errorMessage = "Passwords do not match.";
    });
    return;
  }

  if (newPassword.isEmpty || confirmPassword.isEmpty) {
    setState(() {
      _errorMessage = "All fields are required.";
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final response = await authService.resetPassword(
      email: email,
      newPassword: newPassword,
    );

    print('*** response for change password : $response');
    
    if (response['statusCode'] == 200 && response['success'] == true) {
      
     // Get.snackbar("Success", response['message']);
     // Navigator.of(context).pop();
    } else {
      setState(() => _errorMessage = response['message'] ?? "Failed to change password.");
    }
  } catch (error) {
    setState(() => _errorMessage = "An error occurred: $error");
  } finally {
    _completed=true;
    setState(() => _isLoading = false);
  }
}


Future<void> _validateOTP() async {
  final email = _emailController.text.trim();
  final otp = _otpController.text.trim();
  print('otp is $otp $email');

  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final response = await authService.verifyOtp(email, otp);
    print('response is $response');

    if (response['success'] == true) {
      setState(() {
        _showOtp = false;
        _showPassword = true;
      });
      //Get.snackbar("OTP Validated", response['message'] ?? "Success.");
    } else {
      setState(() {
        _errorMessage = response['message'] ?? "Failed to validate OTP.";
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = "Error validating OTP: $e";
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  
  Future<void> _validateEmailAndShowFields() async {
    final email = _emailController.text.trim();

    if (!EmailValidator.validate(email)) {
      setState(() {
        _errorMessage = "Invalid email address.";
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final response = await authService.requestOtp(email);

      if (response['statusCode'] == 200) {
        setState(() {
          _showOtp = true;
        });
       // Get.snackbar("OTP Sent", "An OTP has been sent to your email.");
      } else {
        setState(() {
          _errorMessage = response['message'] ?? "Failed to send OTP.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error sending OTP: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        Get.off(() => const CraziiAppSignIn());
      },
    ),
  ),
  extendBodyBehindAppBar: true, 
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
          padding: const EdgeInsets.symmetric(horizontal: 43),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 119),
              Center(
                child: Image.asset(
                  FreeBankingAppPngimage.crazii,
                  width: 98,
                  height: 21.66,
                ),
              ),
              const SizedBox(height: 13),
              const Center(
                child: Text(
                  'CHANGE PASSWORD',
                  style: TextStyle(
                    fontFamily: 'Exo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if(!_showOtp && !_showPassword&& !_completed) ...[
              const Text('Email', style: _labelStyle),
              const SizedBox(height: 8),
              _buildInputField(
                _emailController,
                'Enter your email',
                enabled: !_showOtp,
              ),

              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _validateEmailAndShowFields,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB38F3F),
                    minimumSize: const Size(304, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                child: const Text(
                  'GET OTP',
                     style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                ),
              ),
              ],
              const SizedBox(height: 20),
              
              if (_errorMessage != null)
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

              if (_showOtp && !_completed) ...[
                const SizedBox(height: 20),
                const Text('OTP', style: _labelStyle),
                const SizedBox(height: 8),
                _buildInputField(
                  _otpController,
                  'Enter OTP',
                  obscure: _isOtpObscured,
                  showToggle: true,
                  onToggleVisibility: () {
                    setState(() {
                      _isOtpObscured = !_isOtpObscured;
                    });
                  },
                ),

                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _isLoading ? null : _validateOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB38F3F),
                    minimumSize: const Size(304, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'VERIFY OTP',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),

                ],
                 if (_showPassword && !_completed) ...[
                const SizedBox(height: 15),
                const Text('New Password', style: _labelStyle),
                const SizedBox(height: 8),
                _buildInputField(
                  _newPasswordController,
                  'Enter new password',
                  obscure: _isPasswordObscured,
                  showToggle: true,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),
                const SizedBox(height: 15),
                const Text('Confirm Password', style: _labelStyle),
                const SizedBox(height: 8),
                _buildInputField(
                  _confirmPasswordController,
                  'Confirm password',
                  obscure: _isPasswordObscured,
                  showToggle: true,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForgotPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB38F3F),
                    minimumSize: const Size(304, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
                 
              const SizedBox(height: 20),],

              if (_completed) ...[
                      const SizedBox(height: 40),
                      const Center(
                        child: Text(
                          "Password successfully updated!",
                          style: TextStyle(
                            fontFamily: 'Exo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(); // or navigate to login screen
                          },
                          child: const Text(
                            "Click here to login",
                            style: TextStyle(
                              fontFamily: 'Exo',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.orangeAccent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller,
    String hintText, {
    bool obscure = false,
    VoidCallback? onToggleVisibility,
    bool showToggle = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFD9D9D9),
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: 'Neue Haas Grotesk Display Pro',
          fontSize: 16,
          color: const Color(0xFF141527).withOpacity(0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: showToggle
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.black54,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  fontFamily: 'Exo',
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: Colors.white,
);
