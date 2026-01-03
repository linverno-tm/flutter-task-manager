import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import '../home/home_screen.dart';
import '../calendar/calendar_screen.dart';
import '../statistics/statistics_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isBottomBarVisible = true;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  void _showBottomBar() {
    if (!_isBottomBarVisible) {
      setState(() => _isBottomBarVisible = true);
    }
  }

  void _hideBottomBar() {
    if (_isBottomBarVisible) {
      setState(() => _isBottomBarVisible = false);
    }
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          onScrollDown: _hideBottomBar,
          onScrollUp: _showBottomBar,
        );
      case 1:
        return CalendarScreen(
          onScrollDown: _hideBottomBar,
          onScrollUp: _showBottomBar,
        );
      case 2:
        return StatisticsScreen(
          onScrollDown: _hideBottomBar,
          onScrollUp: _showBottomBar,
        );
      case 3:
        return ProfileScreen(
          onScrollDown: _hideBottomBar,
          onScrollUp: _showBottomBar,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (_) =>
            CupertinoPageRoute(builder: (_) => _buildScreen(index)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          Stack(
            children: List.generate(
              4,
              (index) => _buildOffstageNavigator(index),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: 0,
            right: 0,
            bottom: _isBottomBarVisible ? 0 : -100,
            child: WaterDropNavBar(
              backgroundColor: const Color(0xFF1C1C1E),
              waterDropColor: CupertinoColors.systemPurple,
              inactiveIconColor: CupertinoColors.systemGrey,
              iconSize: 26,
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() {
                  _currentIndex = index;
                  _isBottomBarVisible = true;
                });
              },
              barItems: [
                BarItem(
                  filledIcon: CupertinoIcons.home,
                  outlinedIcon: CupertinoIcons.home,
                ),
                BarItem(
                  filledIcon: CupertinoIcons.calendar,
                  outlinedIcon: CupertinoIcons.calendar,
                ),
                BarItem(
                  filledIcon: CupertinoIcons.chart_bar_fill,
                  outlinedIcon: CupertinoIcons.chart_bar,
                ),
                BarItem(
                  filledIcon: CupertinoIcons.person_fill,
                  outlinedIcon: CupertinoIcons.person,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
