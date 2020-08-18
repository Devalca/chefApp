import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myChef/models/state.dart';
import 'package:myChef/ui/screens/detail.dart';
import 'package:myChef/ui/screens/guest.dart';
import 'package:myChef/ui/screens/sign_in.dart';
import 'package:myChef/ui/widgets/loading.dart';
import 'package:myChef/utils/state_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_home.dart';

class HomeScreen extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Firestore firestore = Firestore.instance;
  StateModel appState;
  String filter;
  String filJe;
  bool _loadingVisible = false;

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heightScreen = mediaQueryData.size.height;

    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      return GuestScreen();
    } else {
      if (appState.isLoading) {
        _loadingVisible = true;
      } else {
        _loadingVisible = false;
      }

      final userId = appState?.firebaseUserAuth?.uid ?? '';

      return Scaffold(
        appBar: AppBar(title: Text("My Chef Home"), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                filter = null;
                filJe = null;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.book),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddHomeScreen()));
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              StateWidget.of(context).logOutUser();
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
                                  BoxShadow(
                                      color: Colors.grey, spreadRadius: 3),
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
                                  BoxShadow(
                                      color: Colors.blue, spreadRadius: 3),
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
                                  .where('userId', isEqualTo: userId)
                                  .snapshots()
                              : firestore
                                  .collection('resep')
                                  .where('userId', isEqualTo: userId)
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
                            List<dynamic> listLike = List.from(resep['likes']);
                            List count = resep['likes'];
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
                                          kategori: resep['kategori'],
                                          image: resep['image'],
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
                                      subtitle: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                resep['jenis'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                resep['kategori'],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
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
                                      trailing: Column(
                                        children: <Widget>[
                                          Stack(
                                            children: [
                                              IconButton(
                                                  icon: Icon(
                                                    Icons.favorite,
                                                    size: 40,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    DocumentReference
                                                        documentTask =
                                                        firestore.document(
                                                            'resep/${document.documentID}');
                                                    if (!listLike
                                                        .contains(userId)) {
                                                      listLike.add(userId);
                                                      firestore.runTransaction(
                                                          (transaction) async {
                                                        DocumentSnapshot task =
                                                            await transaction.get(
                                                                documentTask);
                                                        if (task.exists) {
                                                          await transaction
                                                              .update(
                                                            documentTask,
                                                            <String, dynamic>{
                                                              'userId': resep[
                                                                  'userId'],
                                                              'nama':
                                                                  resep['nama'],
                                                              'jenis': resep[
                                                                  'jenis'],
                                                              'keterangan': resep[
                                                                  'keterangan'],
                                                              'image': resep[
                                                                  'image'],
                                                              'likes': listLike,
                                                              'countLikes':
                                                                  count.length +
                                                                      1
                                                            },
                                                          );
                                                        }
                                                      });
                                                    } else {
                                                      print("Gagal");
                                                    }
                                                  }),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20,
                                                        horizontal: 25),
                                                child: listLike == null
                                                    ? Text(" ")
                                                    : Text(
                                                        listLike.length
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.white)),
                                              )
                                            ],
                                          )
                                        ],
                                      )),
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
}
