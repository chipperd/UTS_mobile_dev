import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  bool _isDarkMode = false;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadDarkModePreference();
    _loadProfileImage();
  }

  void _loadDarkModePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
      prefs.setBool('isDarkMode', _isDarkMode);
    });
  }

  void _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profileImagePath');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleDarkMode,
          ),
        ],
      ),
      body: FutureBuilder<UserProfile>(
        future: _getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Tidak ada data pengguna.'));
          } else {
            UserProfile userProfile = snapshot.data!;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _profileImagePath != null
                        ? CircleAvatar(
                            radius: 50,
                            backgroundImage: FileImage(File(_profileImagePath!)),
                          )
                        : const Icon(Icons.person, size: 100, color: Colors.blueAccent),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Nama: ${userProfile.fullName}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Email: ${userProfile.email}',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Alamat : bulurejo purwoharjo kab. banyuwangi',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 10),
                            ])),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        bool? confirm =
                            await _showDeleteConfirmationDialog(context);
                        if (confirm == true) {
                          await _deleteAccount();
                          exit(0);
                        }
                      },
                      child: const Text('Hapus Akun',
                          style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await _destroyResources();
                        SystemNavigator.pop(); 
                      },
                      child: const Text('Keluar',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<UserProfile> _getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? 'Tidak ada email';
    String fullName = prefs.getString('fullName') ?? 'Tidak ada nama';
    String address = prefs.getString('address') ?? 'Tidak ada alamat';
    String? profileImagePath = prefs.getString('profileImagePath');
    
    return UserProfile(
      fullName: fullName,
      email: email,
      address: address,
      profileImagePath: profileImagePath,
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Akun'),
          content: const Text('Apakah Anda yakin ingin menghapus akun ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false);
              },
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) { // Memastikan widget masih terpasang sebelum menggunakan context
      _showDeleteConfirmationDialog(context); 
    }
  }

  Future<void> _destroyResources() async {
  }
}

class UserProfile {
  final String fullName;
  final String email;
  final String address;
  final String? profileImagePath;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.address,
    this.profileImagePath,
  });
}
