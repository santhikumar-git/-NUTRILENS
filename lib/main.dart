
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const green = Color(0xFF45DDA2);
const bg = Color(0xFF081410);

void main() => runApp(const NutriLensApp());

class NutriLensApp extends StatelessWidget {
  const NutriLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NUTRILENS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
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
  int index = 0;
  bool loading = false;
  Map<String, dynamic>? product;
  String? error;

  Future<void> lookup(String barcode) async {
    if (loading) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final uri = Uri.https(
        'world.openfoodfacts.org',
        '/api/v2/product/$barcode.json',
        {
          'fields':
              'product_name,brands,quantity,image_url,ingredients_text,nutriments',
        },
      );

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'NUTRILENS Android App'},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Server connection failed.');
      }

      final data = jsonDecode(response.body);

      if (data['status'] != 1 || data['product'] == null) {
        throw Exception('Product not found. Try another barcode.');
      }

      if (!mounted) return;

      setState(() {
        product = Map<String, dynamic>.from(data['product']);
        index = 2;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error!)),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: index,
          children: [
            dashboard(),
            ScannerPage(onScan: lookup, loading: loading),
            NutritionPage(product: product, loading: loading),
            const ProfilePage(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF101F19),
        indicatorColor: const Color(0xFF245D46),
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
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
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NUTRILENS',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: green,
            ),
          ),
          const Text(
            'SEE BEYOND THE LABEL',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 35),
          const Text(
            'Eat smarter.',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Know what is inside your food.',
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF176B4A), Color(0xFF103B2B)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.qr_code_scanner, size: 42, color: green),
                const SizedBox(height: 18),
                const Text(
                  'SCAN YOUR FOOD',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Explore nutrition and ingredients.'),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => setState(() => index = 1),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Start scanning'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BFFD0),
                    foregroundColor: const Color(0xFF082418),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'EXPLORE FEATURES',
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              feature(Icons.qr_code_2, 'Barcode Scan',
                  'Identify products', () => setState(() => index = 1)),
              feature(Icons.restaurant_menu, 'Nutrition',
                  'Explore nutrients', () => setState(() => index = 2)),
              feature(Icons.science_outlined, 'Ingredients',
                  'Understand labels', () => setState(() => index = 2)),
              feature(Icons.person_outline, 'Profile',
                  'Your settings', () => setState(() => index = 3)),
            ],
          ),
          const SizedBox(height: 25),
          if (product != null)
            Text('Last scanned: ${product!['product_name'] ?? 'Food product'}'),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'YOUR FOOD. YOUR KNOWLEDGE.',
              style: TextStyle(color: Colors.white38, letterSpacing: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget feature(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback action,
  ) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF13241C),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: green, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class ScannerPage extends StatefulWidget {
  final Future<void> Function(String) onScan;
  final bool loading;

  const ScannerPage({
    super.key,
    required this.onScan,
    required this.loading,
  });

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final controller = MobileScannerController();
  final manual = TextEditingController();
  bool detected = false;

  @override
  void dispose() {
    controller.dispose();
    manual.dispose();
    super.dispose();
  }

  Future<void> scan(BarcodeCapture capture) async {
    if (detected || widget.loading) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        detected = true;
        await controller.stop();
        await widget.onScan(value);
        if (mounted) {
          detected = false;
          await controller.start();
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'FOOD SCANNER',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Place a product barcode inside the camera frame.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(
                    controller: controller,
                    onDetect: scan,
                  ),
                  Center(
                    child: Container(
                      width: 245,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(color: green, width: 3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                  if (widget.loading)
                    const ColoredBox(
                      color: Colors.black54,
                      child: Center(
                        child: CircularProgressIndicator(color: green),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: manual,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter barcode manually',
              filled: true,
              fillColor: const Color(0xFF13241C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: green),
                onPressed: () {
                  final value = manual.text.trim();
                  if (value.isNotEmpty) widget.onScan(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Product information is retrieved from Open Food Facts.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class NutritionPage extends StatelessWidget {
  final Map<String, dynamic>? product;
  final bool loading;

  const NutritionPage({
    super.key,
    required this.product,
    required this.loading,
  });

  String value(dynamic v, String unit) {
    if (v == null) return 'Not available';
    final number = double.tryParse(v.toString());
    if (number == null) return 'Not available';
    return '${number.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: green),
      );
    }

    if (product == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Text(
            'Scan a food barcode to see nutrition and ingredient information.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white60),
          ),
        ),
      );
    }

    final nutrients =
        product!['nutriments'] as Map<String, dynamic>? ?? {};

    final name = product!['product_name'] ?? 'Unnamed product';
    final ingredients = product!['ingredients_text'] ??
        'Ingredient information not available.';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PRODUCT INFORMATION',
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          if (product!['image_url'] != null)
            Center(
              child: Image.network(
                product!['image_url'],
                height: 160,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.fastfood, size: 80, color: green),
              ),
            ),
          const SizedBox(height: 18),
          Text(name,
              style:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            '${product!['brands'] ?? 'Brand not available'}'
            ' • ${product!['quantity'] ?? 'Quantity unknown'}',
            style: const TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 25),
          const Text(
            'NUTRITION INFORMATION',
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          nutrient('Energy', value(nutrients['energy-kcal_100g'], 'kcal/100g')),
          nutrient('Protein', value(nutrients['proteins_100g'], 'g/100g')),
          nutrient('Carbohydrates',
              value(nutrients['carbohydrates_100g'], 'g/100g')),
          nutrient('Total fat', value(nutrients['fat_100g'], 'g/100g')),
          nutrient('Sugar', value(nutrients['sugars_100g'], 'g/100g')),
          nutrient('Salt', value(nutrients['salt_100g'], 'g/100g')),
          const SizedBox(height: 25),
          const Text(
            'INGREDIENTS',
            style: TextStyle(
              color: green,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: const Color(0xFF13241C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(ingredients.toString()),
          ),
          const SizedBox(height: 20),
          const Text(
            'Values are database information per 100 g. Missing values are not estimated.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget nutrient(String name, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF13241C),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(amount,
              style: const TextStyle(
                color: green,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final nameController = TextEditingController();
  bool saved = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    nameController.text = prefs.getString('profile_name') ?? '';
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', nameController.text.trim());
    if (!mounted) return;
    setState(() => saved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved on this device.')),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_circle, size: 85, color: green),
          const SizedBox(height: 20),
          const Text(
            'YOUR PROFILE',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Your name',
              filled: true,
              fillColor: const Color(0xFF13241C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Save profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: bg,
                padding: const EdgeInsets.all(15),
              ),
            ),
          ),
          if (saved)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Profile saved', style: TextStyle(color: green)),
            ),
          const SizedBox(height: 15),
          const Text(
            'Your profile name is stored locally on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}


