import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 3)
class UserProfile extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  String country;

  UserProfile({required this.username, required this.country});
}
