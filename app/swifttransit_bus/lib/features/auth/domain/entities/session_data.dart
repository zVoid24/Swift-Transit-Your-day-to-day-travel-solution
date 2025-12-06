class SessionData {
  final String token;
  final int routeId;
  final String busId;
  final int busCredentialId;
  final String variant;

  const SessionData({
    required this.token,
    required this.routeId,
    required this.busId,
    required this.busCredentialId,
    required this.variant,
  });
}
