import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "FAQs",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "How to use the HMApp?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "The application have two user interfaces based on the act that they want to do. The first one is called the Giver like the name suggests, this is the option where the user can donate and give food. On the other hand, the Recipient is the option for those who are aiming and wishing to receive food.\n\nThe transaction begins with the Giver uploading an image of the food to the application and filling in information regarding the said food. Before uploading they need to agree first to the Terms and Conditions regarding the food that they are willing to give. By clicking agree, they are verifying that the food is safe to eat. Recipient who may want to obtain a particular food can review details about the food before confirming. Recipients in the same way are also obliged to agree to the Terms and Conditions of the application. Through chatting, the users can communicate how they will receive the food to finish the transaction.",
            )
          ],
        ),
      ),
    );
  }
}
