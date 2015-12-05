import 'dart:async';
import "package:jaded/jaded.dart" as jade;
import "package:redstone/redstone.dart" as app;
import 'package:di/di.dart' as di;
import 'package:redstone_mapper/plugin.dart' as mapper;
import 'package:redstone_mapper_mongo/manager.dart' as mongo;
import 'package:shelf_static/shelf_static.dart';

import '../lib/dao/user.dart';
import '../lib/service/user.dart';

@app.Route("/", responseType: "text/html")
helloWorld() {
  return jade.renderFile("../web/jade/main.jade");
}

_setupDb() {
  var dbManager = new mongo.MongoDbManager("mongodb://localhost/dbname", poolSize: 3);
  app.addPlugin(mapper.getMapperPlugin(dbManager));
}

_di() {
  app.addModule(new di.Module()
                        ..bind(UserDao));
}

void main(List<String> args) {
  _setupDb();
  _di();

  app.setShelfHandler(createStaticHandler("../web",
      serveFilesOutsidePath: true));


  app.setupConsoleLog();
  app.start();
}

