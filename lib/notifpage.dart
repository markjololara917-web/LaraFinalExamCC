import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        const Text(
          'Notifications',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          'A little more sound for your day.',
          style: TextStyle(color: Color(0xFFA3ABA5)),
        ),
        const SizedBox(height: 24),
        const _NotificationRow(
          icon: Icons.water_drop_outlined,
          color: Color(0xFF4F9D91),
          title: 'Fresh from the field',
          detail: 'Rain on a Window is ready to explore.',
          time: 'TODAY',
        ),
        const _NotificationRow(
          icon: Icons.local_fire_department_outlined,
          color: Color(0xFFE45C36),
          title: 'New in Nature',
          detail: 'Listen for the crackle of a campfire.',
          time: 'YESTERDAY',
        ),
        const _NotificationRow(
          icon: Icons.library_music_outlined,
          color: Color(0xFF697D4D),
          title: 'Your collection is growing',
          detail: 'Save sounds you want to find again.',
          time: '2 DAYS AGO',
        ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.detail,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String detail;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF2D332F))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(color: Color(0xFFA3ABA5), height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFFA3ABA5),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
