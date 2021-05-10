/*
 * Copyright © 2021 -  Dorian & Co - All right reserved
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'CheckList.dart';
import 'CircularClipper.dart';
import 'main.dart' show eventBus;

class CheckListItem extends StatefulWidget {
  final String name;
  final Image img;
  final CheckList list;
  final GlobalKey<CheckListItemState> stateKey = GlobalKey<CheckListItemState>();

  CheckListItem({Key? key, required this.name, required this.img, required this.list}) : super(key: key);

  void onCheck() => list.checkedItems.add(id);

  void onUnCheck() => list.checkedItems.remove(id);

  String get id => list.id + name.toLowerCase().replaceAll(' ', '_');

  CheckListItemState createState() => CheckListItemState();

  CheckListItemState? get state => stateKey.currentState;
}

class CheckListItemState extends State<CheckListItem> with TickerProviderStateMixin {
  bool isChecked = false;
  late AnimationController controller;
  late Animation<int> animation = IntTween(begin: 0, end: 100).animate(controller);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    checkIfInitiallyChecked(); // BUG
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void check() {
    setState(() => isChecked = true);
    controller.forward();
    widget.onCheck();
    eventBus.fire(CheckItemEvent(widget.id, widget.list.id, isChecked));
  }

  void unCheck() {
    setState(() => isChecked = false);
    controller.reverse();
    widget.onUnCheck();
    eventBus.fire(CheckItemEvent(widget.id, widget.list.id, isChecked));
  }

  Future<void> checkIfInitiallyChecked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var stringListName = '${widget.list.id}-checked';
    var listIdChecked = prefs.getStringList(stringListName);
    if (listIdChecked == null) return;
    if (listIdChecked.contains(widget.id)) {
      check();
    }
  }

  Future<void> saveItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var stringListName = '${widget.list.id}-checked';
    var listIdChecked = prefs.getStringList(stringListName);
    if (listIdChecked != null) {
      if (isChecked) {
        prefs.setStringList(stringListName, [...listIdChecked, widget.id]);
      } else {
        prefs.setStringList(stringListName, listIdChecked.where((listId) => listId != widget.id).toList());
      }
    } else if (isChecked) {
      prefs.setStringList(stringListName, [widget.id]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (context, anim) {
        return Stack(children: <Widget>[
          Card(
            key: widget.stateKey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            margin: EdgeInsets.all(4),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.bottomCenter,
                        foregroundDecoration: BoxDecoration(
                          color: Colors.grey,
                          backgroundBlendMode: BlendMode.saturation,
                        ),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: widget.img.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      ClipPath(
                        clipBehavior: Clip.antiAlias,
                        clipper: CircularClipper(animation.value),
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: widget.img.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
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
          Material(
            child: InkWell(
                splashColor: Colors.grey.withAlpha(30),
                onTap: () {
                  setState(() => isChecked = !isChecked);
                  if (isChecked) {
                    check();
                  } else {
                    unCheck();
                  }
                  saveItem();
                  eventBus.fire(CheckItemEvent(widget.id, widget.list.id, isChecked));
                }),
            type: MaterialType.transparency,
          ),
        ]);
      },
      animation: controller,
    );
  }
}

class CheckItemEvent {
  final String itemId;
  final String listId;
  final bool isChecked;

  CheckItemEvent(this.itemId, this.listId, this.isChecked);
}
