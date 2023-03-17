import 'package:mongo_dart/mongo_dart.dart';

class Product {
  String? id;
  String linkimage;
  String title;
  String details;
  String contact;
  String price;

  Product({
    this.id,
    required this.linkimage,
    required this.title,
    required this.details,
    required this.contact,
    required this.price,
  });

  // Implement a method that returns the map you need
  //Object to Json
  Map<String, dynamic> toMap() {
    return {
      "_id": ObjectId(),
      "linkimage": linkimage,
      "title": title,
      "details": details,
      "contact": contact,
      "price": price,
    };
  }
}
