class GetUserPublicDataByIdRequestModel {
  final List<String> userIds;

  const GetUserPublicDataByIdRequestModel({
    required this.userIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_ids': userIds,
    };
  }
}

class GetUserPublicDataByUsernameRequestModel {
  final String username;

  const GetUserPublicDataByUsernameRequestModel({
    required this.username,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
    };
  }
}
