import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:myChef/models/state.dart';
import 'package:myChef/ui/screens/sign_in.dart';
import 'package:myChef/utils/state_widget.dart';

class AddResScreen extends StatefulWidget {
  final bool isEdit;
  final String documentId;
  final String nama;
  final String keterangan;
  final String kategori;
  final String image;
  final String jenis;
  List<dynamic> listLike;
  int countLikes;

  AddResScreen(
      {@required this.isEdit,
      this.listLike,
      this.kategori = '',
      this.documentId = '',
      this.nama = '',
      this.keterangan = '',
      this.image = '',
      this.jenis = '',
      this.countLikes});

  @override
  _AddResScreenState createState() => _AddResScreenState();
}

class _AddResScreenState extends State<AddResScreen> {
  File _image;
  String urlImage;
  StateModel appState;
  String jenis;
  List<dynamic> likess;
  bool _loadingVisible = false;
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  final Firestore firestore = Firestore.instance;
  final TextEditingController controllernama = TextEditingController();
  final TextEditingController controllerkategori = TextEditingController();
  final TextEditingController controllerketerangan = TextEditingController();
  List _listJenis = ["Indonesian Food", "Chinese Food"];

  double widthScreen;
  double heightScreen;
  bool isLoading = false;

  @override
  void initState() {
    if (widget.isEdit) {
      controllernama.text = widget.nama;
      controllerketerangan.text = widget.keterangan;
      controllerkategori.text = widget.kategori;
      urlImage = widget.image;
      jenis = widget.jenis;
      likess = widget.listLike;
    }
    super.initState();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
      print('Image Path $_image');
    });
  }

  Future uploadPic(BuildContext context) async {
    String filenama = _image.path.toString();
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(filenama);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    String url = dowurl.toString();
    setState(() {
      urlImage = url;
      Navigator.pop(context);
    });
    return url;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heightScreen = mediaQueryData.size.height;

    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.firebaseUserAuth == null ||
            appState.user == null ||
            appState.settings == null)) {
      return SignInScreen();
    } else {
      if (appState.isLoading) {
        _loadingVisible = true;
      } else {
        _loadingVisible = false;
      }

      final userId = appState?.firebaseUserAuth?.uid ?? '';

      return Scaffold(
        key: scaffoldState,
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Update Resep' : 'Tambah Resep'),
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Container(
                  width: widthScreen,
                  height: heightScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 150.0,
                          height: 150.0,
                          child: (_image != null)
                              ? GestureDetector(
                                  onTap: () {
                                    getImage();
                                  },
                                  child: Image.file(
                                    _image,
                                    fit: BoxFit.fill,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    getImage();
                                  },
                                  child: Image.network(
                                    "https://image.flaticon.com/icons/png/512/48/48639.png",
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                        ),
                      ),
                      (_image != null)
                          ? RaisedButton(
                              child: Text("Upload"),
                              onPressed: () {
                                uploadPic(context);
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return WillPopScope(
                                        onWillPop: () {},
                                        child: AlertDialog(
                                          title: Text(
                                              'Mohon Tunggu Sebentar Sedang Proses Upload'),
                                        ),
                                      );
                                    });
                              },
                            )
                          : Text("Klik Gambar Di Atas Untuk Memilih"),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextField(
                              controller: controllernama,
                              decoration: InputDecoration(
                                labelText: 'Nama Resep',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Jenis Resep"),
                              DropdownButton(
                                hint: Text("Pilih Jenis"),
                                value: jenis,
                                items: _listJenis.map((value) {
                                  return DropdownMenuItem(
                                    child: Text(value),
                                    value: value,
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    jenis = value;
                                  });
                                },
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextField(
                              controller: controllerkategori,
                              decoration: InputDecoration(
                                labelText: 'Kategori',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.0),
                                topRight: Radius.circular(24.0),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              children: <Widget>[
                                TextField(
                                  controller: controllerketerangan,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    labelText: 'Keterangan',
                                  ),
                                ),
                                isLoading
                                    ? Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.all(16.0),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : Container(
                                        width: double.infinity,
                                        color: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 8.0),
                                        child: RaisedButton(
                                          color: Colors.blue,
                                          child: Text(widget.isEdit
                                              ? 'UPDATE RESEP'
                                              : 'TAMBAH RESEP'),
                                          textColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          onPressed: () async {
                                            uploadPic(context);
                                            String nama = controllernama.text;
                                            String keterangan =
                                                controllerketerangan.text;
                                            String kategori =
                                                controllerkategori.text;
                                            if (nama.isEmpty) {
                                              scaffoldState.currentState
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Nama Resep Dibutuhkan'),
                                              ));
                                              return;
                                            } else if (kategori.isEmpty) {
                                              scaffoldState.currentState
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Kategori Resep Dibutuhkan'),
                                              ));
                                              return;
                                            } else if (keterangan.isEmpty) {
                                              scaffoldState.currentState
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Keterangan Dibutuhkan'),
                                              ));
                                              return;
                                            } else if (urlImage == null) {
                                              scaffoldState.currentState
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Klik Tombol Upload Terlebih Dahulu'),
                                              ));
                                              return;
                                            } else if (jenis == null) {
                                              scaffoldState.currentState
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Pilih Kategori Resep Terlebih Dahulu'),
                                              ));
                                              return;
                                            }
                                            setState(() => isLoading = true);
                                            if (widget.isEdit) {
                                              CollectionReference kat =
                                                  firestore
                                                      .collection('kategori');
                                              Map<String, dynamic> postData = {
                                                'kategori': kategori
                                              };
                                              DocumentReference documentTask =
                                                  firestore.document(
                                                      'resep/${widget.documentId}');
                                              firestore.runTransaction(
                                                  (transaction) async {
                                                DocumentSnapshot task =
                                                    await transaction
                                                        .get(documentTask);
                                                if (task.exists) {
                                                  await transaction.update(
                                                    documentTask,
                                                    <String, dynamic>{
                                                      'userId': userId,
                                                      'nama': nama,
                                                      'jenis': jenis,
                                                      'kategori': kategori,
                                                      'keterangan': keterangan,
                                                      'image': urlImage,
                                                      'likes': likess
                                                    },
                                                  );
                                                  await kat
                                                      .document(kategori)
                                                      .setData(postData);
                                                  Navigator.pop(context, true);
                                                }
                                              });
                                            } else {
                                              CollectionReference kat =
                                                  firestore
                                                      .collection('kategori');
                                              CollectionReference resep =
                                                  firestore.collection('resep');
                                              Map<String, dynamic> postData = {
                                                'kategori': kategori
                                              };
                                              DocumentReference result =
                                                  await resep
                                                      .add(<String, dynamic>{
                                                'userId': userId,
                                                'nama': nama,
                                                'jenis': jenis,
                                                'kategori': kategori,
                                                'keterangan': keterangan,
                                                'image': urlImage,
                                                'likes': [userId],
                                                'countLikes': 1
                                              });
                                              await kat
                                                  .document(kategori)
                                                  .setData(postData);
                                              if (result.documentID != null) {
                                                Navigator.pop(context, true);
                                              }
                                            }
                                          },
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
