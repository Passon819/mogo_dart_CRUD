import 'dart:developer';

import 'package:mongotest_app/constant.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongotest_app/main.dart';

var alldata; //อ่านข้อมูลทั้งหมดในmongoDB ได้ข้อมูลเป็น list ของ Json
var db;
var collection;

class MongoDatabase {
  static connect() async {
    db = await Db.create(MONGO_URL);
    await db.open();
    inspect(db);
    var status = db.serverStatus();
    print(status);
    collection = db.collection(COLLECTION_NAME);
    //
    // await collection.insertOne({
    //   "username": "long",
    //   "name": "Passon Saejow",
    //   "email": "passonXXX@gmail.com"
    // });
    // await collection.insertOne({
    //   "linkimage": "long",
    //   "title": "phone",
    //   "details": "iphone 15 pro",
    //   "contact": "FB: Rubhew",
    //   "price": "999",
    // });
    // //
    // await collection.insertMany([
    //   {
    //     "username": "long(many1)",
    //     "name": "Passon Saejow",
    //     "email": "passonXXX@gmail.com"
    //   },
    //   {
    //     "username": "long(many2)",
    //     "name": "Passon Saejow",
    //     "email": "passonXXX@gmail.com"
    //   }
    // ]);

    // print(await collection.find().toList());

    // Update
    // await collection.update(
    //     where.eq('username', 'long'), modify.set('name', 'Update Passson',));

    // print(await collection.find().toList());

    //
    // await collection.deleteOne({"username": "long"});
    // print(await collection.find().toList());
    //
    // await collection.deleteMany({"username": "long(many1)"});
    // print(await collection.find().toList());

    //อ่านข้อมูลทั้งหมดใน collection
    alldata = await collection.find().toList();
    print(alldata);
  }

  addd() async {
    await db.open();
    var collection = db.collection(COLLECTION_NAME);

    await collection.insertOne(mapProduct);
    print("At adddddddd");
  }

  deletee() async {
    await db.open();
    var collection = db.collection(COLLECTION_NAME);

    String hexid = objectid!.substring(10, 34);
    print(hexid);
    // result hexid = "6413f16edfcfe1fbcc3c3033"
    //แปลง hexid ให้เป็น ObjectId
    var id = ObjectId.fromHexString(hexid);

    await collection.deleteOne({"_id": id});
    print("At deleteeeeee");
  }

  editt(int index) async {
    await db.open();
    var collection = db.collection(COLLECTION_NAME);

    String hexid = objectid!.substring(10, 34);
    print(hexid);
    // result hexid = "6413f16edfcfe1fbcc3c3033"
    //แปลง hexid ให้เป็น ObjectId
    var id = ObjectId.fromHexString(hexid);

    await collection.update(
        where.eq('_id', id),
        modify.set(
          'linkimage',
          '${Products[index].linkimage}',
        ));
    await collection.update(
        where.eq('_id', id),
        modify.set(
          'title',
          '${Products[index].title}',
        ));
    await collection.update(
        where.eq('_id', id),
        modify.set(
          'details',
          '${Products[index].details}',
        ));
    await collection.update(
        where.eq('_id', id),
        modify.set(
          'contact',
          '${Products[index].contact}',
        ));
    await collection.update(
        where.eq('_id', id),
        modify.set(
          'price',
          '${Products[index].price}',
        ));
    print('editttttokkkkk');
  }
}
