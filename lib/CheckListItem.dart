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
  GlobalKey<CheckListItemState> stateKey = GlobalKey<CheckListItemState>();

  CheckListItem({Key? key, required this.name, required this.img, required this.list}) : super(key: key);

  void check() {
    print(stateKey.currentState);
    stateKey.currentState?.check();
  }

  void unCheck() {
    stateKey.currentState?.unCheck();
  }

  CheckListItemState createState() => CheckListItemState();
}

class CheckListItemState extends State<CheckListItem> with TickerProviderStateMixin {
  bool isChecked = false;
  late AnimationController controller;
  late Animation<int> animation = IntTween(begin: 0, end: 100).animate(controller);

  String get id => widget.list.id + widget.name.toLowerCase().replaceAll(' ', '_');

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: Duration(milliseconds: 150));
    checkIfInitiallyChecked();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void check() {
    setState(() => isChecked = true);
    controller.forward();
    widget.list.checkedItems++;
    eventBus.fire(CheckItemEvent(id, widget.list.id, isChecked));
  }

  void unCheck() {
    setState(() => isChecked = false);
    controller.reverse();
    widget.list.checkedItems--;
    eventBus.fire(CheckItemEvent(id, widget.list.id, isChecked));
  }

  Future<void> checkIfInitiallyChecked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var stringListName = '${widget.list.id}-checked';
    var listIdChecked = prefs.getStringList(stringListName);
    if (listIdChecked == null) return;
    if (listIdChecked.contains(id)) {
      check();
    }
  }

  Future<void> saveItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var stringListName = '${widget.list.id}-checked';
    var listIdChecked = prefs.getStringList(stringListName);
    if (listIdChecked != null) {
      if (isChecked) {
        prefs.setStringList(stringListName, [...listIdChecked, id]);
      } else {
        prefs.setStringList(stringListName, listIdChecked.where((listId) => listId != id).toList());
      }
    } else if (isChecked) {
      prefs.setStringList(stringListName, [id]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      key: widget.stateKey,
      builder: (context, anim) {
        return Stack(children: <Widget>[
          Card(
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
                    controller.forward();
                    widget.list.checkedItems++;
                  } else {
                    controller.reverse();
                    widget.list.checkedItems--;
                  }
                  saveItem();
                  eventBus.fire(CheckItemEvent(id, widget.list.id, isChecked));
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
