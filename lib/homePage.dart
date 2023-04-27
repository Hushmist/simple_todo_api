import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/api.dart';
import 'loginV2.dart';

void main() => runApp(const MainPage());

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.deepOrangeAccent,
      ),
      home: const _HomeWidget(),
    );
  }
}

class _HomeWidget extends StatefulWidget {
  const _HomeWidget({super.key});

  @override
  State<_HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<_HomeWidget> {
  List todoList = [];

  @override
  void initState() {
    _loadUserData();
    _getTodo();
    super.initState();
    // todoList.addAll([
    //   ['Buy milk', 'Buy milk'],
    //   ['Repair phone', 'Buy milk']
    // ]);
  }

  String? name;
  String? _userToDo;
  String? _userBody;

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user')!);

    if (user != null) {
      setState(() {
        name = user['name'];
      });
    }
  }

  _getTodo() async {
    var res;
    var body;
    res = await Network().getData('/todo');
    body = jsonDecode(res.body);
    if (body['statusCode'] == 200) {
      todoList.clear();
      setState(() {
        body['data'].forEach((var todo) {
          todoList.add([todo['id'], todo['title'], todo['body']]);
        });
      });
    }
  }

  void _sentTodo() async {
    var data = {'title': _userToDo, 'body': _userBody};
    var res = await Network().postData('/todo', data);
    var body = json.decode(res.body);
    print(body);
    if (body['statusCode'] == 200) {
      _getTodo();
    }
  }

  void _deleteTodo(taskId) async {
    var data = {'task_id': taskId};

    var res = await Network().postData('/todo/destroy', data);
    var body = json.decode(res.body);
    if (body['statusCode'] == 200) {
      _getTodo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        title: const Text('Todo'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: todoList.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(todoList[index][1]),
            child: Card(
              child: ListTile(
                title: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(todoList[index][1]),
                                const Divider(height: 5.0),
                                Text(todoList[index][2] ?? ''),
                              ],
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              )
                            ],
                          );
                        },
                      );
                    },
                    child: Text(todoList[index][1])),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_sweep,
                    color: Colors.deepOrangeAccent,
                  ),
                  onPressed: () {
                    _deleteTodo(todoList[index][0]);
                    _getTodo();
                  },
                ),
              ),
            ),
            onDismissed: (direction) {
              setState(() {
                _deleteTodo(todoList[index][0]);
                _getTodo();
                // todoList.removeAt(index);
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add elemnt'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (String value) {
                        _userToDo = value;
                      },
                    ),
                    TextField(
                      onChanged: (String value) {
                        _userBody = value;
                      },
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      if (_userToDo == null || _userToDo!.isEmpty) {
                        return;
                      }
                      setState(() {
                        _sentTodo();
                        _getTodo();
                      });
                      _userToDo = null;
                      Navigator.of(context).pop();
                    },
                    child: const Text('Add'),
                  )
                ],
              );
            },
          );
        },
        backgroundColor: Colors.greenAccent,
        child: const Icon(
          Icons.add_box,
          color: Colors.white,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(name!),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void logout() async {
    var res = await Network().getData('/logout');
    var body = json.decode(res.body);
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    localStorage.remove('user');
    localStorage.remove('token');
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }
}
