class UserModel {
  final String login;
  final int id;
  final String avatarUrl;
  final String? name;
  final String? company;
  final String? blog;
  final String? location;
  final String? email;
  final String? bio;
  final int publicRepos;
  final int publicGists;
  final int followers;
  final int following;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.login,
    required this.id,
    required this.avatarUrl,
    this.name,
    this.company,
    this.blog,
    this.location,
    this.email,
    this.bio,
    required this.publicRepos,
    required this.publicGists,
    required this.followers,
    required this.following,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      login: json['login'] ?? '',
      id: json['id'] ?? 0,
      avatarUrl: json['avatar_url'] ?? '',
      name: json['name'],
      company: json['company'],
      blog: json['blog'],
      location: json['location'],
      email: json['email'],
      bio: json['bio'],
      publicRepos: json['public_repos'] ?? 0,
      publicGists: json['public_gists'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'id': id,
      'avatar_url': avatarUrl,
      'name': name,
      'company': company,
      'blog': blog,
      'location': location,
      'email': email,
      'bio': bio,
      'public_repos': publicRepos,
      'public_gists': publicGists,
      'followers': followers,
      'following': following,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? login,
    int? id,
    String? avatarUrl,
    String? name,
    String? company,
    String? blog,
    String? location,
    String? email,
    String? bio,
    int? publicRepos,
    int? publicGists,
    int? followers,
    int? following,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      login: login ?? this.login,
      id: id ?? this.id,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      name: name ?? this.name,
      company: company ?? this.company,
      blog: blog ?? this.blog,
      location: location ?? this.location,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      publicRepos: publicRepos ?? this.publicRepos,
      publicGists: publicGists ?? this.publicGists,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}