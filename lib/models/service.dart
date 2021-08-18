import 'package:hive/hive.dart';

// part 'service.g.dart';

@HiveType(typeId: 2)
class Service {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? url;
  @HiveField(3)
  String? username;
  @HiveField(4)
  bool? isConnected;
}
