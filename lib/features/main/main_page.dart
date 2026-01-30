// import 'package:flutter/material.dart';
// import 'map_page.dart';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   int selectedIndex = 0;

//   final pages = [
//     const MapPage(),
//     const Center(child: Text('Page 2')),
//     const Center(child: Text('Page 3')),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           // SIDEBAR
//           Container(
//             width: 72,
//             color: Colors.white,
//             child: Column(
//               children: [
//                 const SizedBox(height: 24),

//                 _buildIcon(
//                   icon: Icons.motorcycle,
//                   index: 0,
//                 ),
//                 _buildIcon(
//                   icon: Icons.notifications,
//                   index: 1,
//                 ),
//                 _buildIcon(
//                   icon: Icons.person,
//                   index: 2,
//                 ),
//               ],
//             ),
//           ),

//           // CONTENT
//           Expanded(
//             child: Stack(
//               children: [
//                 pages[selectedIndex],

//                 // BACK BUTTON
//                 Positioned(
//                   top: 24,
//                   left: 24,
//                   child: InkWell(
//                     onTap: () => Navigator.pop(context),
//                     child: Row(
//                       children: const [
//                         Icon(Icons.arrow_back_ios, size: 18),
//                         SizedBox(width: 4),
//                         Text('Back'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildIcon({required IconData icon, required int index}) {
//     final isSelected = selectedIndex == index;

//     return InkWell(
//       onTap: () {
//         setState(() {
//           selectedIndex = index;
//         });
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 12),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isSelected ? Colors.blue.withOpacity(0.1) : null,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(
//           icon,
//           color: isSelected ? Colors.blue : Colors.grey,
//           size: 28,
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import '../home/home_vehicle_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final pages = const [
    HomeVehiclePage(),
    Center(child: Text('Notifications')),
    Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // SIDEBAR
          Container(
            width: 72,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildIcon(Icons.motorcycle, 0),
                _buildIcon(Icons.notifications, 1),
                _buildIcon(Icons.person, 2),
              ],
            ),
          ),

          // CONTENT
          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() => selectedIndex = index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.grey,
          size: 28,
        ),
      ),
    );
  }
}
