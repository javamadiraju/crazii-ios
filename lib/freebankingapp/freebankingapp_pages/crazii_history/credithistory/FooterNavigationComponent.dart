import 'package:flutter/material.dart';

class FooterNavigationComponent extends StatelessWidget {
  final Function(int)? onTabSelected;
  final int currentIndex;

  const FooterNavigationComponent({
    Key? key,
    this.onTabSelected,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'Home', 'https://dashboard.codeparrot.ai/api/image/Z7RHt6WN819FoZlP/group-2.png'),
          _buildNavItem(1, 'Products', 'https://dashboard.codeparrot.ai/api/image/Z7RHt6WN819FoZlP/group-5.png'),
          _buildAddCreditButton(),
          _buildNavItem(3, 'History', 'https://dashboard.codeparrot.ai/api/image/Z7RHt6WN819FoZlP/group-4.png'),
          _buildNavItem(4, 'Profile', 'https://dashboard.codeparrot.ai/api/image/Z7RHt6WN819FoZlP/group-3.png'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconPath) {
    bool isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTabSelected?.call(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            iconPath,
            width: 36,
            height: 36,
            color: isSelected ? Colors.blue : Colors.white,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Exo',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCreditButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.brown,
          ),
          child: Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Add Credit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Exo',
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

