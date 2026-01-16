import 'package:dately/features/discovery/presentation/discovery_screen.dart';
import 'package:dately/features/likes/presentation/likes_screen.dart';
import 'package:dately/features/messages/presentation/messages_screen.dart';
import 'package:dately/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';

import 'package:dately/app/widgets/app_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DiscoveryScreen(showBottomNav: false),
          LikesScreen(showBottomNav: false),
          MessagesScreen(showBottomNav: false),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(currentTab: _getTab(_currentIndex)),
    );
  }

  AppTab _getTab(int index) {
    switch (index) {
      case 0:
        return AppTab.explore;
      case 1:
        return AppTab.likes;
      case 2:
        return AppTab.messages;
      case 3:
        return AppTab.profile;
      default:
        return AppTab.explore;
    }
  }
}
