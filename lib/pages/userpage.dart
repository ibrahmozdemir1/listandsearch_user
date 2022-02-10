// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:listandsearch_user/Serialize/user.dart';
import 'package:listandsearch_user/Serialize/userphoto.dart';

class Jobs extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  Jobs({Key? key}) : super(key: key);

  @override
  JobsState createState() => JobsState();
}

List<UsersPhoto> uphotoList = [];
List<UsersPhoto> uphotoLists = [];
List<Users> ulist = [];
List<Users> userLists = [];

getPhotoUrl(String userid) {
  for (var i = 0; i < uphotoLists.length; i++) {
    if (uphotoList[i].id == userid) {
      String photoUrl = (uphotoList[i].download_url).toString();
      return photoUrl;
    }
  }
}

class JobsState extends State<Jobs> {
  final TextEditingController _searchController = TextEditingController();
  List<String> photoResponse = [];
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
      throw Exception(e);
    }
  }

  static List<Users> parseAgents(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Users>((json) => Users.fromJson(json)).toList();
  }

  Future<List<UsersPhoto>> getAlluphotoList() async {
    for (var i = 0; i < userLists.length; i++) {
      String purl = photourl + (userLists[i].id).toString() + '/info';
      try {
        final responsephoto = await http.get(Uri.parse(purl));
        if (responsephoto.statusCode == 200) {
          photoResponse.add(responsephoto.body);
        } else {
          throw Exception('Error');
        }
      } catch (e) {
        throw Exception(e);
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

  getUserList(String text) {
    setState(() {
      userLists = ulist
          .where(
            (u) => (u.username!.toLowerCase().contains(text.toLowerCase())),
          )
          .toList();
    });
  }

  //Main Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Information',
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
              controller: _searchController,
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
                suffixIcon: _searchController.text != ''
                    ? InkWell(
                        child: const Icon(Icons.clear),
                        onTap: () {
                          _searchController.text = '';
                          getUserList(_searchController.text);
                        },
                      )
                    : const Icon(Icons.search),
                contentPadding: const EdgeInsets.all(15.0),
                hintText: 'Search ',
              ),
              onChanged: (String text) {
                //  _debouncer.run(() {
                getUserList(text);
                //     });
              },
            ),
          ),
          Expanded(
            child: userLists.isEmpty
                ? const Text('Kullanıcı Bulunamadı')
                : ListView.builder(
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
                          child: ListTile(
                            leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: (getPhotoUrl(
                                            userLists[index].id.toString()) ==
                                        null)
                                    ? const AssetImage('image/loading.gif')
                                    : NetworkImage(getPhotoUrl(
                                            userLists[index].id.toString()))
                                        as ImageProvider),
                            title: Text(
                              (userLists[index].name).toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              (userLists[index].username).toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.account_circle),
                              onPressed: () {
                                showGeneralDialog(
                                    context: context,
                                    pageBuilder: (BuildContext buildContext,
                                        Animation animation,
                                        Animation secondaryAnimation) {
                                      return _informationDialog(
                                          context,
                                          (userLists[index].id).toString(),
                                          index);
                                    });
                              },
                            ),
                          ));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

ShapeBorder _defaultShape() {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30.0),
    side: const BorderSide(
      color: Colors.deepOrange,
    ),
  );
}

_getCloseButton(context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
    child: GestureDetector(
      onTap: () {},
      child: Container(
        alignment: FractionalOffset.topRight,
        child: GestureDetector(
          child: const Icon(
            Icons.clear,
            color: Colors.red,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    ),
  );
}

Widget _informationDialog(context, userid, index) {
  return AlertDialog(
    backgroundColor: Colors.white,
    shape: _defaultShape(),
    content: SizedBox(
      width: 250,
      height: 330,
      child: Column(
        children: <Widget>[
          _getCloseButton(context),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage: (getPhotoUrl(userid) == null)
                    ? const AssetImage('image/loading.gif')
                    : NetworkImage(getPhotoUrl(userid)) as ImageProvider,
              ),
              Text(
                (userLists[index].name).toString(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                (userLists[index].email).toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Email: " + (userLists[index].email).toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Telefon: " + (userLists[index].phone).toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Adres: " +
                      (userLists[index].address!.street).toString() +
                      (userLists[index].address!.suite).toString() +
                      (userLists[index].address!.zipcode).toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Şehir: " + (userLists[index].address!.city).toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  "Konum: " +
                      (userLists[index].address!.geo!.lat).toString() +
                      "/" +
                      (userLists[index].address!.geo!.lng).toString(),
                  style: const TextStyle(fontSize: 16),
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}
