import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hmapp/donate.dart';
import 'package:hmapp/home.dart';
import 'package:hmapp/search.dart';
import 'package:hmapp/sidebar.dart';

class Food_Copy_2 extends StatefulWidget {
  @override
  _Food_Copy_2State createState() => _Food_Copy_2State();
}

const highlightColor = Color(0xFF214847);
const backgroundColor = Color(0xFFe3dbc8);
TextStyle title = TextStyle(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.bold,
    color: highlightColor);

TextStyle txt_btn = const TextStyle(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.bold,
    color: highlightColor);

TextStyle giver = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.bold,
    color: highlightColor);

TextStyle style4 = TextStyle(
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.bold,
    color: highlightColor);

const style2 = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll<Color>(highlightColor),
);

class _Food_Copy_2State extends State<Food_Copy_2> {
  bool finished = false;
  @override
  Widget build(BuildContext context) {
    Widget food = Column(children: [
      Text(
        "Someone wants to receive your food.",
        style: title,
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 16,
      ),
      Row(
        children: [
          Text(
            "Receiver's location:",
            textAlign: TextAlign.left,
            style: giver,
          )
        ],
      ),
      SizedBox(
        height: 12,
      ),
      Container(
        child: Image.asset(
          "assets/images/map.png",
          height: 148,
        ),
        height: 148,
        decoration: new BoxDecoration(
            color: highlightColor, borderRadius: BorderRadius.circular(16)),
      ),
      SizedBox(
        height: 8,
      ),
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.image,
                size: 64,
              ),
              SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Details:"),
                  SizedBox(height: 8),
                  Text("Type of food:"),
                  Text("Expiration:")
                ],
              )
            ],
          ),
        ),
      ),
      TextButton(
          onPressed: () {},
          child: Row(
            children: [
              Icon(
                Icons.message,
                size: 24,
                color: highlightColor,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "Message Receiver",
                style: txt_btn,
              )
            ],
          )),
      Expanded(child: SizedBox()),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    finished = !finished;
                  });
                },
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(highlightColor)),
                child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )),
              ),
            )
          ],
        ),
      )
    ]);
    Widget ty = Column(children: [
      Text(
        "Waiting to be picked up.",
        style: title,
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 16,
      ),
      Row(
        children: [
          Text(
            "Receiver's live location:",
            textAlign: TextAlign.left,
            style: giver,
          )
        ],
      ),
      SizedBox(
        height: 12,
      ),
      Container(
        child: Image.asset(
          "assets/images/map.png",
          height: 148,
        ),
        height: 148,
        decoration: new BoxDecoration(
            color: highlightColor, borderRadius: BorderRadius.circular(16)),
      ),
      SizedBox(
        height: 8,
      ),
      Text(
        "Estimated Arrival Time:",
        style: style4,
      ),
      Text(
        "Less than 5 minutes",
        style: style4,
      ),
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.image,
                size: 64,
              ),
              SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Details:"),
                  SizedBox(height: 8),
                  Text("Type of food:"),
                  Text("Expiration:")
                ],
              )
            ],
          ),
        ),
      ),
      TextButton(
          onPressed: () {},
          child: Row(
            children: [
              Icon(
                Icons.message,
                size: 24,
                color: highlightColor,
              ),
              SizedBox(
                width: 8,
              ),
              Text(
                "Message Receiver",
                style: txt_btn,
              )
            ],
          )),
      Expanded(child: SizedBox()),
    ]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: highlightColor,
        toolbarHeight: 64, // Set this height
        title: Text("Receive"),
      ),
      drawer: Sidebar(),
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: Padding(padding: EdgeInsets.all(48), child: finished ? ty : food),
    );
  }
}
