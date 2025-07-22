import 'package:connectivity_plus/connectivity_plus.dart';

// Bagian 1: Kontrak (Blueprint)
// Mendefinisikan apa yang harus bisa dilakukan oleh sebuah NetworkInfo.
// Repository akan bergantung pada kelas abstrak ini, bukan pada implementasinya.
abstract class NetworkInfo {
  /// Mengecek apakah ada koneksi internet.
  /// Mengembalikan `true` jika terhubung, `false` jika tidak.
  Future<bool> get isConnected;
}

// Bagian 2: Implementasi (Pekerja Nyata)
// Kelas ini mengimplementasikan kontrak di atas menggunakan package `connectivity_plus`.
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  // Meminta instance Connectivity melalui constructor (Dependency Injection).
  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    
    // `checkConnectivity` mengembalikan List<ConnectivityResult>.
    // Jika daftar tersebut berisi `ConnectivityResult.none`, berarti tidak ada koneksi.
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }
    
    // Jika tidak ada `ConnectivityResult.none`, berarti ada koneksi aktif (WiFi, Mobile, dll).
    return true;
  }
}