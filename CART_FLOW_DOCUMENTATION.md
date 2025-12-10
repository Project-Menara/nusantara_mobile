# Cart Integration Flow - Product to Cart

## 🔄 Complete Flow: Menambah Product ke Cart

### 1. **User Action: Klik Tombol "Tambah Pembelian"**
Location: `ShopDetailPage` → Modal Product Detail

```dart
// Saat user klik tombol di modal
context.read<CartBloc>().add(
  AddToCartEvent(
    productId: product.id,  // ID produk yang dipilih
    quantity: 1,            // Default quantity = 1
  ),
);
```

---

### 2. **CartBloc Processing** 
Location: `lib/features/cart/presentation/bloc/cart/cart_bloc.dart`

#### Step 2.1: Emit Loading State
```dart
emit(CartActionLoading(items: currentItems, actionType: 'add'));
```
- UI menampilkan loading indicator pada tombol
- Tombol disabled untuk prevent double-click

#### Step 2.2: POST ke API - Add to Cart
```dart
final result = await addToCartUseCase(
  productId: event.productId,
  quantity: event.quantity,
);
```

**API Call:**
- **Endpoint:** `POST /customer/add-cart-item`
- **Headers:** 
  - `Content-Type: application/json`
  - `Authorization: Bearer {token}`
- **Body:**
  ```json
  {
    "product_id": "uuid-product-123",
    "quantity": 1
  }
  ```
- **Response Success (200):**
  ```json
  {
    "message": "Product added to cart successfully"
  }
  ```

#### Step 2.3: GET Cart Data (Auto Refresh)
```dart
// Setelah POST berhasil, langsung GET data terbaru
final cartResult = await getMyCartUseCase();
```

**API Call:**
- **Endpoint:** `GET /customer/my-cart`
- **Headers:** 
  - `Authorization: Bearer {token}`
- **Response Success (200):**
  ```json
  {
    "data": [
      {
        "id": "cart-item-id",
        "product_id": "uuid-product-123",
        "product_name": "Double Cheese",
        "product_image": "https://...",
        "price": 46000,
        "quantity": 1,
        "unit": "pcs",
        "total_price": 46000,
        "shop_id": "shop-123",
        "shop_name": "Bolu Menara Tembung",
        "created_at": "2025-11-03T10:00:00Z",
        "updated_at": "2025-11-03T10:00:00Z"
      }
    ]
  }
  ```

#### Step 2.4: Calculate Totals
```dart
final totalItems = items.fold<int>(
  0,
  (sum, item) => sum + item.quantity,
);

final totalPrice = items.fold<int>(
  0,
  (sum, item) => sum + item.totalPrice,
);
```

#### Step 2.5: Emit Success States
```dart
emit(CartActionSuccess(message: message, items: items));
emit(CartLoaded(
  items: items,
  totalItems: totalItems,
  totalPrice: totalPrice,
));
```

---

### 3. **UI Updates**

#### A. Modal Bottom Sheet
Location: `ShopDetailPage` → `_buildModalActionButton`

**Listener menangkap state:**
```dart
BlocConsumer<CartBloc, CartState>(
  listener: (context, state) {
    if (state is CartActionSuccess) {
      // ✅ Tampilkan SnackBar hijau
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.green,
        ),
      );
      // ✅ Tutup modal otomatis
      Navigator.pop(context);
    } else if (state is CartError) {
      // ❌ Tampilkan SnackBar merah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
)
```

**Result:**
- ✅ Success: Green SnackBar + Modal close
- ❌ Error: Red SnackBar + Modal tetap buka

#### B. Cart Icon Badge (AppBar)
Location: `ShopDetailPage` → AppBar actions

**BlocBuilder mendengarkan state:**
```dart
BlocBuilder<CartBloc, CartState>(
  builder: (context, state) {
    int itemCount = 0;
    
    if (state is CartLoaded) {
      itemCount = state.totalItems;
    }
    
    return Stack(
      children: [
        IconButton(icon: Icon(Icons.shopping_cart)),
        if (itemCount > 0)
          Positioned(
            child: Container(
              child: Text('$itemCount'),
            ),
          ),
      ],
    );
  },
)
```

**Result:**
- Badge angka ter-update otomatis
- Menampilkan total quantity semua items di cart

---

## 📊 State Flow Diagram

