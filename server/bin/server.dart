import 'dart:async';
import "package:jaded/jaded.dart" as jade;
import "package:redstone/redstone.dart" as app;
import 'package:di/di.dart' as di;
import 'package:redstone_mapper/plugin.dart' as mapper;
import 'package:redstone_mapper_mongo/manager.dart' as mongo;
import 'package:shelf_static/shelf_static.dart';

import '../lib/dao/user.dart';
//though unsused directly, the import is required for Redmine to discover registered
//routes
import '../lib/service/user.dart';

@app.Route("/", responseType: "text/html")
helloWorld() {
  return jade.renderFile("../web/jade/main.jade");
}

///Create db connection pool, open for the whole life of the application
/// replace the localhost connection string with a proper one
_setupDb() {
  var dbManager = new mongo.MongoDbManager("mongodb://localhost/dbname", poolSize: 3);
  app.addPlugin(mapper.getMapperPlugin(dbManager));
}

///Register components for dependency injection.
_di() {
  app.addModule(new di.Module()
                        ..bind(UserDao));
}

//serve static files from the web folder
_serveStatic() {
  app.setShelfHandler(createStaticHandler("../web",
      serveFilesOutsidePath: true));
}

void main(List<String> args) {
  _setupDb();
  _di();
  _serveStatic();

  app.setupConsoleLog();
  app.start();
}

