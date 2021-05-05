/*
 * Copyright © 2021 -  Dorian & Co - All right reserved
 */

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

typedef JSON = Map<String, dynamic>;

class CheckList extends StatelessWidget {
  String title = 'Unnamed list';
  List<CheckListItem> items = [];

  CheckList(this.title);

  CheckList.withItems(this.title, this.items);

  CheckList.fromJSON(JSON json) {
    this.title = json['title'];
    for (var item in json['items']) {
      Image? img;
      if (item['img'].startsWith('http'))
        img = Image.network(item['img']);
      else
        img = Image.asset(item['img'].replaceAll('../', ''));
      this.items.add(new CheckListItem(item['title'], img));
    }
  }

  Widget build(BuildContext context) {
    return items.length > 0
        ? GridView.count(
            crossAxisCount: 2,
            children: items,
          )
        : Center(child: const Text('This list have no item.'));
  }
}

class CheckListItem extends StatefulWidget {
  final String name;
  final Image img;

  CheckListItem(this.name, this.img);

  CheckListItemState createState() => CheckListItemState();
}

class CheckListItemState extends State<CheckListItem> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      margin: EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          setState(() => isChecked = !isChecked);
        },
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                foregroundDecoration: BoxDecoration(
                  color: isChecked ? Colors.transparent : Colors.grey,
                  backgroundBlendMode: BlendMode.saturation,
                ),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.img.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                widget.name,
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
