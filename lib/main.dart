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
    return const MaterialApp(
      title: 'Busca de Usuários',
      home: UserSearchPage(),
    );
  }
}

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
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
    if (id == null || id < 1 || id > 12) {
      setState(() {
        errorMessage = 'Por favor, insira um ID entre 1 e 12.';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Digite o ID do usuário (1 a 12)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onSearch,
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (name != null && email != null && avatarUrl != null)
              Column(
                children: [
                  Image.network(avatarUrl!),
                  const SizedBox(height: 10),
                  Text('Nome: $name'),
                  Text('Email: $email'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}