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
        appBar: AppBar(
          title: Text("Semua Resep"),
        ),
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.blue, spreadRadius: 3),
                              ],
                            ),
                            height: 25,
                            child: FlatButton(
                                child: Text("Semua"),
                                onPressed: () {
                                  setState(() {
                                    filter = null;
                                  });
                                }),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.blue, spreadRadius: 3),
                              ],
                            ),
                            height: 25,
                            child: FlatButton(
                                child: Text("Nasi Goreng"),
                                onPressed: () {
                                  setState(() {
                                    filter = "Nasi Goreng";
                                  });
                                }),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.blue, spreadRadius: 3),
                              ],
                            ),
                            height: 25,
                            child: FlatButton(
                                child: Text("Seblak"),
                                onPressed: () {
                                  setState(() {
                                    filter = "Seblak";
                                  });
                                }),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: filter == null
                            ? firestore
                                .collection('resep')
                                .where('userId', isEqualTo: userId)
                                .snapshots()
                            : firestore
                                .collection('resep')
                                .where('userId', isEqualTo: userId)
                                .where('jenis', isEqualTo: filter)
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
                                    children: <Widget>[
                                      Text(
                                        resep['keterangan'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        resep['jenis'],
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
                                              image: resep['image'],
                                              jenis: resep['jenis'],
                                              listLike: resep['likes'],
                                              countLikes: resep['countLikes']
                                            );
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
