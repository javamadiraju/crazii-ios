import 'package:flutter/material.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_model/User.dart';
import 'package:get/get.dart';

class AccountDetailsComponent extends StatefulWidget {
  final Function(String) onUsernameChanged;

  const AccountDetailsComponent({Key? key, required this.onUsernameChanged})
      : super(key: key);

  @override
  _AccountDetailsComponentState createState() => _AccountDetailsComponentState();
}

class _AccountDetailsComponentState extends State<AccountDetailsComponent> {
  final ApiService apiService = ApiService();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nameController;

  late Future<User> _userFuture = apiService.getUserData();

  @override
  void initState() {
    super.initState();
    _userFuture = apiService.getUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('${'error'.tr}: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          _emailController = TextEditingController(text: user.data.email);
          _passwordController = TextEditingController(text: '••••••');
          _nameController = TextEditingController(text: "${user.data.firstName} ${user.data.lastName}");

          return LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.white,   // ⭐ Background changed to white
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("email".tr),
                    const SizedBox(height: 8),
                    _buildInputField(controller: _emailController, constraints: constraints, obscureText: false),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel("password".tr),
                        TextButton(
                          onPressed: () async {
                            final newPassword = _passwordController.text;
                            try {
                              final response = await apiService.updatePassword(newPassword);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response['message'])),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          child: _buildButtonText("change_password".tr),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(controller: _passwordController, constraints: constraints, obscureText: true),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel("name".tr),
                        TextButton(
                          onPressed: () async {
                            final newName = _nameController.text.split(' ');
                            final firstName = newName.isNotEmpty ? newName[0] : '';
                            final lastName = newName.length > 1 ? newName[1] : '';

                            try {
                              final response = await apiService.saveProfile(firstName, lastName);

                              if (response) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Name updated successfully')),
                                );
                                setState(() {
                                  _nameController.text = "$firstName $lastName";
                                  user.data.firstName = firstName;
                                  user.data.lastName = lastName;
                                });

                                widget.onUsernameChanged("$firstName $lastName");
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to update name')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          child: _buildButtonText("change_name".tr),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInputField(controller: _nameController, constraints: constraints, obscureText: false),
                  ],
                ),
              );
            },
          );
        } else {
          return Center(child: Text('no_data'.tr));
        }
      },
    );
  }

  // Label text – converted to BLACK
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black, // ⭐ changed
        fontSize: 16,
        fontFamily: 'Exo',
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // Input field – unchanged except background -> white & text -> black
   // Input field – updated for better visibility
Widget _buildInputField({
  required TextEditingController controller,
  required BoxConstraints constraints,
  required bool obscureText,
}) {
  return Container(
    width: constraints.maxWidth,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.black.withOpacity(0.4), width: 1.2), // ⭐ added border
    ),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontFamily: 'Neue Haas Grotesk Display Pro',
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}


  // Button text – changed to black
  Widget _buildButtonText(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black, // ⭐ changed
        fontSize: 16,
        fontFamily: 'Exo',
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.underline,
      ),
    );
  }
}
