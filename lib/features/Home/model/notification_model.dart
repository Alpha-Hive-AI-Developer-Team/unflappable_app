class NotificationItem {
  final String title;
  final String body;
  final String time;
  final bool isNew;

  const NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    this.isNew = false,
  });
}

const newNotifications = [
  NotificationItem(
    title: 'Breathe and refocus 🧘',
    body:
        'A deep breath can clear your mind and spark fresh ideas. Try it and watch your creativity flow! ✨',
    time: 'Just now',
    isNew: true,
  ),
  NotificationItem(
    title: "You're THIS close ✨",
    body:
        "2 out of 3 done 🎯\nBas ek aur task finish it and lock your day like a pro 🔥",
    time: '2 min ago',
    isNew: true,
  ),
  NotificationItem(
    title: 'Keep the momentum going 🚀',
    body:
        "Remember, progress is progress no matter how small. Celebrate every step forward! 💪",
    time: '3h ago',
    isNew: true,
  ),
  NotificationItem(
    title: 'Pause for a second 🛑',
    body:
        "Feeling stuck? 🤔\nTake 30 seconds, reset your mind, and get back in control! ⚡",
    time: '5h ago',
    isNew: true,
  ),
];

const oldNotifications = [
  NotificationItem(
    title: "You're on fire 🔥🔥",
    body:
        "3-day streak going strong 💥\nDon't break it now tomorrow depends on today 📅",
    time: 'Yesterday',
  ),
  NotificationItem(
    title: 'Keep it going 📈',
    body: "Small wins today = big results tomorrow. Stay locked in 🔒",
    time: '1 week ago',
  ),
  NotificationItem(
    title: 'Hey... quick check ✨',
    body: "Are you doing what actually matters right now?",
    time: '2 week ago',
  ),
];
