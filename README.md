# Sample Dart Webapp - Dart, Redstone, Polymer

This project serves as hand-on introduction into [Dart](http://www.dartlang.org) programming language and its concepts.
The material has been created for a workshop organized at the [Faculty of Applied Sciences](http://fav.zcu.cz/en/)
 of the University of West Bohemia in Pilsen, Czech Republic.

The material is organized in the following fashion:

* key concepts of Dart language with examples - this document
* tutorial for writing simple server-side app with web service API - `server` sub-folder and its README.
* tutorial for writing a simple polymer.dart app connecting to the server created in the previous example - **TO BE DONE** 


## Licensing

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">This project</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="http://www.danekja.org" property="cc:attributionName" rel="cc:attributionURL">Jakub Danek</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

Full text of the license may be found in the attached LICENSE file.

## Elementary Dart Concepts

This section has been mainly extracted from the [Tour of the Dart Language](https://www.dartlang.org/docs/dart-up-and-running/ch02.html)
 official document.
 
* everything is an object - numbers, functions, *null*
* all objects inherit from the *Object* class
* static typing is optional
    * use `dynamic` type to specify *any*
    * use `var` to declare variable without specifying its type
* Dart has top-level functions (as well as static and instance methods)
* no accessor keywords (like private, protected, public)
    * start identifier with `_` to make it private to the library it is defined in

## Functions

Functions can be created without specifying return and parameter types:

        sayHello(name) {
          print("Hello $name");
        }

but it is a nice thing to do:

        void sayHello(String name) {
          print("Hello $name");
        }

Functions with only a single expression can be shortened:

        void sayHello(String name) => print("Hello $name");

### Optional Parameters

Functions may have optional parameters, either named - encapsulated by curly brackets `{}`.
All parameters may have default values given using `paramName: value`:

        void sayHello(String firstName, {String lastName : ""}) => print("Hello $firstName $lastName");
        
        sayHello("John");
        sayHello("John", lastName: "Doe");

or positional, encapsulated by square brackets `[]`:

        void sayHello(String firstName, {String lastName : ""}) => print("Hello $firstName $lastName");
                
        sayHello("John");
        sayHello("John", "Doe");

Named parameters are always optional, positional only if encapsulated by the square brackets.
Default value for optional parameter is null if not stated otherwise.

### Functions are First-Class Objects

Functions can be passed as a parameter to another function or be assigned to a variable.

        void sayHello(String name) => print("Hello $name");
        
        var group = ["John", "Jane"];
        group.forEach(sayHello);
        
        var hello = sayHello;
        group.forEach(hello);

### Scope

Dart is a lexically scoped language - scope of variables is determined by the layout
of the code. Scope level is defined by `code block`, i.e. portion of code encapsulated
by curly brackets `{}`. Within deeper level blocks, you still have access to classes, variables and
functions defined on the upper levels.

Together with scope comes closure - a function object with access to variables in its
lexical scope, even when invoked outside of the scope. What is going the following 
example to output?

        celebrityIDCreator (theCelebrities) {
          var i;
          var uniqueID = 100;
          for (i = 0; i < theCelebrities.length; i++) {
            theCelebrities[i]["id"] = () {
             return uniqueID + i;
            };
          }
          return theCelebrities;
        }
        
        
        
        void main(List<String> args) {
        
          var actionCelebs = [{"name":"Stallone", "id":0}, {"name":"Cruise", "id":0}, {"name":"Willis", "id":0}];
          var createIdForActionCelebs = celebrityIDCreator(actionCelebs);
          var stalloneID = createIdForActionCelebs[0];
          print(stalloneID["id"]()); // What is the output?
        
        }
        
        Source: http://javascriptissexy.com/understand-javascript-closures-with-ease

How would you fix it?

## Classes

Everything in Dart is an instance of a class. All classes inherit from `Object`.

### Constructors

**Default constructor** - unless any other constructor is defined, the class has an
 implicit default constructor - takes no arguments and invokes no-argument constructor
 of the superclass.
 
**Named constructor** - if you need multiple constructors for a class, you need to
provide named constructors (unlike Java, multiple constructor implementation using
different sets of argument is not allowed).

        class Point {
          num x;
          num y;
          
          // Syntactic sugar for setting x and y
          // before the constructor body runs.
          Point(this.x, this.y);
        
          // Named constructor
          Point.fromJson(Map json) {
            x = json['x'];
            y = json['y'];
          }
        }

**Superclass constructors & Redirecting** - if you need to specify which superclass 
constructor to use or to redirect call to another class constructor, you use the
following syntax:

        class Person {
          String name;
        
          Person(this.name) {
            print('in Person');
            print(name);
          }
        
          //no body allowed when delegating to another constructor
          Person.fromJson(Map data) : this(data["name"]);
        
          Person.init(Map data) : name = data["name"] {
            print('in Person Init');
            print(name);
          }
        }
        
        class Employee extends Person {
          // Person does not have a default constructor;
          // you must call super.fromJson(data).
          Employee.fromJson(Map data) : super.fromJson(data) {
            print('in Employee');
          }
        }


### Attributes

Dart implementation of properties doesn't enforce explicit getter & setter (unlike Java) creation unless they are really needed:

        class Rectangle {
          num left;
          num top;
          num width;
          num height;
        
          Rectangle(this.left, this.top, this.width, this.height);
        
          // Define two calculated properties: right and bottom.
          num get right             => left + width;
              set right(num value)  => left = value - width;
          num get bottom            => top + height;
              set bottom(num value) => top = value - height;
        }

The main benefit of the *get/set* approach is that you can start with bare properties and provide getters and setters
later without breaking your API.

### Inheritance

There is no *interface* keyword in Dart. To define an interface in the way it is understood in Java, simply create
an abstract class with only abstract methods:

        // This class is declared abstract and thus
        // can't be instantiated.
        abstract class Logger {       
          void log(String msg); // Abstract method.
        }
                
However, it is often suitable to provide default implementation at the same time, since Dart supports *implicit interfaces*.
Thus it is possible to implement *any* class interface without actually inheriting the implementation:

        class ConsoleLogger {
          void log(String msg) => print(msg);
        }
        
        class FileLogger implements ConsoleLogger {
            //static checker raises error due to unimplemented method
        }
        
        class YetAnotherConsoleLogger implements ConsoleLogger {
            void log(String msg) => super.log(msg); // raises runtime error, since super refers to Object, not ConsoleLogger
        }
        
        class ExtendedConsoleLogger extends ConsoleLogger {
            //static checker raises error due to unimplemented method
            void log(String msg1, String msg2) { 
              super.log(msg1);
              super.log(msg2);
            }
        }
        
        class ClassLogger {
          void logClass(dynamic obj) {
              print(obj.getClass());
          }
        }

        //Mixin inheritance allows re-use of class body in multiple hierarchies
        // MixinLogger has both log and logClass methods and their implementations
        // from its parents.
        //print(mixin is ClassLogger); //prints true
        //print(mixin is ConsoleLogger); //prints true
        //super has access only to the ConsoleLogger implementation, not ClassLogger
        class MixinLogger extends ConsoleLogger with ClassLogger {
        }

## Asynchronous Processing

In it's asynchronity, Dart is very similar to Node.js. Time-consuming operations are delegated to another thread and
a *promise* object is returned for the user, without waiting for the operation to complete. User then provides
callback function to invoke when the operation completes/fails.

The Dart implementation of a promise is called a `Future`:

        import "dart:async";
        
        Future<String> startLongRunningOp() {
          return new Future(() => "Hello, World!");
        }
        
        void processResult(Future<String> res) {
          res.then(print);
        }
        
        void main() {
          var res = startLongRunningOp();
        
          processResult(res);
        }

However, Dart also provides another, equivalent, syntax for processing asynchronous code, using `async` and `await`
keywords:

        import "dart:async";
        
        Future<String> startLongRunningOp() {
          return new Future(() => "Hello, World!");
        }
        
        //if the function returned something, it would have to be a Future
        //e.g. Future<String> - each async function passes its result as
        //a future
        processResult(Future<String> res) async {
          var text = await res;
          print(text);
        }
        
        void main() {                             
          var res = startLongRunningOp();
        
          processResult(res);
        }

The two pieces of code are equivalent in what they actually do.

## And more...

There is much more to the Dart language. For more exhaustive info, consult the [official documentation](https://www.dartlang.org/docs/dart-up-and-running/ch02.html).