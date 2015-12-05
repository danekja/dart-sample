library dartws.user.model;

import 'package:redstone_mapper/mapper.dart';
import 'package:redstone_mapper_mongo/metadata.dart';

///Entity representing application's user.
class User extends Schema {

  ///Primary key
  @Id()
  String id;

  ///Unique username
  @Field()
  @NotEmpty()
  String username;

  ///User's name
  @Field()
  String name;

  ///User's email
  @Field()
  @NotEmpty()
  String email;

  /// Empty constructor
  User();

  /// Constructor initializing all fields.
  User.full(this.id, this.username, this.name, this.email);

  /// Constructor for initialization of User object from JSON document.
  User.fromJson(Map map) : this.full(map["id"], map['username'], map['name'],map['email']);

}