# Update: Integrasi Cart Icon di Shop Detail Page

## Perubahan yang Dilakukan

### 1. **Shop Detail Page** (`lib/features/shop/presentation/pages/shop_detail_page.dart`)

#### A. Import Tambahan
- `flutter_bloc` untuk BlocBuilder dan BlocConsumer
- `CartBloc` untuk mengakses state cart
- `InitialRoutes` untuk navigasi ke cart page

#### B. AppBar - Icon Search → Cart dengan Badge
**Sebelum:**
```dart
actions: [
  IconButton(
    icon: const Icon(Icons.search, color: Colors.white),
    onPressed: () {
      // Aksi untuk pencarian
    },
  ),
],
```

**Sesudah:**
```dart
actions: [
  BlocBuilder<CartBloc, CartState>(
    builder: (context, state) {
      int itemCount = 0;
      
      if (state is CartLoaded) {
        itemCount = state.totalItems;
      }
      
      return Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              context.push(InitialRoutes.cart);
            },
          ),
          if (itemCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  itemCount > 99 ? '99+' : '$itemCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    },
  ),
],
```

**Fitur:**
- Icon search diganti menjadi shopping_cart icon
- Badge bulat oranye menampilkan jumlah item di cart
- Badge hanya muncul jika ada item di cart (itemCount > 0)
- Menampilkan "99+" jika jumlah item lebih dari 99
- Klik icon navigasi ke halaman cart

#### C. Tombol "Tambah Pembelian" di Modal
**Update pada `_buildModalActionButton`:**
- Menambahkan `BlocConsumer<CartBloc, CartState>`
- Listener untuk menampilkan SnackBar sukses/error
- Loading state saat menambahkan item
- Memanggil `AddToCartEvent` saat tombol diklik
- Modal otomatis tertutup setelah item berhasil ditambahkan

**Fitur:**
```dart
onPressed: isLoading ? null : () {
  // Tambahkan produk ke cart dengan quantity default 1
  context.read<CartBloc>().add(
    AddToCartEvent(
      productId: product.id,
      quantity: 1,
    ),
  );
},
```

**SnackBar:**
- ✅ Success: Badge hijau dengan icon check_circle
- ❌ Error: Badge merah dengan icon error_outline
- Loading: CircularProgressIndicator pada tombol

### 2. **App Router** (`lib/routes/app_router.dart`)

**Perubahan:**
```dart
GoRoute(
  path: InitialRoutes.shopDetail,
  name: InitialRoutes.shopDetail,
  builder: (context, state) {
    final shop = state.extra as ShopEntity;
    return BlocProvider(
      create: (context) => sl<CartBloc>()..add(const GetMyCartEvent()),
      child: ShopDetailPage(shop: shop),
    );
  },
),
```

**Tujuan:**
- Wrap ShopDetailPage dengan BlocProvider
- Otomatis load data cart saat halaman dibuka
- Memastikan CartBloc tersedia di seluruh widget tree ShopDetailPage

## Flow Penggunaan

1. **User membuka Shop Detail Page**
   - CartBloc otomatis di-create dan load data cart
   - Badge di cart icon menampilkan jumlah item (jika ada)

2. **User klik produk → Modal Detail terbuka**
   - Menampilkan gambar, nama, harga, rating produk
   - Tombol "Tambah Pembelian" di bagian bawah

3. **User klik "Tambah Pembelian"**
   - Tombol berubah menjadi loading indicator
   - API dipanggil untuk menambah item ke cart (quantity: 1)
   - Jika sukses:
     - SnackBar hijau muncul dengan pesan sukses
     - Modal tertutup otomatis
     - Badge di cart icon ter-update dengan jumlah baru
   - Jika error:
     - SnackBar merah muncul dengan pesan error
     - Modal tetap terbuka
     - User bisa coba lagi

4. **User klik Cart Icon**
   - Navigasi ke halaman Cart (`/cart`)
   - Menampilkan semua item yang ada di keranjang

## UI/UX Improvements

### Cart Icon Badge
- **Posisi**: Top-right corner dari icon
- **Warna**: Orange dengan border putih
- **Font**: Bold, ukuran 10, warna putih
- **Shape**: Lingkaran dengan min width/height 18px
- **Conditional**: Hanya muncul jika ada item

### SnackBar Notifications
- **Floating**: Tidak fullwidth, ada margin dari edge
- **Rounded**: BorderRadius 10px
- **Duration**: 2 detik
- **Colors**:
  - Success: Green background
  - Error: Red background
- **Icon**: Check circle (success) atau Error outline (error)

### Loading State
- Button disabled saat loading
- Text diganti CircularProgressIndicator
- Background color berubah jadi grey
- User tidak bisa spam click button

## Testing Checklist

- [x] Cart icon muncul di AppBar
- [x] Badge menampilkan jumlah item yang benar
- [x] Badge tidak muncul saat cart kosong
- [x] Klik cart icon navigasi ke cart page
- [x] Modal detail produk bisa dibuka
- [x] Tombol "Tambah Pembelian" berfungsi
- [x] Loading state tampil saat menambah item
- [x] SnackBar sukses muncul setelah item ditambahkan
- [x] Modal tertutup otomatis setelah sukses
- [x] Badge ter-update setelah item ditambahkan
- [x] Error handling bekerja dengan baik

## Next Steps (Optional)

1. **Quantity Selector di Modal**
   - Tambahkan stepper untuk pilih quantity sebelum add to cart
   - Update API call dengan quantity yang dipilih

2. **Product Variants**
   - Jika produk punya varian (ukuran, rasa, dll)
   - Tampilkan pilihan varian di modal

3. **Quick Add Button**
   - Tambahkan tombol "+" kecil di product list item
   - Langsung add tanpa buka modal (default qty: 1)

4. **Animation**
   - Animasi badge saat jumlah berubah
   - Animasi item "terbang" ke cart icon
   - Shake animation pada cart icon setelah item ditambahkan

5. **Wishlist Integration**
   - Tombol "Simpan" di modal connect ke Favorite feature
   - Toggle favorite status
