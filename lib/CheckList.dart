/*
 * Copyright © 2021 -  Dorian & Co - All right reserved
 */

import 'dart:ui';
import 'package:flutter/material.dart';

import 'CheckListItem.dart';

typedef JSON = Map<String, dynamic>;

// ignore: must_be_immutable
class CheckList extends StatelessWidget {
  String title = 'Unnamed list';
  List<CheckListItem> items = [];
  bool private = false;
  ValueNotifier<int> checkedItems = new ValueNotifier(0);

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
      this.items.add(new CheckListItem(item['title'], img, this));
    }
  }

  String get id => title.toLowerCase().replaceAll(' ', '_');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: checkedItems,
      builder: (context, value, child) {
        if (items.length > 0) {
          return Column(
            children: [
              Container(
                // padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[10],
                  border: Border.all(color: Colors.grey[300]!, width: .5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton(items: [DropdownMenuItem(child: const Text('Filters'))]),
                    Text(
                      'Checked item${checkedItems.value > 1 ? 's' : ''}: ${checkedItems.value}/${items.length}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  children: items,
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: const Text(
              'This list have no item.',
              style: TextStyle(fontSize: 18),
            ),
          );
        }
      },
    );
  }
}
