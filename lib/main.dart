import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    MaterialApp(
      home: HomePage(),
    ),
  );
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

   @override
  State<HomePage> createState(){
    return _HomePageState();
  }
}
class _HomePageState extends State<HomePage>{

  final nomeController = TextEditingController();
  final alturaController = TextEditingController();
  final pesoController = TextEditingController();
  final idController = TextEditingController();

String? classificacao;
double? imcResultado;
List<dynamic> listaImcs = [];
  
  Future<void> Cadastrar() async {
    String nome= nomeController.text;
    double altura=double.parse(alturaController.text);
    double peso=double.parse(pesoController.text);
    Map<String,dynamic> dados= {
      'nome' :nome,
      'altura': altura,
      'peso' :peso,
    };
    print(dados);
    String json = jsonEncode(dados);
    print(json);
    
    final resposta = await http.post(
  Uri.parse('http://10.0.2.2:8080/imcs'),
  headers: {
    'Content-Type': 'application/json',
  },
  body: json,
);

print(resposta.statusCode);
print(resposta.body);
final resultado = jsonDecode(resposta.body);

setState(() {
  imcResultado = resultado['imc'];
  classificacao = resultado['classificacao'];
});
  }
Future<void> listarImcs() async {
  final resposta = await http.get(
  Uri.parse('http://10.0.2.2:8080/imcs'),
  );
  final dados = jsonDecode(resposta.body);
  setState(() {
    listaImcs= dados;
    
  });
  }
  Future<void> buscarImc() async {
    String id= idController.text;

    final resposta = await http.get(
    Uri.parse('http://10.0.2.2:8080/imcs/$id'),
    );
     final dados=jsonDecode(resposta.body);
}
  
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora IMC')
      ),
      body: Column(
        children:[
          TextField(
            controller: nomeController,
            decoration : InputDecoration(
              labelText: 'Nome',
            ),
          ),
          TextField(
            controller: alturaController,
            decoration : InputDecoration(
              labelText: 'Altura',
            ),
          ),
          TextField(
            controller: pesoController,
            decoration : InputDecoration(
              labelText: 'Peso',
            ),
          ),
          TextField(
            controller: idController,
            decoration: InputDecoration(
            labelText: 'ID',
          ),
          ),
          ElevatedButton(
            onPressed:(){

            },
            child:Text('Buscar por ID'),
            ),
          ElevatedButton( onPressed:(){
            Cadastrar();
          },
            child:Text('Cadastrar'),
          ),
          ElevatedButton(onPressed:(){
            listarImcs();
            },
            child:Text('Listar IMCs'),
          ),
          for (var item in listaImcs)
  Card(
    child: Column(
      children: [
        Text('ID: ${item['id']}'),
        Text('Nome: ${item['nome']}'),
        Text('Altura: ${item['altura']}'),
        Text('Peso: ${item['peso']}'),
        Text('IMC: ${item['imc']}'),
        Text('Classificação: ${item['classificacao']}'),
      ],
    ),
  ),
           if (imcResultado != null)
          Text('IMC: ${imcResultado!.toStringAsFixed(2)}'),

          if (classificacao != null)
          Text('Classificação: $classificacao'),
],
  ),
    );
  }
}