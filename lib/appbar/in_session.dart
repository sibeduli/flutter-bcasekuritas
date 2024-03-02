import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InSessionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefresh;
  const InSessionAppBar({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: SvgPicture.asset(
        'assets/logo_bca.svg',
        height: 140,
      ),
      centerTitle: true,
      backgroundColor: Colors.white70,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh), // Use built-in refresh icon
          onPressed: onRefresh,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4.0), // Adjust height for shadow
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(0.2), // Shadow color and opacity
                spreadRadius: 1, // Spread radius
                blurRadius: 1, // Blur radius
                offset: const Offset(0, 2), // Changes position of shadow
              ),
            ],
          ),
          height:
              1.0, // Actual border height is minimal; shadow takes extra space
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
      kToolbarHeight + 4.0); // AppBar height + bottom border height
}
