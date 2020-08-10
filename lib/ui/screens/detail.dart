import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final String documentId;
  final String nama;
  final String keterangan;
  final String image;
  final String jenis;

  DetailScreen(
      {this.documentId, this.nama, this.keterangan, this.image, this.jenis});
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Detail Resep"),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 200,
                child: Image.network(widget.image),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: <Widget>[Text("Nama Resep : "), Text(widget.nama)],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                children: <Widget>[
                  Text("Kategori Resep : "),
                  Text(widget.jenis)
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Text("Keterangan dan Bahan"),
              SizedBox(
                height: 10,
              ),
              Text(widget.keterangan)
            ],
          ),
        ),
      )),
    );
  }
}
