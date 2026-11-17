
import 'package:flutter/material.dart';

void main() {
  runApp(const NutriLensApp());
}

class NutriLensApp extends StatelessWidget {
  const NutriLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NUTRILENS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF081410),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF35D69A),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<String> titles = [
    'Discover',
    'Scanner',
    'Nutrition',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: selectedIndex == 0
              ? dashboard()
              : otherPage(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF101F19),
        indicatorColor: const Color(0xFF245D46),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget dashboard() {
    return SingleChildScrollView(
      key: const ValueKey('dashboard'),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'NUTRILENS',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0xFF45DDA2),
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'SEE BEYOND THE LABEL',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              const CircleAvatar(
                backgroundColor: Color(0xFF193B2D),
                child: Icon(Icons.eco, color: Color(0xFF45DDA2)),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Eat smarter.',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Know what is inside your food.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white60,
            ),
          ),
          const SizedBox(height: 25),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 900),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF176B4A),
                    Color(0xFF103B2B),
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFF45DDA2).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.document_scanner_outlined,
                    size: 38,
                    color: Color(0xFF72F5BC),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'SCAN YOUR FOOD',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Explore nutrition and ingredients.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => selectedIndex = 1);
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Start scanning'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BFFD0),
                      foregroundColor: const Color(0xFF082418),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'EXPLORE FEATURES',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 2,
              color: Color(0xFF45DDA2),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 17),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 13,
            crossAxisSpacing: 13,
            childAspectRatio: 1.25,
            children: const [
              FeatureCard(
                icon: Icons.qr_code_2,
                title: 'Barcode Scan',
                subtitle: 'Identify products',
              ),
              FeatureCard(
                icon: Icons.restaurant_menu,
                title: 'Nutrition',
                subtitle: 'Explore nutrients',
              ),
              FeatureCard(
                icon: Icons.science_outlined,
                title: 'Ingredients',
                subtitle: 'Understand labels',
              ),
              FeatureCard(
                icon: Icons.compare_arrows,
                title: 'Compare',
                subtitle: 'Compare products',
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            'YOUR FOOD. YOUR KNOWLEDGE.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget otherPage() {
    return Center(
      key: ValueKey(selectedIndex),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              [
                Icons.home,
                Icons.qr_code_scanner,
                Icons.analytics,
                Icons.person,
              ][selectedIndex],
              size: 65,
              color: const Color(0xFF45DDA2),
            ),
            const SizedBox(height: 20),
            Text(
              titles[selectedIndex],
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'NUTRILENS feature module',
              style: TextStyle(color: Colors.white54),
            ),
            const SizedBox(height: 20),
            const Text(
              'This feature is under development.',
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF13241C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 29,
            color: const Color(0xFF45DDA2),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}
