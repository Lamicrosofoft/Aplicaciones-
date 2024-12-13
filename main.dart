import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(
        primaryColor: Color(0xFF6A0572),
        hintColor: Color(0xFFD81159),
        scaffoldBackgroundColor: Color(0xFF2A1B3D),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Color(0xFF9A1F60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF4B2142),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          labelStyle: TextStyle(color: Colors.white70),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  List<Map<String, dynamic>> users = [
    {
      'username': 'Lam',
      'password': '1234',
      'fullname': 'Luis Dario Perez Lam',
      'role': 'admin',
      'cuenta': 20166562,
      'beca': 'Peña Colorada',
      'photo': null,
    },
    {
      'username': 'Luis',
      'password': '5678',
      'fullname': 'Luis Lam',
      'role': 'user',
      'cuenta': 20166564,
      'beca': 'Coca Cola',
      'photo': null,
    },
  ];

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int failedAttempts = 0;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsers = prefs.getString('usuarios');
    if (storedUsers != null) {
      setState(() {
        users = List<Map<String, dynamic>>.from(jsonDecode(storedUsers));
      });
    } else {
      _saveUsers();
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('usuarios', jsonEncode(users));
  }

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    final user = users.firstWhere(
      (user) =>
          user['username'] == username && user['password'] == password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      setState(() {
        errorMessage = '';
        failedAttempts = 0;
      });
      if (user['role'] == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminScreen(users: users, saveUsers: _saveUsers),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserScreen(users: users, saveUsers: _saveUsers),
          ),
        );
      }
    } else {
      setState(() {
        failedAttempts++;
        errorMessage = 'Usuario o contraseña incorrectos';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Inicio de sesión',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Entrar'),
            ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final Function saveUsers;

  AdminScreen({required this.users, required this.saveUsers});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  void _navigateToAddUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddUserScreen(
          users: widget.users,
          saveUsers: widget.saveUsers,
        ),
      ),
    );
  }

  // Función para eliminar usuario (solo admin puede hacerlo)
  void _deleteUser(int index) {
    setState(() {
      if (widget.users[index]['role'] == 'user') {
        widget.users.removeAt(index);
        widget.saveUsers();
      }
    });
  }

  // Función para editar usuario
  void _editUser(int index) {
    var user = widget.users[index];
    TextEditingController usernameController = TextEditingController(text: user['username']);
    TextEditingController passwordController = TextEditingController(text: user['password']);
    TextEditingController fullnameController = TextEditingController(text: user['fullname']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Usuario'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
              ),
              TextField(
                controller: fullnameController,
                decoration: InputDecoration(labelText: 'Nombre Completo'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.users[index] = {
                    'username': usernameController.text,
                    'password': passwordController.text,
                    'fullname': fullnameController.text,
                    'role': user['role'],  // No se modifica el rol
                    
                  };
                });
                widget.saveUsers();
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Usuarios'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          return Card(
            color: Color(0xFF3E1E3C),
            child: ListTile(
              title: Text(
                widget.users[index]['fullname'] ?? '',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                widget.users[index]['username'],
                style: TextStyle(color: Colors.white70),
              ),
              trailing: PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Text('Eliminar'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 1) {
                    _editUser(index); // Editar usuario
                  } else if (value == 2) {
                    _deleteUser(index); // Eliminar usuario
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddUser,
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).hintColor,
      ),
    );
  }
}

class UserScreen extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final Function saveUsers;

  UserScreen({required this.users, required this.saveUsers});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  void _navigateToAddBecario() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBecarioScreen(
          users: widget.users,
          saveUsers: widget.saveUsers,
        ),
      ),
    );
  }

  // Función para eliminar becario
  void _deleteBecario(int index) {
    setState(() {
      widget.users[index]['beca'] = null; // Eliminar solo la beca
    });
    widget.saveUsers();
  }

  // Función para editar becario
  void _editBecario(int index) {
    var becario = widget.users[index];
    TextEditingController cuentaController = TextEditingController(text: becario['cuenta'].toString());
    TextEditingController fullnameController = TextEditingController(text: becario['fullname']);
    String? selectedBeca = becario['beca'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Becario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cuentaController,
                decoration: InputDecoration(labelText: 'No. de Cuenta'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fullnameController,
                decoration: InputDecoration(labelText: 'Nombre Completo'),
              ),
              DropdownButtonFormField<String>(
                value: selectedBeca,
                items: [
                  'Inscripción',
                  'Coca Cola',
                  'Peña Colorada',
                  'Transporte',
                  'Alimentos'
                ].map((beca) {
                  return DropdownMenuItem<String>(

                    value: beca,
                    child: Text(beca, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBeca = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Beca'),
                dropdownColor: Color(0xFF4B2142),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.users[index] = {
                    'username': becario['username'],
                    'password': becario['password'],
                    'fullname': fullnameController.text,
                    'role': becario['role'],  // No se modifica el rol
                    'cuenta': int.tryParse(cuentaController.text) ?? becario['cuenta'],
                    'beca': selectedBeca,
                    'photo': becario['photo'],
                  };
                });
                widget.saveUsers();
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Becarios'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        itemCount: widget.users.length,
        itemBuilder: (context, index) {
          return Card(
            color: Color(0xFF3E1E3C),
            child: ListTile(
              title: Text(
                widget.users[index]['fullname'] ?? '',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                widget.users[index]['beca'] ?? 'Sin beca',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) => [
                  PopupMenuItem<int>(
                    value: 1,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Text('Eliminar'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 1) {
                    _editBecario(index); // Editar becario
                  } else if (value == 2) {
                    _deleteBecario(index); // Eliminar becario
                  }
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddBecario,
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).hintColor,
      ),
    );
  }
}

class AddUserScreen extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final Function saveUsers;

  AddUserScreen({required this.users, required this.saveUsers});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  

  void _addUser() {
    setState(() {
      widget.users.add({
        'username': _usernameController.text,
        'password': _passwordController.text,
        'fullname': _fullnameController.text,
        'role': 'user',
        
      });
    });
    widget.saveUsers();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            TextField(
              controller: _fullnameController,
              decoration: InputDecoration(labelText: 'Nombre Completo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addUser,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddBecarioScreen extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final Function saveUsers;

  AddBecarioScreen({required this.users, required this.saveUsers});

  @override
  _AddBecarioScreenState createState() => _AddBecarioScreenState();
}

class _AddBecarioScreenState extends State<AddBecarioScreen> {
  final TextEditingController _cuentaController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  String? _selectedBeca;

  void _addBecario() {
    final user = widget.users.firstWhere(
      (user) => user['fullname'] == _fullnameController.text,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      setState(() {
        user['cuenta'] = int.tryParse(_cuentaController.text) ?? 0;
        user['beca'] = _selectedBeca;
      });
      widget.saveUsers();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El usuario no está registrado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Becario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fullnameController,
              decoration: InputDecoration(labelText: 'Nombre Completo'),
            ),
            TextField(
              controller: _cuentaController,
              decoration: InputDecoration(labelText: 'No. Cuenta'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _selectedBeca,
              items: [
                'Inscripción',
                'Coca Cola',
                'Peña Colorada',
                'Transporte',
                'Alimentos'
              ].map((beca) {
                return DropdownMenuItem<String>(
                  value: beca,
                  child: Text(beca),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBeca = value;
                });
              },
              decoration: InputDecoration(labelText: 'Beca'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addBecario,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
