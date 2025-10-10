import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Profile/Settings page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Profile'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.dreamGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: AppColors.deepLavender),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildSection('Account', [
                _buildTile(Icons.person, 'Edit Profile', () {}),
                _buildTile(Icons.email, 'Email Settings', () {}),
              ]),
              _buildSection('Appearance', [
                _buildTile(Icons.palette, 'Theme', () {}),
                _buildTile(Icons.language, 'Language', () {}),
              ]),
              _buildSection('Data', [
                _buildTile(Icons.cloud_upload, 'Backup', () {}),
                _buildTile(Icons.download, 'Export Data', () {}),
              ]),
              _buildSection('Support', [
                _buildTile(Icons.help, 'Help Center', () {}),
                _buildTile(Icons.info, 'About', () {}),
              ]),
              const SizedBox(height: 80),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.deepLavender,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.deepLavender),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
