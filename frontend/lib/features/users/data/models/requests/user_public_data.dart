class GetUserPublicDataRequestModel {
  final List<String> userIds;

  const GetUserPublicDataRequestModel({
    required this.userIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_ids': userIds,
    };
  }
}
