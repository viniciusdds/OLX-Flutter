import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Configuracoes{

  static List<DropdownMenuItem<String>> getEstados(){

    List<DropdownMenuItem<String>> listaItensDropEstados = [];

    //Categorias
    listaItensDropEstados.add(
        DropdownMenuItem(
            child: Text(
                "Região",
                style: TextStyle(
                  color: Color(0xff9c27b0)
                ),
            ), value: null)
    );

    for(var estado in Estados.listaEstadosSigla){
       listaItensDropEstados.add(
          DropdownMenuItem(child: Text(estado), value: estado)
      );
    }


    return listaItensDropEstados;
  }

  static List<DropdownMenuItem<String>> getCategorias() {

    List<DropdownMenuItem<String>> itensDropCategorias = [];

          itensDropCategorias.add(
              DropdownMenuItem(
                  child: Text(
                    "Categoria",
                    style: TextStyle(
                        color: Color(0xff9c27b0)
                    ),
                  ), value: null)
          );

          Firestore db = Firestore.instance;

          var dados = db.collection("categorias");

          dados.getDocuments().then((value) {
            for(int i=0; i<value.documents.length; i++){
              itensDropCategorias.add(
                  DropdownMenuItem(child: Text(value.documents[i].data["nome"]), value: value.documents[i].data["codigo"])
              );
            }

          });

        return itensDropCategorias;

  }

}