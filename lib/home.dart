import 'package:flutter/material.dart';
import 'tabs/timeline.dart';
import 'tabs/search.dart';
import 'tabs/notifications.dart';
import 'tabs/settings.dart';

enum Pages { timeline, search, notifications, settings }

class Home extends StatefulWidget {
  final String pageName = '/';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Pages _currentPage = Pages.timeline;
  Map<Pages, Widget> _pages = {};
  // int _currentPageIndex;
  // List<Widget> _pages;`

  void _onTap(int index) {
    setState(() {
      _currentPage = Pages.values[index];
      // _currentPageIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _currentPage = Pages.timeline;
      _pages = {
        Pages.timeline: Timeline(),
        Pages.search: Search(),
        Pages.notifications: Notifications(),
        Pages.settings: Settings()
      };
      // _currentPageIndex = 0;
      // _pages = [TimeLine(), Search(), Notifications(), Settings()];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PwViewer'),
      ),
      body: _pages[_currentPage],
      // body: _pages[_currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'タイムライン',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '検索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '通知',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        currentIndex: _currentPage.index,
        // currentIndex: _currentPageIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
