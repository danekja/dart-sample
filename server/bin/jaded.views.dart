import 'dart:isolate';
import 'package:jaded/runtime.dart';
import 'package:jaded/runtime.dart' as jade;

render(Map locals) {
  
var buf = [];
var self = locals;
if (self == null) self = {};
buf.add("<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>Dart appka</title><link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css\" integrity=\"sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7\" crossorigin=\"anonymous\"><link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css\" integrity=\"sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r\" crossorigin=\"anonymous\"><script src=\"/js/jquery.min.js\"></script></head><script src=\"/js/frontend.js\"></script><body><h1>Dart workshop</h1><p>Simple dart + redstone + jade + bootstrap + mongo application</p><div id=\"wrapper\"><div id=\"userInfo\" class=\"col-md-3\"><h2>User Details</h2><table class=\"table\"><tr><td class=\"col-md-1\"><strong>Username:</strong></td><td id=\"userInfoUsername\"></td></tr><tr><td class=\"col-md-1\"><strong>Email:</strong></td><td id=\"userInfoEmail\"></td></tr><tr><td class=\"col-md-1\"><strong>Full Name:</strong></td><td id=\"userInfoFullname\"></td></tr></table></div><div id=\"userList\" class=\"col-md-4\"><h2>User List</h2><table class=\"table table-striped table-bordered\"><thead><th>UserName</th><th class=\"col-md-3\">Action</th></thead><tbody></tbody></table></div><div id=\"addUser\" class=\"col-md-3\"><h2>Add New User</h2><p><input id=\"inputUserName\" type=\"text\" placeholder=\"Username\" class=\"form-control\"></p><p><input id=\"inputUserEmail\" type=\"text\" placeholder=\"Email\" class=\"form-control\"></p><p><input id=\"inputUserFullname\" type=\"text\" placeholder=\"Full Name\" class=\"form-control\"></p><p><button id=\"btnAddUser\" class=\"btn btn-success\">Add User</button></p></div></div><script src=\"https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js\"></script><script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js\" integrity=\"sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS\" crossorigin=\"anonymous\"></script></body></html>");;
return buf.join("");

}

main(List args, SendPort replyTo) {
  var html = render(args.first);
    replyTo.send(html.toString());
}
