import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/kisan_widgets.dart';
import '../../../../features/auth/state/auth_provider.dart';
import '../../../../providers/farmer_profile_provider.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.valueOrNull?.user;
    final farmProfile = ref.watch(farmerProfileProvider);

    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0F0D),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E676)),
        ),
      );
    }

    // Resolve display values: prefer farm profile data, fallback to auth user
    final displayName = (farmProfile?.name.isNotEmpty == true)
        ? farmProfile!.name
        : (currentUser?.name ?? '');
    final displayEmail = (farmProfile?.email.isNotEmpty == true)
        ? farmProfile!.email
        : (currentUser?.email ?? '');
    final displayPhone = (farmProfile?.phone.isNotEmpty == true)
        ? farmProfile!.phone
        : (currentUser?.phone ?? '');
    final displayLocation = farmProfile != null
        ? [farmProfile.village, farmProfile.district, farmProfile.state]
            .where((s) => s.isNotEmpty)
            .join(', ')
        : '';
    final displayRole = currentUser?.role ?? 'Farmer';
    final displayInitial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final memberSince = currentUser?.createdAt != null
        ? _formatDate(currentUser!.createdAt!)
        : 'Recently joined';

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0F0D),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_off_outlined, size: 64, color: Color(0xFF8BA898)),
              SizedBox(height: 16),
              Text('No user data available',
                  style: TextStyle(color: Color(0xFF8BA898), fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F0D),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: KisanAppBar(title: 'My Profile', showSearch: false)),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile header card
                _buildProfileHeader(
                  context,
                  displayName: displayName,
                  displayRole: displayRole,
                  displayLocation: displayLocation,
                  initial: displayInitial,
                ),
                const SizedBox(height: 20),

                // Quick stats row (if farm profile exists)
                if (farmProfile != null) ...[
                  _buildFarmStats(farmProfile),
                  const SizedBox(height: 20),
                ],

                _buildSectionTitle('Personal Information'),
                _buildInfoCard([
                  _InfoRow(icon: Icons.person_outline, label: 'Name',
                      value: displayName.isNotEmpty ? displayName : 'Not provided'),
                  _InfoRow(icon: Icons.phone, label: 'Phone',
                      value: displayPhone.isNotEmpty ? displayPhone : 'Not provided'),
                  _InfoRow(icon: Icons.email, label: 'Email',
                      value: displayEmail.isNotEmpty ? displayEmail : 'Not provided'),
                  _InfoRow(icon: Icons.location_on, label: 'Location',
                      value: displayLocation.isNotEmpty ? displayLocation : 'Not provided'),
                ]),
                const SizedBox(height: 20),

                if (farmProfile != null) ...[
                  _buildSectionTitle('Farm Details'),
                  _buildInfoCard([
                    _InfoRow(icon: Icons.landscape, label: 'Land Area',
                        value: '${farmProfile.landAcres.toStringAsFixed(1)} acres'),
                    _InfoRow(icon: Icons.grass, label: 'Soil Type',
                        value: farmProfile.soilType.isNotEmpty ? farmProfile.soilType : 'Not set'),
                    _InfoRow(icon: Icons.water_drop, label: 'Water Source',
                        value: farmProfile.waterSource.isNotEmpty ? farmProfile.waterSource : 'Not set'),
                    if (farmProfile.cropName?.isNotEmpty == true)
                      _InfoRow(icon: Icons.spa, label: 'Current Crop',
                          value: farmProfile.cropName!),
                  ]),
                  const SizedBox(height: 20),
                ],

                _buildSectionTitle('Account'),
                _buildInfoCard([
                  _InfoRow(icon: Icons.badge, label: 'Role',
                      value: displayRole[0].toUpperCase() + displayRole.substring(1)),
                  _InfoRow(icon: Icons.calendar_today, label: 'Member Since',
                      value: memberSince),
                  _InfoRow(icon: Icons.verified, label: 'Status', value: 'Active ✓'),
                ]),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  Widget _buildProfileHeader(
    BuildContext context, {
    required String displayName,
    required String displayRole,
    required String displayLocation,
    required String initial,
  }) {
    return KisanCard(
      child: Column(
        children: [
          // Avatar with edit overlay
          Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: const Color(0xFF00E676),
                child: Text(initial,
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0A0F0D))),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
                  child: Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(
                        color: Color(0xFF00E676), shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Color(0xFF0A0F0D), size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName.isNotEmpty ? displayName : 'Farmer',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF0FFF4)),
          ),
          const SizedBox(height: 4),
          Text(
            '${displayRole[0].toUpperCase()}${displayRole.substring(1)}'
            '${displayLocation.isNotEmpty ? " • $displayLocation" : ""}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF8BA898)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 160,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileEditScreen())),
              icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF0A0F0D)),
              label: const Text('Edit Profile',
                  style: TextStyle(color: Color(0xFF0A0F0D), fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmStats(FarmerProfileModel profile) {
    return Row(
      children: [
        _buildStatCard('🌾', '${profile.landAcres.toStringAsFixed(1)}', 'Acres'),
        const SizedBox(width: 10),
        _buildStatCard('🌱', profile.cropName ?? '—', 'Crop'),
        const SizedBox(width: 10),
        _buildStatCard('💧', profile.waterSource.isNotEmpty ? profile.waterSource.split(' ').first : '—', 'Water'),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2420),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E3D38)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFF0FFF4)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8BA898))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
    );
  }

  Widget _buildInfoCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2420),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3D38)),
      ),
      child: Column(
        children: List.generate(rows.length, (i) => Column(
          children: [
            rows[i],
            if (i < rows.length - 1)
              const Divider(color: Color(0xFF2E3D38), height: 1, indent: 52),
          ],
        )),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E676), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF8BA898))),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(fontSize: 15, color: Color(0xFFF0FFF4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
