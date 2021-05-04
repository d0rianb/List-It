/*
 * Copyright © 2021 -  Dorian & Co - All right reserved
 */

import 'dart:ui';
import 'package:flutter/material.dart';

typedef JSON = Map<String, dynamic>;

class CheckList {
  String title = 'Unnamed list';
  List<CheckListItem> items = [];

  CheckList(this.title);

  CheckList.withItems(this.title, this.items);

  CheckList.fromJSON(JSON json) {
    this.title = json['title'];
    for (var item in json['items']) {
      this.items.add(new CheckListItem(item['title'], Image.network(item['img'])));
    }
  }

  Widget build() {
    List<Widget> items = [];
    for (CheckListItem item in this.items) {
      items.add(item.build());
    }
    return items.length > 0
        ? GridView.count(
            crossAxisCount: 2,
            children: items,
          )
        : Center(child: const Text('This list have no item.'));
  }
}

class CheckListItem {
  String name;
  bool isChecked = false;
  Image img;

  CheckListItem(this.name, this.img);

  Widget build() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      margin: EdgeInsets.all(16),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () => {print('item ${this.name} tapped')},
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[this.img, Text(this.name)],
        ),
      ),
    );
  }
}
