import 'package:flutter/material.dart';
import 'package:myChef/models/state.dart';
import 'package:myChef/ui/screens/detail.dart';
import 'package:myChef/ui/widgets/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuestScreen extends StatefulWidget {
  _GuestScreenState createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  final Firestore firestore = Firestore.instance;
  StateModel appState;
  bool _loadingVisible = false;
  String filter;
  String filJe;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heightScreen = mediaQueryData.size.height;

    return Scaffold(
      appBar: AppBar(title: Text("My Chef Home"), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.person_pin),
          onPressed: () {
            Navigator.pushNamed(context, '/signin');
          },
        ),
      ]),
      backgroundColor: Colors.white,
      body: LoadingScreen(
          child: Container(
            width: widthScreen,
            height: heightScreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 50,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection('jenis')
                        .orderBy('jenis')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center();
                      }
                      return ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: snapshot.data.documents.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document =
                              snapshot.data.documents[index];
                          Map<String, dynamic> jns = document.data;
                          return Container(
                            margin: EdgeInsets.only(right: 12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.grey, spreadRadius: 3),
                              ],
                            ),
                            height: 25,
                            child: FlatButton(
                                child: Text(jns['jenis']),
                                onPressed: () {
                                  String fil = jns['jenis'];
                                  setState(() {
                                    filJe = fil;
                                  });
                                }),
                          );
                        },
                      );
                    },
                  ),
                ),
                Container(
                  height: 50,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection('kategori')
                        .orderBy('kategori')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center();
                      }
                      return ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: snapshot.data.documents.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document =
                              snapshot.data.documents[index];
                          Map<String, dynamic> kat = document.data;
                          return Container(
                            margin: EdgeInsets.only(right: 12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.blue, spreadRadius: 3),
                              ],
                            ),
                            height: 25,
                            child: FlatButton(
                                child: Text(kat['kategori']),
                                onPressed: () {
                                  String fil = kat['kategori'];
                                  setState(() {
                                    filter = fil;
                                  });
                                }),
                          );
                        },
                      );
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: filJe == null
                        ? filter == null
                            ? firestore
                                .collection('resep')
                                .orderBy("countLikes", descending: true)
                                .snapshots()
                            : firestore
                                .collection('resep')
                                .where('kategori', isEqualTo: filter)
                                .snapshots()
                        : firestore
                            .collection('resep')
                            .where('kategori', isEqualTo: filter)
                            .where('jenis', isEqualTo: filJe)
                            .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (BuildContext context, int index) {
                          DocumentSnapshot document =
                              snapshot.data.documents[index];
                          Map<String, dynamic> resep = document.data;
                          List listLike = resep['likes'];
                          return Card(
                            child: Container(
                              height: 100,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      return DetailScreen(
                                        documentId: document.documentID,
                                        nama: resep['nama'],
                                        keterangan: resep['keterangan'],
                                        image: resep['image'],
                                        kategori: resep['kategori'],
                                        jenis: resep['jenis'],
                                      );
                                    }),
                                  );
                                },
                                child: ListTile(
                                  title: Text(
                                    resep['nama'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  subtitle: listLike == null
                                      ? Text(" ")
                                      : Row(
                                          children: <Widget>[
                                            Text(
                                              listLike.length.toString(),
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            Text(" Orang menyukai resep ini")
                                          ],
                                        ),
                                  isThreeLine: false,
                                  leading: Container(
                                      width: 60.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: resep['image'] != null
                                          ? Container(
                                              child: Image.network(
                                              resep['image'],
                                              fit: BoxFit.fill,
                                            ))
                                          : Text("data")),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          inAsyncCall: _loadingVisible),
    );
  }
}
