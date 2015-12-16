# Dart Workshop - Server-side

Server-side of a simple application demo for Dart workshop organised at the
Faculty of Applied Sciences of the University of West Bohemia in Pilsen, Czech Republic.

Based on the same app prepared by Martin Bydzovsky for Node.js workshop at the same
 organisation.
 
During the workshop, you are going to write a simple Dart application using web service
API, Redstone micro-framework and MongoDb database.

Simple html(jade) + javascript UI is provided for easier testing.

## Steps

Follow these steps to recreate the workshop app stored in this repository.

### Project Initialization

        cd <workdir>
        mkdir bin
        mkdir lib
        touch pubspec.yaml

The `pubspec.yaml` file contains project meta-data as well as dependency specifications.

        name: 'server'
        version: 0.0.1
        description: A web server built using the shelf package.
        author: MyName <danek.ja@gmail.com>
        homepage: http://www.myhomepage.org
        
        environment:
          sdk: '>=1.0.0 <2.0.0'
        
        dependencies:
          redstone: '^0.6.1'
          shelf: '>=0.6.0 <0.7.0'

* [Redstone](https://github.com/redstone-dart/redstone) is an annotation driven web server micro-framework.
* [Shelf](https://github.com/dart-lang/shelf) is web server middleware.

To download the dependencies, run:

        pub get

### Start Script

Let's create a start script

        touch bin/server.dart

with the following content:

        import "package:redstone/redstone.dart" as app;
        
        
        @app.Route("/")
        helloWorld() => "Hello, World!";
        
        void main(List<String> args) {
          app.setupConsoleLog();
          app.start();
        }

after running the application and accessing [http://localhost:8080/](http://localhost:8080/) you should 
see the "Hello, World!" message.

### Application Structure

         _ bin
         _ lib
          |_ src

* *bin* contains tools, executable scripts
* *lib* contains library files usable by the scripts or other applications
* *lib/src* contains implementation files which are not to by used by other applications

Users are allowed to create any sub-directory structure within this basic layout.

### User API

Now our goal is to implement API for adding, listing and removing users. Initially, we need 
User representation within our app:

        mkdir lib/model
        touch lib/model/user.dart

and inside the `user.dart` file:

        library dartws.user.model;
        
        ///Entity representing application's user.
        class User {
        
          ///Primary key
          String id;
        
          ///username
          String username;
        
          ///User's name
          String name;
        
          ///User's email
          String email;
        
          /// Empty constructor
          User();
        
          /// Constructor initializing all fields.
          User.full(this.id, this.username, this.name, this.email);
        
          /// Constructor for initialization of User object from JSON document.
          User.fromJson(Map map) : this.full(map["id"], map['username'], map['name'],map['email']);
        
        }

for easy (de)serialization and validation we are going to use Redstone's mapping module:

1. Add into the pubspec.yaml, under "dependencies":

          redstone_mapper: any
        
        transformers:
        - redstone_mapper

2. In terminal, fetch new dependencies:

        pub get

2. Add import to `lib/model/user.dart` file:

        import 'package:redstone_mapper/mapper.dart';

2. Make the class `User` extend `Schema:

        class User extends Schema {

2. Annotate all serializable fields with one of the following annotations:

    * @Field() - mandatory, marks serializable field
    * @NotEmpty() - optional, marks required fields

Now we are going to implement persistence of users into the MongoDb database:

1. Add into the pubspec.yaml, under dependencies:

        mongo_dart: any
        redstone_mapper_mongo: any

2. In terminal, fetch new dependencies:

        pub get

2. Add import to `lib/model/user.dart` file:

        import 'package:redstone_mapper_mongo/metadata.dart';

2. Annotate id field as primary key, it can replace the NotEmpty and Field annotations:

        @Id()

2. Create User DAO:

        mkdir lib/dao
        touch lib/dao/user.dart

3. Provide implementation

        library dartws.user.dao;
        
        import 'package:redstone_mapper_mongo/service.dart';
        import 'package:mongo_dart/mongo_dart.dart';
        import 'dart:async';
        
        import '../model/user.dart';

        ///Implementation of UserDao interface on top of MongoDB database
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

Finally, the application logic for registration and exposure of the web service;
this should go into a `lib/service/user.dart` file:

        library dartws.user.service;
        
        import "dart:async";
        import "package:redstone/redstone.dart" as app;
        import 'package:redstone_mapper/plugin.dart' as map;
        import "../model/user.dart";
        import "../dao/user.dart";
        
        @app.Group("/users") // group all inner endpoints under /users resource
        class UserService {
        
          UserDao _userDao;
        
          UserService(this._userDao);
        
          //the parameter annotation @map.Decode(from: const [app.FORM]) tells Redmine
          //to automatically fill the user parameter with request data in FORM mimetype
          @map.Encode() //tell redstone to automatically encode response User into JSON
          @app.DefaultRoute(methods: const [app.POST]) //use same route path as parent group (/users)
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
        
          //this route handles /users/:id/ delete request
          @app.Route("/:id", methods: const [app.DELETE])
          delete(String id) {
            _userDao.delete(id);
          }
        }

### Wiring it Together (DI)

At this moment we have our user service implemented, however the server doesn't know about
it yet. Redstone needs the service files imported in it's start script in order to load
the annotated interfaces.

1. Add the following into the `bin/server.dart`:

        //though unsused directly, the import is required for Redstone to discover registered
        //routes
        import '../lib/service/user.dart';

2. Register instances for DI, add the following into `bin/server.dart`

        import 'package:di/di.dart' as di;

        ///Register components for dependency injection.
        _di() {
          app.addModule(new di.Module()
                                ..bind(UserDao));
        }
        
    and call the method before `app.start();` in the `main` method.

3. Setup and register MongoDb driver in `bin/server.dart`

        import 'package:redstone_mapper/plugin.dart' as mapper;
        import 'package:redstone_mapper_mongo/manager.dart' as mongo;
        
        
        ///Create db connection pool, open for the whole life of the application
        /// replace the <url> with proper connection string
        _setupDb() {
          var dbManager = new mongo.MongoDbManager("mongodb://localhost/dbname", poolSize: 3);
          app.addPlugin(mapper.getMapperPlugin(dbManager));
        }

    and call the method before `app.start();` in the `main` method.

### UI using Jade templating

Now we have a working server-side of our application. Time to throw in basic user interface.
We are going to use [Jade](http://jade-lang.com/) template created by M. Bydzovsky for the
previous Node.js workshop.

First let's create the folder structure. In Dart, static web files (such as html, js, css)
belong to the `web` folder in the project root (i.e. on the same level as `lib` and `bin` folders).

        cd <project_root>
        mkdir web
        mkdir web/jade
        mkdir web/js

Now a jade template with simple view of our users, selected user's details and input form:

        touch web/jade/main.jade

And the contents is:

    doctype html
    html
        head
            meta(charset='utf-8')
            title Dart appka
            link(rel="stylesheet", href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css", integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7", crossorigin="anonymous")
            link(rel="stylesheet", href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css", integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r", crossorigin="anonymous")
            script(src='/js/frontend.js')
        body
            h1 Dart workshop
            p Simple dart + redstone + jade + bootstrap + mongo application
            div#wrapper
    
                div#userInfo.col-md-3
                    h2 User Details
                    table.table
                        tr
                            td.col-md-1
                                strong Username:
                            td#userInfoUsername
                        tr
                            td.col-md-1
                                strong Email:
                            td#userInfoEmail
                        tr
                            td.col-md-1
                                strong Full Name:
                            td#userInfoFullname
    
    
    
                div#userList.col-md-4
                    h2 User List
                    table.table.table-striped.table-bordered
                        thead
                            th UserName
                            th.col-md-3 Action
                        tbody
    
                div#addUser.col-md-3
                    h2 Add New User
                    p
                        input#inputUserName.form-control(type='text', placeholder='Username')
                    p
                        input#inputUserEmail.form-control(type='text', placeholder='Email')
                    p
                        input#inputUserFullname.form-control(type='text', placeholder='Full Name')
                    p
                        button#btnAddUser.btn.btn-success Add User
    
    
            script(src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js")
            script(src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js", integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS", crossorigin="anonymous")

Front-end logic written in javascript (also by M. Bydzovsky):

        mkdir web/js/frontend.js

with content:

        /**
         * @author Martin Bydzovsky
         */
        
        // Jednoduchá hashmapa pro uchování aktuálně staženého senzmau uživatelů
        var userListData = {}
        
        // všechny operace nad DOMem musí být v jquery navěšeny na DOM-ready event
        $(document).ready(function() {
            //stáhneme a vyplníme tabulku uživatelů
            populateTable()
        
            //navěsíme události na jednotlivé odkazy
            // obyčejný elm.click(function(){}) nestačí, protože by se nezaregistroval pro
            // elementy vytvořené později javascriptem
        
            $("#userList").on("click", ".linkshowuser", showUserInfo)
            $("#btnAddUser").on("click", addUser)
            $("#userList").on("click", ".linkdeleteuser", deleteUser)
        
        
        })
        
        // funckce volaná po každé úspěčné operaci (add/delete). Stáhne ze serveru všechny uživatele
        // a vyplní je do HTML tabulky
        function populateTable() {
        
            // připravíme si html content pro tabulku
            var tableContent = ''
        
            // uděláme GET request na naše API
            $.getJSON( '/users', function( data ) {
                // není zde var = upravujeme globální proměnnou definovanou na začátku skriptu
                userListData = {}
        
                // projdeme odpověď ze serveru a pro každého uživatele vytvoříme řádek tabulky
                for (var i=0; i<data.length; i++) {
        
                    // class linkshowuser a linkdeleteuser = na ty navěsíme onclick
                    // Do rel atributu si přidáme ID uživatele
                    // budeme ho podle toho pak hledat v userListData a při mazání
                    tableContent += "<tr>"
                    tableContent += '<td><a href="#" class="linkshowuser" rel="' + data[i]._id + '">' + data[i].username + '</a></td>'
                    tableContent += '<td><a href="#" class="btn btn-danger btn-xs linkdeleteuser" rel="' + data[i].id + '">&times; delete</a></td>'
                    tableContent += "</tr>"
        
                    //uživatele si uložíme do lokální proměnné (cache)
                    userListData[data[i]._id] = data[i]
                }
                // upravíme body tabulky = nahradíme původní obsah aktuálně staženými uživateli
                $("#userList table tbody").html(tableContent)
            })
        }
        
        
        // Obsluha události kliknutí na jméno uživatele - zobrazíme detaily do levé tabulky
        function showUserInfo(event) {
        
            // zastavíme defaultní akci (a href=# by skočilo na HTML začátek stránky)
            event.preventDefault()
        
            // z rel atribudu linku si vytáhneme id uživatele
            var id = $(this).attr('rel')
        
            // najdeme ho v lokální cachi
            var user = userListData[id]
        
            // vyplníme jednotlivé informace u tomto uživateli
            $("#userInfoUsername").text(user.username)
            $("#userInfoFullname").text(user.name)
            $("#userInfoEmail").text(user.email)
        }
        
        // Obsluha události new user
        function addUser(event) {
        
            // připravíme si objekt nového uživatele který pošleme na server
            var newUser = {
                username: $("#inputUserName").val(),
                email: $("#inputUserEmail").val(),
                name: $("#inputUserFullname").val(),
            }
        
            //zkontrolujeme že jsou všechna pole vyplněna
            for (var prop in newUser)
                if(!newUser[prop])
                //return ukončí celou funkci..
                    return alert("Please fill in all fields")
        
            //uděláme AJAXem HTTP POST na server s daty nového uživatele
            $.ajax({
                type: "POST",
                data: newUser,
                url: "/users"
            }).done(function( response ) {
                if (response.error)
                    return alert("Error from server: " + response.error)
        
                //vyprázdníme všechna input pole
                $("#addUser input").val("")
        
                //znovy vyplníme HTML tabulku s uživateli
                populateTable()
            })
        }
        
        // Obsluha události delete user
        function deleteUser(event) {
        
            // zastavíme defaultní akci (a href=# by skočilo na HTML začátek stránky)
            event.preventDefault()
        
            // opravdu chceme mazat? Jednoduchý JS popup
            var confirmation = confirm("Are you sure you want to delete this user?")
        
            if (confirmation === false) {
                //return ukončí volání delého deleteUser
                return false
            }
        
            var userId = $(this).attr("rel")
            //uděláme AJAXem HTTP DELETE požadavek na server
            $.ajax({
                type: "DELETE",
                url: "/users/" + userId
            }).done(function( response ) {
                if (response.error)
                    return alert("Error: " + response.error)
        
                // aktualizujeme tabulku po úspěšném smazání
                populateTable()
        
            })
        }

To tell our server to serve the static files (*frontend.js*), add this to the `bin/server.dart`:

        //serve static files from the web folder
        _serveStatic() {
          app.setShelfHandler(createStaticHandler("../web",
              serveFilesOutsidePath: true));
        }

and call it from the main function. The `main` function should currently look similar to this:

        void main(List<String> args) {
          _setupDb();
          _di();
          _serveStatic();
        
          app.setupConsoleLog();
          app.start();
        }

### Finished

Re-run the application and enjoy!
