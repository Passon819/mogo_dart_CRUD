import 'package:flutter/material.dart';

import 'Person.dart';
import 'mongodb.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  runApp(const MyApp());
  impdata();
}

//นำข้อมูลที่อ่านได้ใน alldata มาเก็บไว้ใน list Products
void impdata() {
  for (var i = 0; i < alldata.length; i++) {
    Products.add(Product(
      id: alldata[i]['_id'].toString(),
      linkimage: alldata[i]["linkimage"],
      title: alldata[i]["title"],
      details: alldata[i]["details"],
      contact: alldata[i]["contact"],
      price: alldata[i]["price"],
    ));
  }
}

List<Product> Products = []; //list of (json to object)
var mapProduct; //ตัวแปรรอเพิ่มข้อมูลลงDB จะเก็บค่าmap/json เอาไว้
String?
    objectid; // "ObjectId("6413f16edfcfe1fbcc3c3033")" ถูกเก็บไว้แบบ String เพื่อนำไปทำ substring

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter MongoCRUD Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //var showjson =
  //    alldata[0]["username"]; //ข้อมูลใน list แต่ละตำแหน่งเก็บ 1 Document
  //var showdata;

  // void _incrementCounter() {
  //   setState(() {
  //     //addd();
  //     //showdata = showjson["name"];
  //     //เลือก key ของข้อมูลที่ต้องการแสดงและนำข้อมูลไปเก็บ
  //   });
  // }

  void _deleteItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 250, 249, 244),
          elevation: 100,
          title: Text('Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 223, 0, 0), // Background color
              ),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  objectid = Products[index].id;

                  print(objectid);

                  Products.removeAt(index);
                  //alldata.removeAt(index);
                  MongoDatabase().deletee();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: Products.length,
          itemBuilder: (BuildContext context, int index) {
            //เอาข้อมูลใน list object มาโชว์
            Product eachproduct = Products[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage('${eachproduct.linkimage}'),
              ),
              title: Row(
                children: [
                  SizedBox(width: 25),
                  Text(
                    '${eachproduct.title}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              subtitle: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 25),
                      Text('${eachproduct.details}'),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 25),
                      Text('${eachproduct.contact}'),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 25),
                      Text('${eachproduct.price}'),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit_note),
                    onPressed: () async {
                      Product editProduct = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditForm(),
                            settings:
                                RouteSettings(arguments: Products[index])),
                      );

                      setState(() {
                        Products[index].linkimage = editProduct.linkimage;
                        Products[index].title = editProduct.title;
                        Products[index].details = editProduct.details;
                        Products[index].contact = editProduct.contact;
                        Products[index].price = editProduct.price;

                        //เก็บ ObjectId ของอันที่แก้เพื่อนำไประบุการแก้ให้ตรงกับ_idฐานข้อมูล
                        objectid = Products[index].id;
                        print(objectid);
                        MongoDatabase().editt(index);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      _deleteItem(index);
                      print(Products[index].id);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Product newProduct = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddForm()),
          );
          setState(() {
            Products.add(newProduct);

            //แปลงเป็น map/json
            mapProduct = Products[Products.length - 1].toMap();
            print(mapProduct);

            //เพิ่ม ObjectID ที่่ได้จากแปลง toMap ลงใน id ของข้อมูลที่เพิ่มมาใหม่
            Products[Products.length - 1].id = mapProduct['_id'].toString();
            MongoDatabase().addd();
          });
        },
        tooltip: 'เพิ่มรายการข้อมูล',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

//
//ฟอร์มเพิ่มข้อมูล
class AddForm extends StatefulWidget {
  const AddForm({super.key});

