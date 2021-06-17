class NotAuthenticatedException implements Exception {
  final String message;

  NotAuthenticatedException(this.message);

  @override
  String toString() {
    return this.message;
  }
}
