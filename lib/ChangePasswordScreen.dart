import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmNewPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                ),
                obscureText: true, // Şifre gizle
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                ),
                obscureText: true, // Şifre gizle
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextFormField(
                controller: confirmNewPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                ),
                obscureText: true, // Şifre gizle
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Yeni şifrenin doğruluğunu kontrol et
                if (newPasswordController.text != confirmNewPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Passwords do not match')));
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not found')));
                    return;
                  }

                  // Mevcut şifreyi doğrula
                  AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: currentPasswordController.text);
                  await user.reauthenticateWithCredential(credential);

                  // Yeni şifreyi güncelle
                  await user.updatePassword(newPasswordController.text);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password changed successfully')));
                  Navigator.pop(context); // Ekranı kapat
                } catch (e) {
                  print('Error changing password: $e');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to change password')));
                }
              },
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
