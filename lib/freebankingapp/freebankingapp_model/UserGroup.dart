import 'dart:convert';

// POJO model for the API response
class UserGroup {
  List<Group> groups;

  UserGroup({required this.groups});

  // From JSON
  factory UserGroup.fromJson(Map<String, dynamic> json) {
    return UserGroup(
      groups: (json['groups'] as List)
          .map((groupJson) => Group.fromJson(groupJson))
          .toList(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'groups': groups.map((group) => group.toJson()).toList(),
    };
  }
}

class Group {
  String idGroup;
  String title;
  String dashboard;
  String rules;
  String token;
  String createdAt;
  String updatedAt;

  Group({
    required this.idGroup,
    required this.title,
    required this.dashboard,
    required this.rules,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
  });

  // From JSON
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      idGroup: json['id_group'],
      title: json['title'],
      dashboard: json['dashboard'],
      // Decode HTML entities in the 'rules' field
      rules: _decodeHtml(json['rules']),
      token: json['token'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id_group': idGroup,
      'title': title,
      'dashboard': dashboard,
      'rules': rules,
      'token': token,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper function to decode HTML entities
  static String _decodeHtml(String html) {
    return html.replaceAll('&quot;', '"');
  }
}
