# Cart Feature Implementation

## Overview
Fitur Cart telah berhasil diimplementasikan dengan mengikuti Clean Architecture pattern dan menggunakan BLoC untuk state management.

## API Endpoints
1. **GET** `/customer/my-cart` - Mendapatkan keranjang belanja user
2. **POST** `/customer/add-cart-item` - Menambah item ke keranjang
   - Body: `{ "product_id": "string", "quantity": number }`
3. **DELETE** `/customer/delete-cart-item/:product_id` - Menghapus item dari keranjang

## Struktur File

### Domain Layer
- `lib/features/cart/domain/entities/cart_entity.dart` - Entity untuk cart item
- `lib/features/cart/domain/repositories/cart_repository.dart` - Interface repository
- `lib/features/cart/domain/usecases/get_my_cart_usecase.dart` - Use case untuk get cart
- `lib/features/cart/domain/usecases/add_to_cart_usecase.dart` - Use case untuk add item
- `lib/features/cart/domain/usecases/delete_cart_item_usecase.dart` - Use case untuk delete item

### Data Layer
- `lib/features/cart/data/models/cart_model.dart` - Model dengan JSON serialization
- `lib/features/cart/data/datasources/cart_remote_datasource.dart` - Interface datasource
- `lib/features/cart/data/datasources/cart_remote_datasource_impl.dart` - Implementasi datasource
- `lib/features/cart/data/repositories/cart_repository_impl.dart` - Implementasi repository

### Presentation Layer
- `lib/features/cart/presentation/bloc/cart/cart_event.dart` - BLoC events
- `lib/features/cart/presentation/bloc/cart/cart_state.dart` - BLoC states
- `lib/features/cart/presentation/bloc/cart/cart_bloc.dart` - BLoC logic
- `lib/features/cart/presentation/pages/cart_page.dart` - UI halaman cart

## Fitur UI
1. **Daftar Item Cart** - Menampilkan semua item yang dikelompokkan berdasarkan toko
2. **Update Quantity** - Tombol increment/decrement untuk mengubah jumlah item
3. **Hapus Item** - Tombol delete dengan konfirmasi dialog
4. **Total Price** - Menampilkan total harga semua item
5. **Empty State** - Tampilan ketika cart kosong
6. **Error Handling** - Pesan error dengan tombol retry
7. **Loading States** - Loading indicator untuk setiap aksi
8. **Pull to Refresh** - Refresh data cart dengan gesture pull down
9. **Checkout Button** - Tombol untuk melanjutkan ke checkout (siap diimplementasikan)

## State Management (BLoC)

### Events
- `GetMyCartEvent` - Mengambil data cart
- `AddToCartEvent` - Menambah item ke cart
- `DeleteCartItemEvent` - Menghapus item dari cart
- `UpdateCartItemQuantityEvent` - Update jumlah item (delete + add dengan quantity baru)

### States
- `CartInitial` - State awal
- `CartLoading` - Loading saat fetch data
- `CartLoaded` - Cart berhasil dimuat dengan data items
- `CartEmpty` - Cart kosong
- `CartError` - Error dengan pesan error
- `CartActionLoading` - Loading saat melakukan aksi (add/delete/update)
- `CartActionSuccess` - Aksi berhasil dengan pesan sukses

## Dependency Injection
Semua dependencies telah diregistrasi di `lib/core/injection_container.dart`:
- CartBloc (factory)
- Use cases (lazy singleton)
- Repository (lazy singleton)
- Remote datasource (lazy singleton dengan token expired callback)

## Routing
Route `/cart` telah ditambahkan di:
- `lib/routes/initial_routes.dart` - Konstanta route
- `lib/routes/app_router.dart` - GoRouter configuration

## Special Features
1. **Token Expiration Handling** - Datasource memiliki callback untuk handle token expired (401 response)
2. **Empty Cart (404 Handling)** - Response 404 diperlakukan sebagai cart kosong, bukan error
3. **Network Awareness** - Cek koneksi internet sebelum memanggil API
4. **Grouped by Shop** - Items dikelompokkan berdasarkan toko untuk UX yang lebih baik

## Cara Menggunakan

### Navigasi ke Cart Page
```dart
context.go(InitialRoutes.cart);
```

### Menambah Item ke Cart (dari halaman lain)
```dart
context.read<CartBloc>().add(AddToCartEvent(
  productId: 'product-id-123',
  quantity: 2,
));
```

## Testing
Untuk menjalankan test (belum diimplementasikan):
```bash
flutter test test/features/cart/
```

## Build Status
✅ **Semua compile errors telah diperbaiki**
- Tidak ada error blocking
- Hanya info/warning style suggestions yang tersisa (tidak mengganggu build)

## Next Steps
1. Implementasi Checkout feature yang menggunakan data dari CartBloc
2. Tambahkan unit tests untuk domain layer
3. Tambahkan widget tests untuk UI
4. Implementasi persistent cart (simpan ke local database jika diperlukan)
5. Tambahkan animasi untuk transisi state

## Notes
- Cart data di-refresh otomatis setelah setiap aksi (add/delete/update)
- Quantity minimum adalah 1 (tombol decrement disable pada quantity 1, dan muncul tombol delete)
- Authorization menggunakan Bearer token dari LocalDatasource
- Error messages dalam bahasa Inggris (bisa disesuaikan dengan i18n jika diperlukan)
