import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kisan_ai/core/theme/app_theme.dart';
import 'package:kisan_ai/shared/widgets/kisan_widgets.dart';
import 'package:kisan_ai/providers/farmer_profile_provider.dart';

class _Notification {
  final String title;
  final String body;
  final String time;
  final IconData icon;
  final Color color;
  final String category;
  bool isRead;

  _Notification({
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    required this.category,
    this.isRead = false,
  });
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<_Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateDynamicNotifications();
    });
  }

  void _generateDynamicNotifications() {
    final profile = ref.read(farmerProfileProvider);
    final cropName = profile?.cropName ?? 'Wheat';
    final district = profile?.district ?? 'your district';
    final state = profile?.state ?? 'your state';
    
    final List<_Notification> dynamicNotifs = [];

    // Weather Alert
    dynamicNotifs.add(_Notification(
      title: '🌧️ Rain Alert — Next 48 Hours',
      body: 'Heavy rainfall expected in $district. Consider delaying fertilizer application for $cropName.',
      time: '2 hours ago',
      icon: Icons.water_drop,
      color: const Color(0xFF2196F3),
      category: 'Weather',
    ));

    // Market Alert
    dynamicNotifs.add(_Notification(
      title: '📈 $cropName Price Alert',
      body: '$cropName prices have increased in $state markets. Check the Market section for latest trends.',
      time: '5 hours ago',
      icon: Icons.trending_up,
      color: const Color(0xFF00E676),
      category: 'Market',
    ));

    // Scheme Alert
    dynamicNotifs.add(_Notification(
      title: '🌾 New Government Scheme in $state',
      body: 'A new subsidy is available for $cropName farmers in your state. Check eligibility in Schemes section.',
      time: '1 day ago',
      icon: Icons.account_balance,
      color: const Color(0xFFFFB300),
      category: 'Scheme',
    ));

    // Disease Alert
    dynamicNotifs.add(_Notification(
      title: '🐛 Disease Precautions for $cropName',
      body: 'Fungal diseases are spreading in $district. Use our Disease Scanner to check your crops early and apply preventive fungicides.',
      time: '1 day ago',
      icon: Icons.bug_report,
      color: const Color(0xFFFF5252),
      category: 'Alert',
      isRead: true,
    ));

    if (profile?.reportGenerated == true) {
      dynamicNotifs.add(_Notification(
        title: '📊 Your Farm Report is Ready',
        body: 'Your personalized farm plan for $cropName has been generated based on your soil type (${profile?.soilType}). Tap to view.',
        time: '2 days ago',
        icon: Icons.assignment,
        color: const Color(0xFF7C4DFF),
        category: 'Report',
        isRead: true,
      ));
    }

    setState(() {
      _notifications = dynamicNotifs;
    });
  }


  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Weather', 'Market', 'Scheme', 'Alert', 'Report'];

  List<_Notification> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    return _notifications.where((n) => n.category == _selectedFilter).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) n.isRead = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1F17), Color(0xFF0A0F0D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).canPop()
                        ? Navigator.of(context).pop()
                        : null,
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notifications',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF0FFF4))),
                        if (_unreadCount > 0)
                          Text('$_unreadCount unread',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF00E676))),
                      ],
                    ),
                  ),
                  if (_unreadCount > 0)
                    TextButton(
                      onPressed: _markAllRead,
                      child: const Text('Mark all read',
                          style: TextStyle(color: Color(0xFF00E676), fontSize: 12)),
                    ),
                ],
              ),
            ),

            // Filter chips
            Container(
              color: const Color(0xFF0A0F0D),
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentGreen : const Color(0xFF1A2420),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.accentGreen : const Color(0xFF2E3D38),
                        ),
                      ),
                      child: Text(filter,
                          style: TextStyle(
                              color: isSelected ? const Color(0xFF0A0F0D) : const Color(0xFF8BA898),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13)),
                    ),
                  );
                },
              ),
            ),

            const Divider(color: Color(0xFF1A2420), height: 1),

            // List
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: 64, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text('No notifications in this category',
                              style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredNotifications.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: Color(0xFF1A2420), height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final notif = _filteredNotifications[index];
                        return _buildNotificationTile(notif);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(_Notification notif) {
    return InkWell(
      onTap: () => setState(() => notif.isRead = true),
      child: Container(
        color: notif.isRead
            ? Colors.transparent
            : notif.color.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notif.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(notif.icon, color: notif.color, size: 22),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notif.title,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                color: notif.isRead
                                    ? const Color(0xFF8BA898)
                                    : const Color(0xFFF0FFF4))),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                              color: notif.color, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif.body,
                      style: TextStyle(
                          fontSize: 12,
                          color: notif.isRead
                              ? const Color(0xFF4A5E58)
                              : const Color(0xFF8BA898)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: notif.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(notif.category,
                            style: TextStyle(
                                color: notif.color, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text(notif.time,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF4A5E58))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
