library dartws.user.service;

import "dart:async";
import "package:redstone/redstone.dart" as app;
import 'package:redstone_mapper/plugin.dart' as map;
import "../model/user.dart";
import "../dao/user.dart";

@app.Group("/users")
class UserService {

  UserDao _userDao;

  UserService(this._userDao);

  @map.Encode()
  @app.DefaultRoute(methods: const [app.POST])
  Future<User> register(@map.Decode(from: const [app.FORM]) User user) async {
    //method validate from Redstone Mapper Schema class
    var err = user.validate();
    if(err != null) {
      print(err.invalidFields);
      return null;
    }

    if (user.id != null) {
      print("Id is not null!");
      return null;
    }

    var old = await _userDao.findByUsername(user.username);

    if(old != null) {
      print("Username already taken");
      return null;
    } else {
      return _userDao.save(user);
    }
  }

  @map.Encode()
  @app.DefaultRoute(methods: const [app.GET])
  Future<List<User>> findAll() {
    return _userDao.findAll();
  }

  @app.Route("/:id", methods: const [app.DELETE])
  delete(String id) {
    _userDao.delete(id);
  }
}