import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

final List<Map<String, dynamic>> imcs = []; //guardar entrada de dados em uma lista provisória

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/imcs', _listarImcs)
  ..get('/imcs/<id>', _buscarImc)
  ..post('/imcs', _cadastrarImc);
  
Response _listarImcs(Request request) {

  return Response.ok(
    jsonEncode(imcs));
}
Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _buscarImc(Request request) {
  final id = int.parse(request.params['id']!);

  try {
    final resultado = imcs.firstWhere(
      (item) => item['id'] == id,
    );

    return Response.ok(
      jsonEncode(resultado),
    );
  } catch (e) {
    return Response.notFound(
      jsonEncode({
        'erro': 'ID não encontrado',
      }),
    );
  }
}


Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}
Future<Response> _cadastrarImc(Request request) async {
  final body =await request.readAsString();
  print(body);
  final dados = jsonDecode(body);
  
  final nome = dados['nome'];
  final altura = dados['altura'];
  final peso = dados['peso'];
  
  final imc = peso/(altura*altura);
  

  String classificacao;
  if (imc < 18.5) {
  classificacao = 'Você está abaixo do peso ideal';
} else if (imc < 25) {
  classificacao = 'Você está no peso adequado';
} else if (imc < 30) {
  classificacao = 'Você está com sobrepeso';
} else if (imc < 35) {
  classificacao = 'Você está em Obesidade grau I';
} else if (imc < 40) {
  classificacao = 'Você está em Obesidade grau II';
} else {
  classificacao = 'Você está em Obesidade grau III';
}

  final id = imcs.length + 1;

  final resultado = {
  'id': id,
  'nome': nome,
  'altura': altura,
  'peso': peso,
  'imc': imc,
  'classificacao': classificacao,
};
 imcs.add(resultado);
  return Response.ok(jsonEncode(resultado));
  

}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;
  
  // Configure a pipeline that logs requests.
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
