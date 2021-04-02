
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olx/views/Anuncios.dart';
import 'package:olx/views/DetalhesAnuncio.dart';
import 'package:olx/views/Login.dart';
import 'package:olx/views/MeusAnuncios.dart';
import 'package:olx/views/NovoAnuncio.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings){

    final args = settings.arguments;

    switch(settings.name){
      case "/":
        return MaterialPageRoute(
          builder: (_) => Anuncios()
        );
      break;
      case "/login":
        return MaterialPageRoute(
            builder: (_) => Login()
        );
      break;
      case "/meus-anuncios":
        return MaterialPageRoute(
            builder: (_) => MeusAnuncios()
        );
      break;
      case "/novo-anuncio":
        return MaterialPageRoute(
            builder: (_) => NovoAnuncio()
        );
      break;
      case "/detalhes-anuncio":
        return MaterialPageRoute(
            builder: (_) => DetalhesAnuncio(args)
        );
      break;
      default:
        _erroRota();
    }

  }

  static Route<dynamic> _erroRota(){

     return MaterialPageRoute(
       builder: (_){
          return Scaffold(
            appBar: AppBar(
              title: Text("Tela não encontrada!"),
            ),
            body: Text("Tela não encontrada!"),
          );
       }
     );

  }

}