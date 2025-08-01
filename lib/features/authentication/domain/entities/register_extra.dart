class RegisterExtra {
  final String phoneNumber;
  final int ttl;
  final String? action; // Optional action to handle different flows
  RegisterExtra({required this.phoneNumber, required this.ttl, this.action});
}
