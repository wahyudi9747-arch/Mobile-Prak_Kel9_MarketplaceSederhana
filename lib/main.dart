import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MobilePrakApp());
}

class MobilePrakApp extends StatelessWidget {
  const MobilePrakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GadgetStore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const MarketplaceHome(),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

String formatRupiah(double harga) {
  final formatted = harga
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  return 'Rp $formatted';
}

// ─── Model ────────────────────────────────────────────────────────────────────

class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.image = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      category: json['category'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'image': image,
      };
}

// ─── Product Service (MockAPI) ────────────────────────────────────────────────

class ProductService {
  static const String _url =
      'https://6a0043ff2b7ab34960302ef8.mockapi.io/products/products';

  static Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse(_url))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat produk (${response.statusCode})');
    }
  }
}

// ─── Cart Storage (SharedPreferences) ────────────────────────────────────────

class CartStorage {
  static const String _key = 'cart_items';

  static Future<void> saveCart(List<Product> cart) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cart.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  static Future<List<Product>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    return jsonList.map((s) => Product.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

// ─── Home Page ────────────────────────────────────────────────────────────────

class MarketplaceHome extends StatefulWidget {
  const MarketplaceHome({super.key});

  @override
  State<MarketplaceHome> createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends State<MarketplaceHome> {
  List<Product> _allProducts = [];
  List<Product> cart = [];
  bool _isLoading = true;
  String? _errorMessage;
  String selectedCategory = 'Semua';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  void _unfocusSearch() => _searchFocus.unfocus();

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    final savedCart = await CartStorage.loadCart();
    setState(() => cart = savedCart);
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final products = await ProductService.fetchProducts();
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat produk.\nCek koneksi internet kamu.';
        _isLoading = false;
      });
    }
  }

  List<Product> get filteredProducts {
    return _allProducts.where((p) {
      final matchesCategory =
          selectedCategory == 'Semua' || p.category == selectedCategory;
      final matchesSearch =
          p.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<String> get categories {
    final cats = _allProducts.map((p) => p.category).toSet().toList()..sort();
    return ['Semua', ...cats];
  }

  void tambahKeKeranjang(Product product) {
    setState(() => cart.add(product));
    CartStorage.saveCart(cart); // simpan ke SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'GadgetStore',
          style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.user, size: 20),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () => _tampilkanKeranjang(context),
                icon: const Icon(LucideIcons.shoppingBag, size: 20),
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: _unfocusSearch, // tap di mana saja = tutup keyboard
        behavior: HitTestBehavior.translucent,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: (val) => setState(() => searchQuery = val),
              onSubmitted: (_) => _unfocusSearch(), // tekan Enter = tutup keyboard
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari produk',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (!_isLoading && _errorMessage == null)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) =>
                          setState(() => selectedCategory = cat),
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              'Daftar Produk',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat produk...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.wifiOff, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (filteredProducts.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan'));
    }

    // Pull-to-refresh: tarik layar ke bawah = fetch ulang dari MockAPI
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return GestureDetector(
            onTap: () => _tampilkanDetailProduk(context, product),
            child: _ProductCard(
              product: product,
              onAdd: () => tambahKeKeranjang(product),
            ),
          );
        },
      ),
    );
  }

  void _tampilkanDetailProduk(BuildContext context, Product product) {
    _unfocusSearch(); // tutup keyboard sebelum buka modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: product.image.isNotEmpty
                  ? Image.network(
                      product.image,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
            const SizedBox(height: 20),
            Text(product.category.toUpperCase(),
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                )),
            Text(product.name,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(formatRupiah(product.price),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueAccent,
                )),
            const SizedBox(height: 20),
            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(product.description,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                tambahKeKeranjang(product);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Tambah ke Keranjang',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 140,
      color: Colors.grey[100],
      child: const Center(
        child: Icon(LucideIcons.package, size: 48, color: Colors.grey),
      ),
    );
  }

  void _tampilkanKeranjang(BuildContext context) {
    _unfocusSearch(); // tutup keyboard sebelum buka modal
    final rootContext = context;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          void hapusItem(int index) {
            setModalState(() => cart.removeAt(index));
            setState(() {});
            CartStorage.saveCart(cart); // simpan setelah hapus
          }

          double total = cart.fold(0.0, (sum, p) => sum + p.price);

          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollController) => Column(
              children: [
                const SizedBox(height: 16),
                const Text('Keranjang Belanja',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text('Keranjang masih kosong'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            final item = cart[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: item.image.isNotEmpty
                                    ? Image.network(
                                        item.image,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _miniPlaceholder(),
                                      )
                                    : _miniPlaceholder(),
                              ),
                              title: Text(item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: Text(formatRupiah(item.price),
                                  style: const TextStyle(
                                      color: Colors.blueAccent)),
                              trailing: IconButton(
                                icon: const Icon(LucideIcons.trash2,
                                    size: 18, color: Colors.red),
                                onPressed: () => hapusItem(index),
                              ),
                            );
                          },
                        ),
                ),
                if (cart.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontSize: 18)),
                        Text(formatRupiah(total),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: ElevatedButton(
                      onPressed: () {
                        final snapshot = List<Product>.from(cart);
                        final totalSnapshot = total;
                        Navigator.pop(context);
                        _tampilkanRingkasan(
                            rootContext, snapshot, totalSnapshot);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Checkout',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _miniPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      color: Colors.grey[100],
      child:
          const Icon(LucideIcons.package, size: 20, color: Colors.grey),
    );
  }

  void _tampilkanRingkasan(
      BuildContext context, List<Product> snapshot, double totalBersih) {
    final Map<String, int> jumlah = {};
    final Map<String, Product> produkMap = {};
    for (final p in snapshot) {
      jumlah[p.id] = (jumlah[p.id] ?? 0) + 1;
      produkMap[p.id] = p;
    }
    final double ongkir = 36780;
    final double total = totalBersih + ongkir;
    final rootContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ringkasan Pesanan',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Icon(Icons.close, color: Colors.grey[500]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...jumlah.entries.map((e) {
              final p = produkMap[e.key]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${e.value}x ${p.name}',
                        style: const TextStyle(fontSize: 14)),
                    Text(formatRupiah(p.price * e.value),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            _RingkasanInfoRow(
              icon: Icons.location_on_outlined,
              label: 'ALAMAT PENGIRIMAN',
              value: 'Jl. Pemuda Kaffa No. 9, Bangkalan',
            ),
            const SizedBox(height: 12),
            _RingkasanInfoRow(
              icon: Icons.credit_card_outlined,
              label: 'METODE PEMBAYARAN',
              value: 'Bank Mandiri - 873298610372',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _HargaRow(
                      label: 'Subtotal',
                      nilai: formatRupiah(totalBersih)),
                  const SizedBox(height: 8),
                  _HargaRow(
                      label: 'Biaya Pengiriman',
                      nilai: formatRupiah(ongkir)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      Text(formatRupiah(total),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => cart.clear());
                  CartStorage.clearCart(); // hapus dari SharedPreferences
                  _tampilkanSukses(rootContext);
                },
                icon: const Icon(Icons.shield_outlined, size: 18),
                label: const Text('Bayar Sekarang',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'TRANSAKSI AMAN & TERENKRIPSI',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tampilkanSukses(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.checkCircle2,
                size: 80, color: Colors.blueAccent),
            const SizedBox(height: 24),
            const Text('Pesanan Dikonfirmasi!',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Produk Anda akan segera disiapkan oleh penjual!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali Belanja'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget Helper ────────────────────────────────────────────────────────────

class _RingkasanInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _RingkasanInfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blueAccent, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}

class _HargaRow extends StatelessWidget {
  final String label;
  final String nilai;
  const _HargaRow({required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(nilai, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

// ─── Product Card (StatelessWidget) ──────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: product.image.isNotEmpty
                  ? Image.network(
                      product.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  formatRupiah(product.price),
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 36),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Tambah',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),P
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[100],
      child: const Center(
        child: Icon(LucideIcons.package, size: 40, color: Colors.grey),
      ),
    );
  }
}