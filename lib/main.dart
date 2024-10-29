import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter CRUD Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const UserListPage(title: 'Flutter CRUD User List'),
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key, required this.title});

  final String title;

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final String apiUrl = 'https://crudcrud.com/api/unique-endpoint-id/users';
  List<dynamic> _users = [];

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      setState(() {
        _users = json.decode(response.body);
      });
    }
  }

  Future<void> deleteUser(String id) async {
    await http.delete(Uri.parse('$apiUrl/$id'));
    fetchUsers();
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserFormPage()),
            ).then((_) => fetchUsers()),
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            final user = _users[index];
            return ListTile(
              title: Text('${user['nome']} ${user['sobrenome']}'),
              subtitle: Text(user['email']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserFormPage(user: user),
                        ),
                      ).then((_) => fetchUsers());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteUser(user['_id']),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class UserFormPage extends StatefulWidget {
  final dynamic user;
  const UserFormPage({super.key, this.user});

  @override
  _UserFormPageState createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final String apiUrl = 'https://crudcrud.com/api/unique-endpoint-id/users';

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nomeController.text = widget.user['nome'];
      _sobrenomeController.text = widget.user['sobrenome'];
      _emailController.text = widget.user['email'];
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = {
        'nome': _nomeController.text,
        'sobrenome': _sobrenomeController.text,
        'email': _emailController.text,
      };

      if (widget.user == null) {
        await http.post(Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(user));
      } else {
        await http.put(Uri.parse('$apiUrl/${widget.user['_id']}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(user));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulário de Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sobrenomeController,
                decoration: const InputDecoration(labelText: 'Sobrenome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o sobrenome';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
