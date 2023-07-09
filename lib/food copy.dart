import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:hmapp/donate.dart';
import 'package:hmapp/home.dart';
import 'package:hmapp/search.dart';
import 'package:hmapp/sidebar.dart';

class Food_Copy extends StatefulWidget {
  @override
  _Food_CopyState createState() => _Food_CopyState();
}

const highlightColor = Color(0xFF214847);
const backgroundColor = Color(0xFFe3dbc8);
TextStyle title = TextStyle(
    fontSize: 28,
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

class _Food_CopyState extends State<Food_Copy> {
  bool finished = false;
  @override
  Widget build(BuildContext context) {
    Widget food = ListView(children: [
      Text(
        "Your request has been granted.",
        style: title,
        textAlign: TextAlign.center,
      ),
      Text(
        "You can pick up your food now.",
        style: style4,
      ),
      SizedBox(
        height: 16,
      ),
      Row(
        children: [
          Text(
            "Giver's location:",
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
                Icons.account_circle,
                size: 64,
              ),
              SizedBox(
                width: 12,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Details:"),
                  Text("Name:"),
                  Text("Contact Number:"),
                  Text("Address:")
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
                "Message Giver",
                style: txt_btn,
              )
            ],
          )),
      Row(
        children: [
          Text(
            "Disclaimer",
            textAlign: TextAlign.left,
            style: TextStyle(
                color: highlightColor,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
      SizedBox(
        height: 4,
      ),
      Text(
        "By clicking the food received button below, you hereby confirm to receive food through the HMApp. By agreeing, you acknowledge and understand that the creator of the application will not be liable for any possible health-related harm that may happen. This is because there are several factors that are beyond the control of the creator of the application. It is important that you know that the food you can receive here may or may not contain traces of different allergens. Please let the giver know if you suffer from a food allergy or have any specific dietary needs or get in touch with the giver for more information on this food.",
        style: TextStyle(fontSize: 12),
      ),
      SizedBox(
        height: 8,
      ),
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
                      "Food Received",
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
      Icon(
        Icons.check,
        size: 64,
      ),
      Text(
        "Thank you! Enjoy your food.",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
        textAlign: TextAlign.center,
      ),
      Expanded(child: SizedBox()),
      Text(
        "The people who give you their food, give you their heart.\nCesar Chavez",
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 12,
      ),
      Row(
        children: [
          Expanded(
              child: ElevatedButton(
            child: Text("Finish"),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(highlightColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ))
        ],
      )
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
