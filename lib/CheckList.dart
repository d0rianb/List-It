/*
 * Copyright © 2021 -  Dorian & Co - All right reserved
 */

import 'package:flutter/material.dart';

import 'CheckListItem.dart';

typedef JSON = Map<String, dynamic>;

// ignore: must_be_immutable
class CheckList extends StatelessWidget {
  String title = 'Unnamed list';
  List<CheckListItem> items = [];
  bool private = false;
  Set<String> checkedItems = {};

  CheckList(this.title, this.items);

  CheckList.fromJSON(JSON json) {
    title = json['title'];
    if (json.containsKey('private')) {
      private = json['private'];
    }
    for (var item in json['items']) {
      Image? img;
      if (item['img'].startsWith('http')) {
        img = Image.network('https://picsum.photos/250?image=9'); // Placeholder for item['img']
      } else {
        img = Image.asset(item['img'].replaceAll('../', ''));
      }
      this.items.add(new CheckListItem(key: UniqueKey(), name: item['title'], img: img, list: this));
    }
  }

  String get id => title.toLowerCase().replaceAll(' ', '_');

  void checkAll() {
    for (var item in items) {
      // item.check();
    }
  }

  void unCheckAll() {
    for (var item in items) {
      // item..unCheck();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.length > 0) {
      return GridView.count(
        crossAxisCount: 2,
        children: items,
      );
    } else {
      return Center(
        child: const Text(
          'This list have no item.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
  }
}
