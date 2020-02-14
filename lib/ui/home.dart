import 'package:flutter/material.dart';
import 'package:giphy_developers/ui/gifPage.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _search = '';
  int _offset = 0;
  var _searchControll = TextEditingController();

  Future<Map> _getGifs() async {
    http.Response response;

    // Se search estiver vazia busca os trending tops gifs
    if (_search == '') {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/trending?api_key=pnwKzuC5xn4Sh1TPJmqcZo0784W8DLvv&limit=25&rating=G');
    } else {
      response = await http.get(
          'https://api.giphy.com/v1/gifs/search?api_key=pnwKzuC5xn4Sh1TPJmqcZo0784W8DLvv&q=$_search&limit=25&offset=$_offset&rating=G&lang=pt');
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchControll,
                    decoration: InputDecoration(
                      labelText: "Pesquiser gifs",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchControll.text = '';
                          });
                        },
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                    onSubmitted: (text) {
                      setState(() {
                        _search = text;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Container(
                      height: 200,
                      width: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  default:
                    if (snapshot.hasError)
                      return Container();
                    else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ],
      ),
    );
  }

  // -----
  // Caso _search == null retorna tamanho de data e mostra os trendind top
  // Caso _search +! null, ou seja, uma pesquisa foi feita, retorna o tamanaho
  // de date +1 para que dentro do contexto possa usar essa logica para
  // mostrar 1 botão de carregar mais no fim da lista de gifs. O itemCount
  // tera 1 a mais que o tamnaho de data
  int _getCount(List data) {
    if (_search == '') {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        // GestureDetector permite que a imagem seja clicada
        // assim podendo ter uma ação para o clic
        if (_search == '' || index < snapshot.data['data'].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data['data'][index])));
            },
            onLongPress: () => Share.share(
                snapshot.data['data'][index]['images']['fixed_height']['url']),
          );
        } else {
          return Container(
              child: GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                Text(
                  'Carregas mais',
                  style: TextStyle(color: Colors.white, fontSize: 22.0),
                )
              ],
            ),
            onTap: () {
              setState(() {
                _offset = 25;
              });
            },
          ));
        }
      },
    );
  }
}
