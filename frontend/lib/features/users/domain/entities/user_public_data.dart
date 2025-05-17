class UserPublicData {
  String id;
  String username;
  String? publicKey;
  bool isDeleted;

  UserPublicData({
    required this.id,
    required this.username,
    required this.publicKey,
    required this.isDeleted,
  });
}