  @override
  State<AddForm> createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
  //
  //final textController_num = TextEditingController();
  final textController_linkimage = TextEditingController();
  final textController_title = TextEditingController();
  final textController_details = TextEditingController();
  final textController_contact = TextEditingController();
  final textController_price = TextEditingController();
  final _formKey = GlobalKey<FormState>(); //key ที่ใช้เข้าถึง form เพิ่ม

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80, //ความสูง Appbar
        title: const Text(
          'ADD Product',
          style: TextStyle(color: Colors.white),
        ),
        //shadowColor: Colors.black,
        backgroundColor: Color.fromARGB(255, 19, 18, 18),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                //ช่องเพิ่มลิงค์รูปภาพ
                TextFormField(
                  controller: textController_linkimage,
                  decoration: InputDecoration(
                    hintText: 'Your Image link',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //ช่องเพิ่มชื่อสินค้า
                TextFormField(
                  controller: textController_title,
                  decoration: InputDecoration(
                    hintText: 'Product Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //ช่องเพิ่มรายละเอียด
                TextFormField(
                  controller: textController_details,
                  decoration: InputDecoration(
                    hintText: 'Details',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //ช่องทางติดต่อ
                TextFormField(
                  controller: textController_contact,
                  decoration: InputDecoration(
                    hintText: 'Contact',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //ช่องเพิ่มราคา
                TextFormField(
                  controller: textController_price,
                  decoration: InputDecoration(
                    hintText: 'Price',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //แถวของสองปุ่ม Cancel Submit
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //ปุ่มยกเลิก
                    ElevatedButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 15),

                    //ปุ่มบันทึกข้อมูล
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          //เก็บค่าที่ผู้ใช้กรอกในตัวแปลใหม่ เพื่อเตรียม Return ค่า
                          //final itemNo = int.parse(textController_num.text);
                          final itemLinkimage = textController_linkimage.text;
                          final itemTitle = textController_title.text;
                          final itemDetails = textController_details.text;
                          final itemContact = textController_contact.text;
                          final itemPrice = textController_price.text;

                          //สร้างเป็นวัตถุก้อนใหม่เพื่อ return
                          Product answer = Product(
                              linkimage: itemLinkimage,
                              title: itemTitle,
                              details: itemDetails,
                              contact: itemContact,
                              price: itemPrice);

                          // Clear the text controller
                          //textController_num.clear();
                          textController_linkimage.clear();
                          textController_title.clear();
                          textController_details.clear();
                          textController_contact.clear();
                          textController_price.clear();

                          _formKey.currentState!.reset();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Add Data to your list')),
                          );
                          Navigator.pop(context, answer); //return answer
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary:
                            Color.fromARGB(255, 59, 97, 75), // Background color
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//
//ฟอร์มแก้ไขข้อมูล
class EditForm extends StatefulWidget {
  const EditForm({super.key});

  @override
  State<EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<EditForm> {
  final _formKey = GlobalKey<FormState>(); //key ที่ใช้เข้าถึง form แก้ไข

  @override
  Widget build(BuildContext context) {
    Product item = ModalRoute.of(context)!.settings.arguments
        as Product; //item รับวัตถุตำแหน่งที่จะแก้ไขจากที่ส่งมา
    //final textController_num = TextEditingController(text: item.num.toString());
    final textController_linkimage =
        TextEditingController(text: item.linkimage);
    final textController_title = TextEditingController(text: item.title);
    final textController_details = TextEditingController(text: item.details);
    final textController_contact = TextEditingController(text: item.contact);
    final textController_price = TextEditingController(text: item.price);
    //
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80, //ความสูง Appbar
        title: const Text(
          'Edit Product',
          style: TextStyle(color: Colors.white),
        ),
        //shadowColor: Colors.black,
        backgroundColor: Color.fromARGB(255, 19, 18, 18),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                //ช่องแก้ไขลิงค์รูปภาพ
                TextFormField(
                  controller: textController_linkimage,
                  decoration: InputDecoration(
                    hintText: 'New image link',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //ช่องแก้ไขชือสินค้า
                TextFormField(
                  controller: textController_title,
                  decoration: InputDecoration(
                    hintText: 'New Product Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //ช่องแก้ไขรายละเอียด
                TextFormField(
                  controller: textController_details,
                  decoration: InputDecoration(
                    hintText: 'Details',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //ช่องช่องทางติดต่อ
                TextFormField(
                  controller: textController_contact,
                  decoration: InputDecoration(
                    hintText: 'Your contact',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //ช่องแก้ไขราคา
                TextFormField(
                  controller: textController_price,
                  decoration: InputDecoration(
                    hintText: 'New Price',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),

                //แถวของสองปุ่ม Cancel Confirm
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    //ปุ่มยกเลิก
                    ElevatedButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 15),

                    //ปุ่มยืนยันบันทึกข้อมูล
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          //เก็บค่าที่ผู้ใช้กรอกในตัวแปลใหม่ เพื่อเตรียม Return ค่า
                          //final itemNo = int.parse(textController_num.text);
                          final itemLinkimage = textController_linkimage.text;
                          final itemTitle = textController_title.text;
                          final itemDetails = textController_details.text;
                          final itemContact = textController_contact.text;
                          final itemPrice = textController_price.text;

                          //สร้างเป็นวัตถุก้อนใหม่เพื่อ return
                          Product answer = Product(
                            //num: itemNo,
                            linkimage: itemLinkimage,
                            title: itemTitle,
                            details: itemDetails,
                            contact: itemContact,
                            price: itemPrice,
                          );

                          // Clear the text controller
                          //textController_num.clear();
                          textController_linkimage.clear();
                          textController_title.clear();
                          textController_details.clear();
                          textController_contact.clear();
                          textController_price.clear();

                          _formKey.currentState!.reset();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Add Data to your list')),
                          );
                          Navigator.pop(context, answer); //return answer
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(
                            255, 60, 161, 60), // Background color
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
