/*
 * Copyright © 2021 -  Dorian & Co - All right reserved
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'CheckList.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  static Future<List<FileSystemEntity>> dirContents(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();
    var lister = dir.list(recursive: false);
    lister.listen((file) => files.add(file), onDone: () => completer.complete(files));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List It',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(title: 'Home Page'),
    );
  }
}

class HomePage extends StatefulWidget {
  final String? title;

  HomePage({Key? key, this.title}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  CheckList? selectedList;
  List<CheckListItem> exampleListItems = [
    new CheckListItem('First', Image.network('https://via.placeholder.com/150')),
    new CheckListItem('Second', Image.network('https://via.placeholder.com/150')),
    new CheckListItem('Third', Image.network('https://via.placeholder.com/150')),
    new CheckListItem('Etc', Image.network('https://via.placeholder.com/150')),
  ];
  List<CheckList> availableLists = [];
  int lastTap = DateTime.now().millisecondsSinceEpoch;
  int consecutiveTaps = 0;

  @override
  void initState() {
    super.initState();
    availableLists = [new CheckList.withItems('Movies Test', exampleListItems), new CheckList('Others')];
    loadListsFromJSON().then((json) {
      CheckList newList = CheckList.fromJSON(json);
      setState(() {
        availableLists = [...availableLists, newList];
      });
    });
  }

  Future<JSON> loadListsFromJSON() async {
//    final files = await App.dirContents(Directory.current);
//    print(files);
    final json = await rootBundle.loadString('resources/lists/movies.json');
    return JSON.from(jsonDecode(json));
  }

  Widget buildDrawer() {
    List<Widget> lists = [];
    for (CheckList list in availableLists) {
      var container = new ListTile(
        leading: Icon(Icons.list),
        hoverColor: Colors.blueGrey[200],
        title: Text(
          list.title,
          textAlign: TextAlign.left,
        ),
        onTap: () {
          setState(() {
            selectedList = list;
          });
          Navigator.pop(context);
        },
      );
      lists.add(container);
    }
    return Drawer(
      child: ListView(children: [
        Container(
          height: 80.0,
          child: InkWell(
            onTap: () {
              int now = DateTime.now().millisecondsSinceEpoch;
              if (Duration(milliseconds: now - lastTap) < kDoubleTapTimeout) {
                consecutiveTaps++;
                if (consecutiveTaps >= 5) {
                  print('5 taps');
                }
              } else {
                consecutiveTaps = 0;
              }
              lastTap = now;
            },
            child: DrawerHeader(
              child: const Text(
                'Lists',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
              ),
            ),
          ),
        ),
        ...lists
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedList?.title ?? widget.title!),
      ),
      drawer: buildDrawer(),
      body: Center(child: selectedList?.build() ?? const Text('No list selected')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Increment',
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
