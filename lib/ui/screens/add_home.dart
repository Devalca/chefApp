import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myChef/models/state.dart';
import 'package:myChef/ui/screens/add_res.dart';
import 'package:myChef/ui/screens/home.dart';
import 'package:myChef/utils/state_widget.dart';

class AddHomeScreen extends StatefulWidget {
  @override
  _AddHomeScreenState createState() => _AddHomeScreenState();
}

class _AddHomeScreenState extends State<AddHomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  final Firestore firestore = Firestore.instance;
  String filter;
  String filJe;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heightScreen = mediaQueryData.size.height;
    StateModel appState;
    bool _loadingVisible = false;

    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      return HomeScreen();
    } else {
      if (appState.isLoading) {
        _loadingVisible = true;
      } else {
        _loadingVisible = false;
      }

      final userId = appState?.firebaseUserAuth?.uid ?? '';

      return Scaffold(
        appBar: AppBar(title: Text("Semua Resep"), actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                filter = null;
                filJe = null;
              });
            },
          ),
        ]),
        key: scaffoldState,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Container(
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
                                .where('userId', isEqualTo: userId)
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
                              return Card(
                                child: ListTile(
                                  title: Text(resep['nama']),
                                  subtitle: Row(
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
                                  isThreeLine: false,
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          width: 24.0,
                                          height: 24.0,
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
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (BuildContext context) {
                                      return List<PopupMenuEntry<String>>()
                                        ..add(PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ))
                                        ..add(PopupMenuItem<String>(
                                          value: 'hapus',
                                          child: Text('Hapus'),
                                        ));
                                    },
                                    onSelected: (String value) async {
                                      if (value == 'edit') {
                                        bool result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return AddResScreen(
                                                isEdit: true,
                                                documentId: document.documentID,
                                                nama: resep['nama'],
                                                keterangan: resep['keterangan'],
                                                kategori: resep['kategori'],
                                                image: resep['image'],
                                                jenis: resep['jenis'],
                                                listLike: resep['likes'],
                                                countLikes:
                                                    resep['countLikes']);
                                          }),
                                        );
                                        if (result != null && result) {
                                          scaffoldState.currentState
                                              .showSnackBar(SnackBar(
                                            content: Text('Selesai'),
                                          ));
                                          setState(() {});
                                        }
                                      } else if (value == 'hapus') {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Anda Yakin'),
                                              content: Text(
                                                  'Apakah anda akan menghapus resep ${resep['nama']}?'),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('Tidak'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                FlatButton(
                                                  child: Text('Hapus'),
                                                  onPressed: () {
                                                    document.reference.delete();
                                                    Navigator.pop(context);
                                                    setState(() {});
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Icon(Icons.more_vert),
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
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () async {
            bool result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddResScreen(isEdit: false)));
            if (result != null && result) {
              scaffoldState.currentState.showSnackBar(SnackBar(
                content: Text('Selesai'),
              ));
              setState(() {});
            }
          },
        ),
      );
    }
  }
}
