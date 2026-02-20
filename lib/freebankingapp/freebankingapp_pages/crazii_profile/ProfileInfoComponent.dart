import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:freebankingapp/freebankingapp/freebankingapp_model/User.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_globalclass/freebankingapp_icons.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_profile/profileapi.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_apiservices/api_services.dart';
import 'package:get/get.dart';
import 'package:freebankingapp/freebankingapp/utils/language_utils.dart';

class ProfileInfoComponent extends StatefulWidget {
  final String username;

  const ProfileInfoComponent({Key? key, required this.username})
      : super(key: key);

  @override
  _ProfileInfoComponentState createState() => _ProfileInfoComponentState();
}

class _ProfileInfoComponentState extends State<ProfileInfoComponent> {
  late Future<User> _userFuture;

  File? _selectedImage;
  String? _localImagePath;

  final ImagePicker _picker = ImagePicker();
  final ApiService apiService = ApiService();
  final ProfileApiService papiService = ProfileApiService();

  final String BASE_URL = "https://cgmember.com";
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUserAndImage();
  }

  // ====================================================
  // INIT USER + SAFE IMAGE CLEANUP
  // ====================================================
  Future<void> _initializeUserAndImage() async {
    _userFuture = apiService.getUserData();
    final user = await _userFuture;
    _userId = user.data.idUser;

    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_picture_path_$_userId');

    // 🔒 SAFELY REMOVE CORRUPTED FILE (IF EXISTS)
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      prefs.remove('profile_picture_path_$_userId');
    }

    if (mounted) {
      setState(() {
        _localImagePath = null;
        _selectedImage = null;
      });
    }
  }

  // ====================================================
  // CLEAN OLD PROFILE IMAGES
  // ====================================================
  Future<void> _cleanupOldImages(String dirPath,
      {required String keepPath}) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) return;

    for (var file in dir.listSync()) {
      if (file is File &&
          file.path.contains('profile_picture_$_userId') &&
          file.path != keepPath) {
        await file.delete();
      }
    }
  }

  // ====================================================
  // SAVE IMAGE LOCALLY
  // ====================================================
  Future<File> _saveImageLocally(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final path =
        '${directory.path}/profile_picture_${_userId}_$timestamp.jpg';

    final File newImage = await imageFile.copy(path);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_picture_path_$_userId', newImage.path);

    _cleanupOldImages(directory.path, keepPath: newImage.path);

    return newImage;
  }

  // ====================================================
  // PICK IMAGE
  // ====================================================
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final File imageFile = File(pickedFile.path);

    setState(() {
      _selectedImage = imageFile;
    });

    final savedFile = await _saveImageLocally(imageFile);

    setState(() {
      _localImagePath = savedFile.path;
    });

    await _uploadImage(savedFile);
  }

  // ====================================================
  // UPLOAD IMAGE
  // ====================================================
 Future<void> _uploadImage(File imageFile) async {
  try {
    debugPrint("📤 PROFILE UPLOAD STARTED");
    debugPrint("📁 Local file path: ${imageFile.path}");
    debugPrint("📏 File size: ${await imageFile.length()} bytes");

    final bool success =
        await papiService.uploadProfilePicture(imageFile);

    debugPrint("📡 Upload API response: success = $success");

    if (success) {
      debugPrint("✅ PROFILE IMAGE UPLOAD SUCCESS");

      setState(() {
        debugPrint("🔄 Refreshing user data after upload");
        _userFuture = apiService.getUserData();
      });
    } else {
      debugPrint("❌ PROFILE IMAGE UPLOAD FAILED (API returned false)");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to upload image")),
      );
    }
  } catch (e, stack) {
    debugPrint("🔥 PROFILE IMAGE UPLOAD EXCEPTION");
    debugPrint("🔥 Error: $e");
    debugPrint("🔥 StackTrace: $stack");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error uploading profile image")),
    );
  }
}

  // ====================================================
  // IMAGE PICKER OPTIONS
  // ====================================================
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Selfie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  // ====================================================
  // BUILD
  // ====================================================
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('failed_load_user'.tr));
        }

        if (snapshot.hasData) {
          return _buildProfileInfo(snapshot.data!.data.picture);
        }

        return Center(child: Text('no_user_data'.tr));
      },
    );
  }

  // ====================================================
  // PROFILE UI (SAFE)
  // ====================================================
  Widget _buildProfileInfo(String profileImageUrl) {
    final fullUrl = profileImageUrl.startsWith("http")
        ? profileImageUrl
        : "$BASE_URL$profileImageUrl";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          /// PROFILE IMAGE
          ClipOval(
            child: (_localImagePath != null &&
                    File(_localImagePath!).existsSync())
                ? Image.file(
                    File(_localImagePath!),
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _fallbackNetwork(fullUrl),
                  )
                : _fallbackNetwork(fullUrl),
          ),

          const SizedBox(width: 16),

          /// NAME + EDIT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'hi_user'.trParams({'name': widget.username}),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Exo',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: _showImagePickerOptions,
                  child: Text(
                    "edit_picture".tr,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 14,
                      fontFamily: 'Exo',
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // FALLBACK IMAGE
  // ====================================================
  Widget _fallbackNetwork(String url) {
    return Image.network(
      url,
      width: 52,
      height: 52,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) =>
          progress == null
              ? child
              : const SizedBox(
                  width: 52,
                  height: 52,
                  child: Center(
                      child:
                          CircularProgressIndicator(strokeWidth: 2)),
                ),
      errorBuilder: (_, __, ___) {
        return Image.asset(
          FreeBankingAppPngimage.dprofile,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
