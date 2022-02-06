//declare packages
// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:listandsearch_user/Serialize/user.dart';
import 'package:listandsearch_user/Serialize/userphoto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Jobs(),
    );
  }
}

class Jobs extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  Jobs({Key? key}) : super(key: key);

  @override
  JobsState createState() => JobsState();
}

class Debouncer {
  int? milliseconds;
  VoidCallback? action;
  Timer? timer;

  run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(
      const Duration(milliseconds: Duration.millisecondsPerSecond),
      action,
    );
  }
}

class JobsState extends State<Jobs> {
  final _debouncer = Debouncer();

  List<Users> ulist = [];
  List<Users> userLists = [];
  List<String> photoResponse = [];
  List<UsersPhoto> uphotoList = [];
  List<UsersPhoto> uphotoLists = [];

  String url = 'https://jsonplaceholder.typicode.com/users';
  String photourl = 'https://picsum.photos/id/';

  Future<List<Users>> getAllulistList() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // print(response.body);
        List<Users> list = parseAgents(response.body);
        return list;
      } else {
        throw Exception('Error');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static List<Users> parseAgents(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Users>((json) => Users.fromJson(json)).toList();
  }

  Future<List<UsersPhoto>> getAlluphotoList() async {
    print(userLists.length);
    for (var i = 0; i < userLists.length; i++) {
      String purl = photourl + (userLists[i].id).toString() + '/info';
      try {
        final responsephoto = await http.get(Uri.parse(purl));
        if (responsephoto.statusCode == 200) {
          photoResponse.add(responsephoto.body);
        } else {
          throw Exception('Error');
        }
      } catch (e1) {
        throw Exception(e1.toString());
      }
    }
    List<UsersPhoto> photolist = parseAgentsPhoto(photoResponse);
    return photolist;
  }

  static List<UsersPhoto> parseAgentsPhoto(List<String> uphotos) {
    List<UsersPhoto> uphotoList = [];
    for (var i = 0; i < uphotos.length; i++) {
      final parsed = UsersPhoto.fromJson(json.decode(uphotos[i]));
      uphotoList.add(parsed);
    }
    return uphotoList;
  }

  @override
  void initState() {
    super.initState();
    getAllulistList().then((usersFromServer) {
      setState(() {
        ulist = usersFromServer;
        userLists = ulist;
      });
      getAlluphotoList().then((uphotoServer) {
        setState(() {
          uphotoList = uphotoServer;
          uphotoLists = uphotoList;
        });
      });
    });
  }

  //Main Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Users',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: Column(
        children: <Widget>[
          //Search Bar to List of typed Subject
          Container(
            padding: const EdgeInsets.all(15),
            child: TextField(
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                  ),
                ),
                suffixIcon: const InkWell(
                  child: Icon(Icons.search),
                ),
                contentPadding: const EdgeInsets.all(15.0),
                hintText: 'Search ',
              ),
              onChanged: (string) {
                _debouncer.run(() {
                  setState(() {
                    userLists = ulist
                        .where(
                          (u) => (u.username!.toLowerCase().contains(
                                string.toLowerCase(),
                              )),
                        )
                        .toList();
                  });
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(5),
              itemCount: userLists.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            userLists[index].name ?? "null",
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            userLists[index].username ?? "null",
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
