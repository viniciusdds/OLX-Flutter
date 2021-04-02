import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/util/Configuracoes.dart';
import 'package:olx/views/widgets/ItemAnuncio.dart';
import 'package:olx/main.dart';

class Anuncios extends StatefulWidget {
  @override
  _AnunciosState createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {

  List<String> itensMenu = [];
  List<DropdownMenuItem<String>> _listaItensDropCategorias;
  List<DropdownMenuItem<String>> _listaItensDropEstados;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  String _itemSelecionadoEstado;
  String _itemSelecionadoCategoria;

  _escolhaMenuItem(String itemEscolhido){

      switch(itemEscolhido){
        case "Meus anúncios":
          Navigator.pushNamed(context, "/meus-anuncios");
        break;
        case "Entrar / Cadastrar":
          Navigator.pushNamed(context, "/login");
        break;
        case "Deslogar":
          _deslogarUsuario();
        break;
      }

  }

  _deslogarUsuario() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.pushNamed(context, "/login");

  }

  Future _verificarUsuarioLogado() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();

    if(usuarioLogado == null){
       itensMenu = [
         "Entrar / Cadastrar"
       ];
    }else{
       itensMenu = [
         "Meus anúncios", "Deslogar"
       ];
    }
  }

  _carregarItensDropdown(){

    //Categorias
    _listaItensDropCategorias = Configuracoes.getCategorias();

    //Estados
    _listaItensDropEstados = Configuracoes.getEstados();
  }

  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {

      Firestore db = Firestore.instance;
      Stream<QuerySnapshot> stream = db
           .collection("anuncios")
           .snapshots();
      
      stream.listen((dados) {
        _controller.add(dados);
      });
  }

  Future<Stream<QuerySnapshot>> _filtrarAnuncios() async {

    Firestore db = Firestore.instance;
    Query query = db.collection("anuncios");

    if(_itemSelecionadoEstado != null){
      query = query.where("estado", isEqualTo:  _itemSelecionadoEstado);
    }

    if(_itemSelecionadoCategoria != null){
      query = query.where("categoria", isEqualTo:  _itemSelecionadoCategoria);
    }


    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });

  }

  @override
  void initState() {
    super.initState();

    _carregarItensDropdown();
    _verificarUsuarioLogado();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {

    var carregandoDados = Center(
      child: Column(
        children: [
          Text("Carregando anúncios"),
          CircularProgressIndicator()
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("OLX"),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
              onSelected: _escolhaMenuItem,
              itemBuilder: (context){
                  return itensMenu.map((String item) {
                    return PopupMenuItem<String>(
                        value: item,
                        child: Text(item),
                    );
                  }).toList();
              }
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [

            Row(
              children: [
                Expanded(
                    child: DropdownButtonHideUnderline(
                      child: Center(
                        child: DropdownButton(
                          iconEnabledColor: temaPadrao.primaryColor,
                          value: _itemSelecionadoEstado,
                          items: _listaItensDropEstados,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.black
                          ),
                          onChanged: (estado){
                            setState(() {
                              _itemSelecionadoEstado = estado;
                              _filtrarAnuncios();
                            });
                          },
                        ),
                      ),
                    )
                ),

                Container(
                  color: Colors.grey[200],
                  width: 2,
                  height: 60,
                ),

                Expanded(
                    child: DropdownButtonHideUnderline(
                      child: Center(
                        child: DropdownButton(
                          iconEnabledColor: temaPadrao.primaryColor,
                          value: _itemSelecionadoCategoria,
                          items: _listaItensDropCategorias,
                          style: TextStyle(
                              fontSize: 22,
                              color: Colors.black
                          ),
                          onChanged: (categoria){
                            setState(() {
                              _itemSelecionadoCategoria = categoria;
                              _filtrarAnuncios();
                            });
                          },
                        ),
                      ),
                    )
                )
              ],
            ),


            StreamBuilder<QuerySnapshot>(
              stream: _controller.stream,
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return carregandoDados;
                  break;
                  case ConnectionState.active:
                  case ConnectionState.done:

                     QuerySnapshot querySnapshot = snapshot.data;

                     if(querySnapshot.documents.length == 0){
                       return Container(
                         padding: EdgeInsets.all(25),
                         child: Text("Nenhum anúncio! :( ", style: TextStyle(
                           fontSize: 20,
                           fontWeight: FontWeight.bold
                         )),
                       );
                     }
                     
                     return Expanded(
                         child: ListView.builder(
                             itemCount: querySnapshot.documents.length,
                             itemBuilder: (_, index){

                               List<DocumentSnapshot> anuncios = querySnapshot.documents.toList();
                               DocumentSnapshot documentSnapshot = anuncios[index];
                               Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                               return ItemAnuncio(
                                 anuncio: anuncio,
                                 onTapItem: (){
                                    Navigator.pushNamed(
                                        context,
                                        "/detalhes-anuncio",
                                        arguments: anuncio
                                    );
                                 },
                               );

                             }
                         )
                     );
                }

                return Container();
              },
            )

          ],
        ),
      ),
    );
  }
}
