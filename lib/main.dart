import 'package:flutter/material.dart';

void main() => runApp(const ShopApp());

const kAccent = Color(0xFFFF6B4A);

class Product {
  final int id;
  final String name;
  final String category;
  final int price;
  final String emoji;
  final Color color;
  final String desc;
  const Product(this.id, this.name, this.category, this.price, this.emoji,
      this.color, this.desc);
}

const products = <Product>[
  Product(1, 'Handbag', 'Bags', 2500, '👜', Color(0xFFFFE3DC),
      'Stylish handbag, daily use ke liye perfect. Strong material aur roomy design.'),
  Product(2, 'Sneakers', 'Shoes', 4200, '👟', Color(0xFFDCEBFF),
      'Comfortable sneakers, lambe time tak chalne ke liye soft sole ke saath.'),
  Product(3, 'Watch', 'Gadgets', 6800, '⌚', Color(0xFFE4F7E1),
      'Modern look wali watch, waterproof aur long battery life.'),
  Product(4, 'Sunglasses', 'Fashion', 1500, '🕶️', Color(0xFFFFF4CC),
      'UV protection sunglasses, har face cut par suit karti hain.'),
  Product(5, 'Headphones', 'Gadgets', 5400, '🎧', Color(0xFFEBE0FF),
      'Deep bass aur noise isolation wale wireless headphones.'),
  Product(6, 'T-Shirt', 'Fashion', 1200, '👕', Color(0xFFD9F5F2),
      '100% cotton t-shirt, soft aur breathable fabric.'),
  Product(7, 'Backpack', 'Bags', 3300, '🎒', Color(0xFFFFE0EC),
      'Laptop compartment ke saath durable backpack, college aur travel ke liye.'),
  Product(8, 'Gloves', 'Fashion', 700, '🧤', Color(0xFFFFEBD6),
      'Warm aur soft gloves, sardi ke liye best.'),
];

const categories = ['All', 'Bags', 'Shoes', 'Gadgets', 'Fashion'];

class CartStore {
  static final ValueNotifier<Map<int, int>> items = ValueNotifier({});

  static void add(Product p) {
    final m = Map<int, int>.from(items.value);
    m[p.id] = (m[p.id] ?? 0) + 1;
    items.value = m;
  }

  static void remove(Product p) {
    final m = Map<int, int>.from(items.value);
    final q = (m[p.id] ?? 0) - 1;
    if (q <= 0) {
      m.remove(p.id);
    } else {
      m[p.id] = q;
    }
    items.value = m;
  }

  static void clear() => items.value = {};

  static int get count => items.value.values.fold(0, (a, b) => a + b);

  static int get total {
    int t = 0;
    for (final p in products) {
      t += p.price * (items.value[p.id] ?? 0);
    }
    return t;
  }
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kAccent),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [const HomePage(), const CartPage(), const ProfilePage()];
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: ValueListenableBuilder<Map<int, int>>(
        valueListenable: CartStore.items,
        builder: (context, _, __) => NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: [
            const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home'),
            NavigationDestination(
                icon: Badge(
                    isLabelVisible: CartStore.count > 0,
                    label: Text('${CartStore.count}'),
                    child: const Icon(Icons.shopping_cart_outlined)),
                selectedIcon: const Icon(Icons.shopping_cart),
                label: 'Cart'),
            const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String cat = 'All';
  String query = '';

  @override
  Widget build(BuildContext context) {
    final list = products.where((p) {
      final okCat = cat == 'All' || p.category == cat;
      final okQ = p.name.toLowerCase().contains(query.toLowerCase());
      return okCat && okQ;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text('Discover',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ChoiceChip(
              label: Text(categories[i]),
              selected: cat == categories[i],
              selectedColor: kAccent,
              labelStyle: TextStyle(
                  color: cat == categories[i] ? Colors.white : Colors.black87),
              onSelected: (_) => setState(() => cat = categories[i]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('Koi product nahi mila'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72),
                  itemCount: list.length,
                  itemBuilder: (_, i) => ProductCard(product: list[i]),
                ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailPage(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: product.color,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                alignment: Alignment.center,
                child: Text(product.emoji, style: const TextStyle(fontSize: 64)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Text(product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 8, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rs ${product.price}',
                      style: const TextStyle(
                          color: kAccent, fontWeight: FontWeight.bold)),
                  InkWell(
                    onTap: () {
                      CartStore.add(product);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('${product.name} cart me add ho gaya'),
                          duration: const Duration(seconds: 1)));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                          color: kAccent, shape: BoxShape.circle),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Product product;
  const DetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Column(
        children: [
          Container(
            height: 280,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: product.color, borderRadius: BorderRadius.circular(24)),
            alignment: Alignment.center,
            child: Text(product.emoji, style: const TextStyle(fontSize: 120)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    Text('Rs ${product.price}',
                        style: const TextStyle(
                            fontSize: 22,
                            color: kAccent,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Chip(label: Text(product.category)),
                const SizedBox(height: 8),
                Text(product.desc,
                    style: TextStyle(
                        fontSize: 15, color: Colors.grey.shade700, height: 1.5)),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: kAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                onPressed: () {
                  CartStore.add(product);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Cart me add ho gaya'),
                      duration: Duration(seconds: 1)));
                },
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Add to Cart'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<int, int>>(
      valueListenable: CartStore.items,
      builder: (context, cart, _) {
        final inCart = products.where((p) => cart.containsKey(p.id)).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('My Cart',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: inCart.isEmpty
                  ? const Center(child: Text('Cart khali hai 🛒'))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: inCart.length,
                      itemBuilder: (_, i) {
                        final p = inCart[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                    color: p.color,
                                    borderRadius: BorderRadius.circular(14)),
                                alignment: Alignment.center,
                                child: Text(p.emoji,
                                    style: const TextStyle(fontSize: 30)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text('Rs ${p.price}',
                                        style:
                                            const TextStyle(color: kAccent)),
                                  ],
                                ),
                              ),
                              IconButton(
                                  onPressed: () => CartStore.remove(p),
                                  icon: const Icon(Icons.remove_circle_outline)),
                              Text('${cart[p.id]}'),
                              IconButton(
                                  onPressed: () => CartStore.add(p),
                                  icon: const Icon(Icons.add_circle_outline)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            if (inCart.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontSize: 18)),
                        Text('Rs ${CartStore.total}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: kAccent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16))),
                        onPressed: () {
                          CartStore.clear();
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Order Placed ✅'),
                              content: const Text('Shukriya! Aapka order ho gaya.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'))
                              ],
                            ),
                          );
                        },
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SizedBox(height: 24),
        Center(
          child: CircleAvatar(
              radius: 44,
              backgroundColor: kAccent,
              child: Icon(Icons.person, size: 48, color: Colors.white)),
        ),
        SizedBox(height: 12),
        Center(
            child: Text('Guest User',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        SizedBox(height: 24),
        ListTile(leading: Icon(Icons.receipt_long), title: Text('My Orders')),
        ListTile(leading: Icon(Icons.favorite_border), title: Text('Wishlist')),
        ListTile(leading: Icon(Icons.location_on_outlined), title: Text('Addresses')),
        ListTile(leading: Icon(Icons.settings_outlined), title: Text('Settings')),
      ],
    );
  }
}
