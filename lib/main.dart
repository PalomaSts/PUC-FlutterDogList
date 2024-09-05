import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(DogApp());
}

class DogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DogListScreen(),
    );
  }
}

// Tela inicial que exibe a lista de imagens dos cachorros
class DogListScreen extends StatefulWidget {
  @override
  _DogListScreenState createState() => _DogListScreenState();
}

class _DogListScreenState extends State<DogListScreen> {
  List<dynamic> _dogs = [];
  bool _loading = true;

  // Substitua 'YOUR_API_KEY' pela sua chave da API
  final String _apiKey = 'live_1QDOguxB6tzsuuShKuRg3gjBYjhhOS65zWFiRPINdsXLuGHE4OLpPXXc6puYd8gv';

  // Função para buscar dados da API
  Future<void> fetchDogs() async {
    final response = await http.get(
      Uri.parse('https://api.thedogapi.com/v1/breeds'),
      headers: {
        'x-api-key': _apiKey,  // Incluindo a chave da API no cabeçalho
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _dogs = json.decode(response.body);
        _loading = false;
      });
    } else {
      throw Exception('Falha ao carregar os dados');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dog List'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Define 2 colunas
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              padding: const EdgeInsets.all(10.0),
              itemCount: _dogs.length,
              itemBuilder: (context, index) {
                final dog = _dogs[index];
                final imageUrl = dog['image'] != null ? dog['image']['url'] : null; // Verificação de null

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DogDetailScreen(dog: dog),
                      ),
                    );
                  },
                  child: GridTile(
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          )
                        : Center(child: Text('Imagem não disponível')), // Mostra texto caso não tenha imagem
                  ),
                );
              },
            ),
    );
  }
}

// Tela de detalhes do cachorro
class DogDetailScreen extends StatelessWidget {
  final dynamic dog;

  DogDetailScreen({required this.dog});

  @override
  Widget build(BuildContext context) {
    final breed = dog;
    final imageUrl = dog['image'] != null ? dog['image']['url'] : null; // Verificação de null

    return Scaffold(
      appBar: AppBar(
        title: Text('Dog Details'),
      ),
      body: breed != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: imageUrl != null
                      ? Image.network(imageUrl)
                      : Text('Imagem não disponível'), // Mostra texto caso não tenha imagem
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Raça: ${breed['name']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Temperamento: ${breed['temperament']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Expectativa de Vida: ${breed['life_span']}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Peso: ${breed['weight']['metric']} kg',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'Sem informações adicionais para este cachorro.',
                style: TextStyle(fontSize: 18),
              ),
            ),
    );
  }
}
