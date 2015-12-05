library dartws.user.dao;

import 'package:redstone_mapper_mongo/service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:async';

import '../model/user.dart';

class UserDao extends MongoDbService<User> {
  static const COLLECTION = "users";

  /// Constructor taking db connection from Redstone
  UserDao() : super(COLLECTION);

  Future<List<User>> findAll() {
    return super.find();
  }

  Future<User> findByUsername(String username) {
    return super.findOne({"username" : username});
  }

  delete(String id) {
    var objectId = new ObjectId.fromHexString(id);
    super.remove({"_id" : objectId});
  }
}