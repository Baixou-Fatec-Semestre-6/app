import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baixou/core/theme/app_theme.dart';
import 'package:baixou/core/utils/responsive_layout.dart';
import 'package:baixou/features/auth/presentation/controllers/auth_notifier.dart';
import 'package:baixou/features/notifications/presentation/controllers/notifications_notifier.dart';
import 'package:baixou/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:baixou/features/products/presentation/controllers/products_notifier.dart';
import 'package:baixou/features/products/presentation/widgets/add_product_dialog.dart';
import 'package:baixou/features/products/presentation/widgets/product_card.dart';
import 'package:baixou/features/auth/presentation/screens/profile_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0; // 0 = Products, 1 = Notifications, 2 = Profile
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final authNotifier = Provider.of<AuthNotifier>(context);
    final notificationsNotifier = Provider.of<NotificationsNotifier>(context);
    final productsNotifier = Provider.of<ProductsNotifier>(context);

    return Scaffold(
      body: isMobile
          ? _buildMobileShell(authNotifier, notificationsNotifier, productsNotifier)
          : _buildDesktopShell(authNotifier, notificationsNotifier, productsNotifier),
      floatingActionButton: isMobile && _currentTabIndex == 0
          ? FloatingActionButton(
              onPressed: () => AddProductDialog.show(context, isMobile: true),
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  // --- MOBILE SHELL ---
  Widget _buildMobileShell(
    AuthNotifier authNotifier,
    NotificationsNotifier notificationsNotifier,
    ProductsNotifier productsNotifier,
  ) {
    return Column(
      children: [
        // App Bar / Header
        _buildMobileAppBar(authNotifier, notificationsNotifier),
        // Content Area
        Expanded(
          child: IndexedStack(
            index: _currentTabIndex,
            children: [
              _buildProductsTab(productsNotifier, isMobile: true),
              const NotificationsScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
        // Bottom Nav Bar
        BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) => setState(() => _currentTabIndex = index),
          backgroundColor: AppTheme.darkCard,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Produtos',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: notificationsNotifier.unreadCount > 0,
                label: Text(notificationsNotifier.unreadCount.toString()),
                child: const Icon(Icons.notifications_outlined),
              ),
              activeIcon: const Icon(Icons.notifications),
              label: 'Notificações',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileAppBar(AuthNotifier auth, NotificationsNotifier notifications) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: AppTheme.darkBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'B',
                  style: TextStyle(
                    fontFamily: 'Barlow Condensed',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'BAIXOU',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: AppTheme.textSecondary),
            onPressed: () => auth.logout(),
          ),
        ],
      ),
    );
  }

  // --- DESKTOP / WEB SHELL ---
  Widget _buildDesktopShell(
    AuthNotifier authNotifier,
    NotificationsNotifier notificationsNotifier,
    ProductsNotifier productsNotifier,
  ) {
    return Row(
      children: [
        // Side Navigation Rail
        NavigationRail(
          selectedIndex: _currentTabIndex,
          onDestinationSelected: (index) => setState(() => _currentTabIndex = index),
          backgroundColor: AppTheme.darkCard,
          selectedIconTheme: const IconThemeData(color: AppTheme.primary),
          unselectedIconTheme: const IconThemeData(color: AppTheme.textSecondary),
          labelType: NavigationRailLabelType.all,
          selectedLabelTextStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
          unselectedLabelTextStyle: const TextStyle(color: AppTheme.textSecondary),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primary, width: 2.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'BX',
                style: TextStyle(
                  fontFamily: 'Barlow Condensed',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      authNotifier.currentUser?.email.split('@')[0] ?? 'User',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    IconButton(
                      icon: const Icon(Icons.logout, color: AppTheme.statusFailed),
                      tooltip: 'Sair da conta',
                      onPressed: () => authNotifier.logout(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          destinations: [
            const NavigationRailDestination(
              icon: Icon(Icons.shopping_bag_outlined),
              selectedIcon: Icon(Icons.shopping_bag),
              label: Text('Produtos'),
            ),
            NavigationRailDestination(
              icon: Badge(
                isLabelVisible: notificationsNotifier.unreadCount > 0,
                label: Text(notificationsNotifier.unreadCount.toString()),
                child: const Icon(Icons.notifications_outlined),
              ),
              selectedIcon: const Icon(Icons.notifications),
              label: const Text('Alertas'),
            ),
            const NavigationRailDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: Text('Perfil'),
            ),
          ],
        ),
        const VerticalDivider(width: 1, color: AppTheme.border),
        // Content Area
        Expanded(
          child: IndexedStack(
            index: _currentTabIndex,
            children: [
              _buildProductsTab(productsNotifier, isMobile: false),
              const NotificationsScreen(),
              const ProfileScreen(),
            ],
          ),
        ),
      ],
    );
  }

  // --- PRODUCTS LIST TAB ---
  Widget _buildProductsTab(ProductsNotifier productsNotifier, {required bool isMobile}) {
    // Filter products based on search query
    final filteredProducts = productsNotifier.products.where((p) {
      final query = _searchQuery.toLowerCase();
      if (p.title != null && p.title!.toLowerCase().contains(query)) return true;
      if (p.url.toLowerCase().contains(query)) return true;
      return false;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row (Search + Add Button)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar produtos monitorados...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Rastrear Produto'),
                  onPressed: () => AddProductDialog.show(context, isMobile: false),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Grid list of products
          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState(productsNotifier.products.isEmpty)
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isMobile ? 350 : 280,
                      mainAxisExtent: isMobile ? 220 : 250,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: filteredProducts[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isListEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isListEmpty ? Icons.add_shopping_cart : Icons.search_off,
              color: AppTheme.textSecondary.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              isListEmpty ? 'Sem produtos sendo monitorados' : 'Nenhum resultado encontrado',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isListEmpty
                  ? 'Pesquise e selecione um produto da nossa base para iniciar o rastreamento automático.'
                  : 'Tente ajustar sua busca ou limpar os termos do filtro.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            if (isListEmpty) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Começar Rastreamento'),
                onPressed: () {
                  final isMobile = ResponsiveLayout.isMobile(context);
                  AddProductDialog.show(context, isMobile: isMobile);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
