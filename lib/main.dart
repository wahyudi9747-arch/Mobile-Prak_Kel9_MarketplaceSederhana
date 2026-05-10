import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

void main() {
  runApp(const MobilePrakApp()); // Project name: mobile_prak
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

// Helper format Rupiah
String formatRupiah(double harga) {
  final formatted = harga
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  return 'Rp $formatted';
}

// Data Model
class Product {
  final String id, name, description, category, image;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
  });
}

class MarketplaceHome extends StatefulWidget {
  const MarketplaceHome({super.key});

  @override
  State<MarketplaceHome> createState() => _MarketplaceHomeState();
}

class _MarketplaceHomeState extends State<MarketplaceHome> {
  final List<Product> products = [
    Product(
      id: '1',
      name: 'iPhone 15 Pro',
      description: 'Desain titanium dengan chip A17 Pro, kamera utama 48MP.',
      price: 14999000,
      category: 'Smartphone',
      image: 'https://down-id.img.susercontent.com/file/id-11134207-7ra0j-mdrax83jhemw05',
    ),
    Product(
      id: '2',
      name: 'MacBook Air M3',
      description: 'Tipis dan cepat dengan chip M3. Layar 13 inci, RAM 8GB, SSD 256GB.',
      price: 21999000,
      category: 'Laptop',
      image: 'https://ibox.co.id/_next/image?url=https%3A%2F%2Fcdnpro.eraspace.com%2Fmedia%2Fcatalog%2Fproduct%2Fa%2Fp%2Fapple_macbook_air_13_inci_m3_2024_space_gray_1_3_1.jpg&w=1920&q=45',
    ),
    Product(
      id: '3',
      name: 'iPad Pro 12.9"',
      description: 'Performa luar biasa dengan layar Liquid Retina XDR.',
      price: 18999000,
      category: 'Tablet',
      image: 'https://www.static-src.com/wcsstore/Indraprastha/images/catalog/full//95/MTA-55432616/apple_ipad_pro_5th_gen_12-9-inch_full01_szxq2wt1.jpg',
    ),
    Product(
      id: '4',
      name: 'Apple Watch S9',
      description: 'Lebih cerdas, lebih cerah, dan lebih tangguh dari sebelumnya.',
      price: 6999000,
      category: 'Smartwatch',
      image: 'https://ibox.co.id/_next/image?url=https%3A%2F%2Fcdnpro.eraspace.com%2Fmedia%2Fcatalog%2Fproduct%2Fa%2Fp%2Fapple_watch_series_9_41mm_gps_pink_aluminium_case_with_light_pink_sport_band_1.jpg&w=1920&q=45',
    ),
    Product(
      id: '5',
      name: 'AirPods Pro 2',
      description: 'Peredam kebisingan aktif kelas pro dan spatial audio.',
      price: 4299000,
      category: 'TWS',
      image: 'https://macstore.id/wp-content/uploads/2022/10/MQD83.jpeg',
    ),
    Product(
      id: '6',
      name: 'Sony WH-1000XM5',
      description: 'Headphone dengan noise cancelling terdepan di industri.',
      price: 5999000,
      category: 'TWS',
      image: 'https://www.sony.co.id/image/5d02da5df552836db894cead8a68f5f3?fmt=pjpeg&wid=330&bgcolor=FFFFFF&bgc=FFFFFF',
    ),
  ];

  List<Product> cart = [];
  String selectedCategory = 'Semua';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Product> get filteredProducts {
    return products.where((p) {
      final matchesCategory =
          selectedCategory == 'Semua' || p.category == selectedCategory;
      final matchesSearch =
          p.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void tambahKeKeranjang(Product product) {
    setState(() => cart.add(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void hapusDariKeranjang(int index) {
    setState(() => cart.removeAt(index));
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => searchQuery = val),
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

          // Kategori
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                'Semua',
                'Smartphone',
                'Laptop',
                'Tablet',
                'Smartwatch',
                'TWS',
              ].map((cat) {
                bool isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) =>
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

          // Grid Produk
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("Produk tidak ditemukan"))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
          ),
        ],
      ),
    );
  }

  void _tampilkanDetailProduk(BuildContext context, Product product) {
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
              child: Image.network(
                product.image,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.category.toUpperCase(),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              formatRupiah(product.price),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Deskripsi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              product.description,
              style: const TextStyle(color: Colors.grey),
            ),
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
              child: const Text(
                'Tambah ke Keranjang',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _tampilkanKeranjang(BuildContext context) {
    // FIX: simpan rootContext (Scaffold) sebelum masuk modal
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
                const Text(
                  'Keranjang Belanja',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: cart.isEmpty
                      ? const Center(child: Text("Keranjang masih kosong"))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: cart.length,
                          itemBuilder: (context, index) => ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                cart[index].image,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              cart[index].name,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              formatRupiah(cart[index].price),
                              style: const TextStyle(color: Colors.blueAccent),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                LucideIcons.trash2,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: () => hapusItem(index),
                            ),
                          ),
                        ),
                ),
                if (cart.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18)),
                        Text(
                          formatRupiah(total),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: ElevatedButton(
                      onPressed: () {
                        // Snapshot cart sebelum modal ditutup
                        final snapshot = List<Product>.from(cart);
                        final totalSnapshot = total;
                        Navigator.pop(context);
                        _tampilkanRingkasan(rootContext, snapshot, totalSnapshot);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
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
    final double subtotal = totalBersih;
    final double ongkir = 36780;
    final double total = subtotal + ongkir;

    // FIX: simpan rootContext sebelum masuk modal ringkasan
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
                const Text(
                  'Ringkasan Pesanan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                        style: const TextStyle(fontWeight: FontWeight.w600)),
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
                  _HargaRow(label: 'Subtotal', nilai: formatRupiah(subtotal)),
                  const SizedBox(height: 8),
                  _HargaRow(
                      label: 'Biaya Pengiriman', nilai: formatRupiah(ongkir)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        formatRupiah(total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
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
                  // 1. Tutup modal ringkasan
                  Navigator.pop(ctx);
                  // 2. Kosongkan keranjang
                  setState(() => cart.clear());
                  // 3. Tampilkan sukses pakai rootContext
                  _tampilkanSukses(rootContext);
                },
                icon: const Icon(Icons.shield_outlined, size: 18),
                label: const Text(
                  'Bayar Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
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
            const Text(
              'Pesanan Dikonfirmasi!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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

// ── Widget helper Ringkasan ────────────────────────────────────────────────
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
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(nilai, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

// ── Product Card ───────────────────────────────────────────────────────────
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
              child: Image.network(
                product.image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
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
                  child: const Text('Tambah', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}