/*
 * Copyright © 2021 -  Dorian & Co - All right reserved
 * Credit to Anastasiia Frizen for the illustrations
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:package_info/package_info.dart';

import 'CheckList.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
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
  List<CheckList> availableLists = [];
  int lastTap = DateTime.now().millisecondsSinceEpoch;
  int consecutiveTaps = 0;
  bool showPrivateLists = false;
  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    getAppInfos();
    loadListsFromJSON();
  }

  Future<void> getAppInfos() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() => packageInfo = info);
  }

  void loadListsFromJSON() async {
    final manifestContent = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
    final listsPath = manifestMap.keys.where((String key) => key.contains('resources/lists')).toList();

    availableLists = [];

    for (String path in listsPath) {
      final jsonString = await rootBundle.loadString(path);
      final JSON json = JSON.from(jsonDecode(jsonString));
      CheckList newList = CheckList.fromJSON(json);
      if (showPrivateLists || !newList.private) setState(() => availableLists = [...availableLists, newList]);
    }
  }

  Widget buildDrawer() {
    List<Widget> lists = [];
    for (CheckList list in availableLists) {
      Widget container = new ListTile(
        leading: Icon(Icons.list),
        hoverColor: Colors.blueGrey[200],
        title: Text(
          list.title,
          textAlign: TextAlign.left,
        ),
        onTap: () {
          setState(() => selectedList = list);
          Navigator.pop(context);
        },
      );
      lists.add(container);
    }

    List<Widget> drawerContent = (lists.length == 0) ? [Padding(padding: const EdgeInsets.all(20.0), child: Center(child: SizedBox(child: CircularProgressIndicator(), height: 50.0, width: 50.0)))] : lists;

    return Drawer(
      child: ListView(children: [
        Container(
          height: 80.0,
          child: InkWell(
            onTap: () {
              int now = DateTime.now().millisecondsSinceEpoch;
              if (Duration(milliseconds: now - lastTap) < kDoubleTapTimeout) {
                consecutiveTaps++;
                if (consecutiveTaps == 5) {
                  setState(() => showPrivateLists = !showPrivateLists);
                  loadListsFromJSON();
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
        ...drawerContent,
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
        body: Center(child: selectedList ?? const Text('No list selected')),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Create',
          onPressed: () {},
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Dorian&Co © ${packageInfo.appName} -  v${packageInfo.version}',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ],
        ));
  }
}