```
[User Click Button]
        ↓
[CartActionLoading] → Tombol loading
        ↓
[POST /add-cart-item]
        ↓
   [Success?]
    /      \
  YES      NO
   ↓        ↓
[GET /my-cart]  [CartError] → Red SnackBar
   ↓
[CartLoaded]
   ↓
[CartActionSuccess] → Green SnackBar + Close Modal
   ↓
[Badge Update] → Show new total items
```

---

## 🧪 Testing Scenario

### Scenario 1: Add Product Pertama Kali (Cart Kosong)
**Before:**
- Cart badge: Hidden (tidak ada item)
- Cart state: `CartEmpty`

**User Action:**
1. Buka ShopDetailPage
2. Klik product → Modal muncul
3. Klik "Tambah Pembelian"

**Expected Result:**
- Loading indicator muncul di tombol
- POST request terkirim
- GET request auto-refresh
- SnackBar hijau: "Product added to cart successfully"
- Modal tertutup otomatis
- Badge muncul dengan angka "1"
- State: `CartLoaded(totalItems: 1, totalPrice: 46000)`

### Scenario 2: Add Product ke Cart yang Sudah Ada Item
**Before:**
- Cart badge: "2" (sudah ada 2 items)
- Cart state: `CartLoaded(totalItems: 2, totalPrice: 100000)`

**User Action:**
1. Add product baru

**Expected Result:**
- Badge update menjadi "3"
- Total price ter-update
- State: `CartLoaded(totalItems: 3, totalPrice: 146000)`

### Scenario 3: Add Product yang Sudah Ada di Cart
**API Behavior:**
- Backend akan **update quantity** existing item (bukan create new)
- Jika product X qty 1 → add lagi → jadi qty 2

**Expected Result:**
- Total items mungkin tetap (jika hanya update qty)
- Total price bertambah
- Item di cart page quantity ter-update

### Scenario 4: Network Error
**Trigger:** Internet off / API error

**Expected Result:**
- SnackBar merah: "Network error: ..."
- Modal tetap terbuka
- Badge tidak berubah
- User bisa retry

### Scenario 5: Unauthorized (Token Expired)
**Trigger:** Token expired / invalid

**Expected Result:**
- `onTokenExpired()` callback dipanggil
- AuthBloc emit `TokenExpiredEvent`
- User di-redirect ke login page

---

## 🔍 Debug Checklist

### 1. POST Request
```bash
# Check di Flutter DevTools → Network tab
POST /customer/add-cart-item
Status: 200 OK
Body: {"product_id": "...", "quantity": 1}
Response: {"message": "Success"}
```

### 2. GET Request (Auto-triggered)
```bash
GET /customer/my-cart
Status: 200 OK
Response: {"data": [...]} # Array of cart items
```

### 3. State Transitions
```
CartLoaded → CartActionLoading → CartActionSuccess → CartLoaded (updated)
```

### 4. UI Updates
- [ ] Tombol loading saat POST
- [ ] SnackBar muncul setelah response
- [ ] Modal tertutup jika success
- [ ] Badge update dengan angka baru
- [ ] Cart page menampilkan item baru

---

## 💡 Tips & Notes

1. **Quantity Management:**
   - Default quantity = 1 saat add dari product page
   - User bisa update quantity di cart page
   - Min quantity = 1, decrement di qty 1 = delete item

2. **Error Handling:**
   - Network error → Retry available
   - Token expired → Auto redirect to login
   - Server error → Show message dari API

3. **Performance:**
   - POST + GET digabung dalam 1 flow
   - Tidak perlu manual refresh
   - Badge real-time update

4. **Data Consistency:**
   - Single source of truth: API response
   - Local state selalu sync dengan server
   - No local cart caching (selalu fetch dari API)

---

## 🚀 Next Features (Optional)

1. **Quantity Selector di Modal**
   - User pilih qty sebelum add
   - Default: 1, Max: stock available

2. **Add to Cart Animation**
   - Item "terbang" ke cart icon
   - Haptic feedback
   - Badge pulse animation

3. **Recent Added Items**
   - Show toast dengan preview product
   - Quick access ke cart page

4. **Cart Preview Modal**
   - Show mini cart di bottom sheet
   - Langsung checkout dari preview

5. **Offline Support**
   - Queue add actions saat offline
   - Auto-sync saat online kembali
