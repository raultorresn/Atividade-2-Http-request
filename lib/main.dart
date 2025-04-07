import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      title: 'Busca de Usuários',
      home: const UserSearchPage(),
    );
  }
}

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  bool emptyInput = false;
  final TextEditingController _controller = TextEditingController();
  String? name;
  String? email;
  String? avatarUrl;
  String? errorMessage;
  bool isLoading = false;

  Future<void> fetchUser(int id) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      name = null;
      email = null;
      avatarUrl = null;
    });

    try {
      final response = await http.get(Uri.parse('https://reqres.in/api/users/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = data['data'];

        setState(() {
          name = '${user['first_name']} ${user['last_name']}';
          email = user['email'];
          avatarUrl = user['avatar'];
        });
      } else if (response.statusCode == 404) {
        setState(() {
          errorMessage = 'Usuário não encontrado!';
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao buscar usuário. Código: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro de rede ou conexão.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onSearch() {
    final input = _controller.text.trim();
    final id = int.tryParse(input);

    setState(() {
      emptyInput = input.isEmpty;
    });

    if (emptyInput) return;

    if (id == null || id < 1 || id > 12) {
      setState(() {
        errorMessage = 'Usuário não encontrado!';
        name = null;
        email = null;
        avatarUrl = null;
      });
    } else {
      fetchUser(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Busca de Usuários')),
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.network(
              'https://wallpapercave.com/wp/wp6506037.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  if (isLoading) const CircularProgressIndicator(),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  if (name != null && email != null && avatarUrl != null)
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(avatarUrl!),
                        ),
                        const SizedBox(height: 10),
                        Text('Nome: $name', style: TextStyle(color: Colors.white, fontSize: 18)),
                        Text('Email: $email', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: Colors.blue, // cor da borda e do cursor do TextField
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Digite o ID do usuário (1 a 12)',
                            labelStyle: TextStyle(color: Colors.grey[700]),
                            prefixIcon: Icon(Icons.person_search),
                            border: OutlineInputBorder(

                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            errorText: emptyInput? 'Por favor, digite um ID antes de buscar' : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: onSearch,
                    icon: const Icon(Icons.search),
                    label: const Text(
                      'Buscar',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.lightBlueAccent.shade400,
                      elevation: 6,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}