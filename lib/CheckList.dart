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
      Image? img;
      if (item['img'].startsWith('../')) {
        img = Image.asset(
          item['img'].replaceAll('../', ''),
          fit: BoxFit.cover,
        );
      } else if (item['img'].startsWith('http')) {
        img = Image.network(item['img']);
      }
      this.items.add(new CheckListItem(item['title'], img!));
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          print('item ${this.name} tapped');
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: this.img.image,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                this.name,
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
