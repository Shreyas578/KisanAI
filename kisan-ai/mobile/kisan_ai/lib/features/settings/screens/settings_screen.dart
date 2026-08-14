import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/kisan_widgets.dart';
import '../../../../shared/widgets/language_voice_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8BA898),
        ),
      ),
    );
  }
}

class SettingsItem extends StatelessWidget {
  final String title;
  final String? value;
  final IconData icon;
  final bool isDestructive;
  final VoidCallback? onTap;

  const SettingsItem({
    required this.title,
    this.value,
    required this.icon,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF00E676)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isDestructive ? Color(0xFFFF5252) : Color(0xFFF0FFF4),
        ),
      ),
      trailing: value != null
          ? Text(
              value!,
              style: TextStyle(fontSize: 14, color: Color(0xFF8BA898)),
            )
          : const Icon(Icons.chevron_right, color: Color(0xFF8BA898)),
      onTap: onTap,
    );
  }
}

class SettingsToggle extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggle({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(Icons.settings, color: Color(0xFF00E676)),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Color(0xFFF0FFF4)),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Color(0xFF00E676),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    );
  }
}

class SettingsDropdown extends StatelessWidget {
  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SettingsDropdown({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.settings, color: Color(0xFF00E676)),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Color(0xFFF0FFF4)),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: Color(0xFF1A2420),
        style: TextStyle(color: Color(0xFFF0FFF4)),
        icon: Icon(Icons.arrow_drop_down, color: Color(0xFF8BA898)),
        underline: Container(height: 1, color: Color(0xFF2A3830)),
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KisanAppBar(title: 'Settings', showSearch: false),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildAccountSection(),
                const SizedBox(height: 24),
                _buildPreferencesSection(),
                const SizedBox(height: 24),
                _buildNotificationsSection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return KisanCard(
      child: Column(
        children: [
          const SettingsSectionTitle(title: 'Account'),
          const SettingsItem(title: 'Profile', icon: Icons.person, onTap: null),
          const SettingsItem(
            title: 'Security',
            icon: Icons.shield,
            onTap: null,
          ),
          const SettingsItem(
            title: 'Logout',
            icon: Icons.logout,
            isDestructive: true,
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return KisanCard(
      child: Column(
        children: [
          const SettingsSectionTitle(title: 'Preferences'),
          SettingsToggle(
            title: 'Dark Mode',
            value: true,
            onChanged: (value) {},
          ),
          SettingsDropdown(
            title: 'Language',
            value: 'Hindi',
            items: AppConstants.supportedLocales
                .map((locale) => languageCodeToName(locale.languageCode))
                .toList(),
            onChanged: (value) {},
          ),
          SettingsDropdown(
            title: 'Units',
            value: 'Metric',
            items: const ['Metric', 'Imperial'],
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return KisanCard(
      child: Column(
        children: [
          const SettingsSectionTitle(title: 'Notifications'),
          SettingsToggle(
            title: 'Push Notifications',
            value: true,
            onChanged: (value) {},
          ),
          SettingsToggle(
            title: 'Weather Alerts',
            value: true,
            onChanged: (value) {},
          ),
          SettingsToggle(
            title: 'Market Price Alerts',
            value: false,
            onChanged: (value) {},
          ),
          SettingsToggle(
            title: 'Disease Alerts',
            value: true,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return KisanCard(
      child: Column(
        children: const [
          SettingsSectionTitle(title: 'About'),
          SettingsItem(title: 'Version', value: '1.0.0', icon: Icons.info),
          SettingsItem(
            title: 'Privacy Policy',
            icon: Icons.privacy_tip,
            onTap: null,
          ),
          SettingsItem(
            title: 'Terms of Service',
            icon: Icons.description,
            onTap: null,
          ),
          SettingsItem(
            title: 'Contact Support',
            icon: Icons.support_agent,
            onTap: null,
          ),
        ],
      ),
    );
  }

  String languageCodeToName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      case 'ta':
        return 'Tamil';
      case 'te':
        return 'Telugu';
      case 'kn':
        return 'Kannada';
      case 'bn':
        return 'Bengali';
      case 'gu':
        return 'Gujarati';
      case 'pa':
        return 'Punjabi';
      case 'ml':
        return 'Malayalam';
      default:
        return code.toUpperCase();
    }
  }
}
