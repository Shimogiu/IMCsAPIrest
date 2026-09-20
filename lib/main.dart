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
//Variaveis
String? classificacao;
double? imcResultado;
List<dynamic> listaImcs = [];
Map<String, dynamic>? imcBuscado;
String? mensagemErro;
String? mensagemSucesso;
  
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
     if (resposta.statusCode == 200) {
      setState((){
      imcBuscado = dados;
      mensagemErro = null;
     });
     }
     else {
      setState((){
        imcBuscado = null;
        mensagemErro = 'ID não encontrado';
      });
     }
}
Future<void> deletarImc() async {
  String id= idController.text;

  final resposta = await http.delete(
    Uri.parse('http://10.0.2.2:8080/imcs/$id'),
  );
  final dados = jsonDecode(resposta.body);
  if (resposta.statusCode == 200){
    setState((){
      mensagemSucesso = dados['mensagem'];
      mensagemErro = null;
      });
      
      await listarImcs(); // espere o get do delete atualizar 

      }else {
        setState(() {
          mensagemErro = dados['erro'];
          mensagemSucesso = null;
          
        });
  
  }
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
            buscarImc();
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
         
          ElevatedButton(onPressed: (){
            deletarImc();
          },
          child: Text('Deletar IMCs'),
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

          if (mensagemErro != null)
         Text(mensagemErro!),

          if (mensagemSucesso !=null)
          Text (mensagemSucesso!),
          
          if (imcBuscado != null)
        Card(
        child: Column(
        children: [
        Text('ID: ${imcBuscado!['id']}'),
        Text('Nome: ${imcBuscado!['nome']}'),
        Text('Altura: ${imcBuscado!['altura']}'),
        Text('Peso: ${imcBuscado!['peso']}'),
        Text('IMC: ${imcBuscado!['imc']}'),
        Text('Classificação: ${imcBuscado!['classificacao']}'),
      ],
    ),
  ),
],
  ),
    );
  }
}