//parte responsavel por recuperar dados

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/pages/todo_list_page.dart';

const todoListKey = 'todo_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;

//ler lista
  Future<List<Todo>> getTodoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecode = json.decode(jsonString) as List;
    return jsonDecode.map((e) => Todo.fromJson(e)).toList();
  }

//responsavel por salvar
  void saveTodoList(List<Todo> todos) {
    final String jsonString = jsonEncode(todos);
    sharedPreferences.setString(todoListKey, jsonString);
  }
}
