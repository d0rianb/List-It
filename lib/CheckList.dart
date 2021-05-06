/*
 * Copyright © 2021 -  Dorian & Co - All right reserved
 */

import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

typedef JSON = Map<String, dynamic>;

class CircularClipper extends CustomClipper<Path> {
  int percent;
  CircularClipper(this.percent);

  Path getClip(Size size) {
    Path path = Path();
    double ratio = percent / 100;
    path.addOval(Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width * ratio, height: size.height * ratio));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

// ignore: must_be_immutable
class CheckList extends StatelessWidget {
  String title = 'Unnamed list';
  List<CheckListItem> items = [];
  bool private = false;

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

class CheckListItemState extends State<CheckListItem> with TickerProviderStateMixin {
  bool isChecked = false;
  late AnimationController controller = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
  late Animation<int> animation = IntTween(begin: 0, end: 200).animate(controller);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
                        clipper: CircularClipper(isChecked ? 200 - animation.value : animation.value),
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
//                  controller.forward();
                }),
            type: MaterialType.transparency,
          ),
        ]);
      },
      animation: controller,
    );
  }
}
