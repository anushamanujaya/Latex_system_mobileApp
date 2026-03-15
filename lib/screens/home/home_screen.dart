import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  void onTapBottomNav(int index) {
    setState(() {
      selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, AppRoutes.purchase);
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.transactions);
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRoutes.reports);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Latex System')),
      body: const HomeDashboard(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onTapBottomNav,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Purchase',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  Widget buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(radius: 24, child: Icon(icon)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          buildCard(
            icon: Icons.shopping_cart_checkout,
            title: 'New Purchase',
            subtitle: 'Add new latex purchase details',
            onTap: () => Navigator.pushNamed(context, AppRoutes.purchase),
          ),
          const SizedBox(height: 14),
          buildCard(
            icon: Icons.list_alt,
            title: 'Transactions',
            subtitle: 'View all saved transactions',
            onTap: () => Navigator.pushNamed(context, AppRoutes.transactions),
          ),
          const SizedBox(height: 14),
          buildCard(
            icon: Icons.bar_chart,
            title: 'Reports',
            subtitle: 'View monthly report summary',
            onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
          ),
        ],
      ),
    );
  }
}
