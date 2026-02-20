import 'package:flutter/material.dart';

class BottomNavigationComponent extends StatefulWidget {
  final int defaultIndex;

  const BottomNavigationComponent({Key? key, this.defaultIndex = 0}) : super(key: key);

  @override
  _BottomNavigationComponentState createState() => _BottomNavigationComponentState();
}

class _BottomNavigationComponentState extends State<BottomNavigationComponent> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.defaultIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, 'Home', 'https://dashboard.codeparrot.ai/api/image/Z5imv4IayXWIU-Dc/group-2.png'),
          _buildNavItem(1, 'Products', 'https://dashboard.codeparrot.ai/api/image/Z5imv4IayXWIU-Dc/group-5.png'),
          _buildNavItem(2, 'Add Credit7', 'https://dashboard.codeparrot.ai/api/image/Z5imv4IayXWIU-Dc/group-4.png'),
          _buildNavItem(3, 'History', 'https://dashboard.codeparrot.ai/api/image/Z5imv4IayXWIU-Dc/group-3.png'),
          _buildNavItem(4, 'Profile', 'https://dashboard.codeparrot.ai/api/image/Z5imv4IayXWIU-Dc/group-3.png'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconPath) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            iconPath,
            width: 36,
            height: 36,
            color: _selectedIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.white : Colors.white.withOpacity(0.5),
              fontFamily: 'Exo',
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
