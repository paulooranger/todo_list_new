/*arquivo especifico para informarções na pagina do app tal como:
-manipulação do corpo
-textos
-espaçamentos
-rows,columns e bottons
*/

import 'package:flutter/material.dart';
import 'package:todo_list/models/todo.dart';
import 'package:todo_list/reprositores/todo_repository.dart';

import '../widgets/todo_list_item.dart';

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

final TextEditingController todoController = TextEditingController();
final TodoRepository todoRepository = TodoRepository();

List<Todo> todos = [];
Todo? deletedTodo;
int? deletedTodoPosicao;

@override
class _TodoListState extends State<TodoList> {
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  String? errorText;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Todo List"),
          centerTitle: true,
          backgroundColor: Colors.indigoAccent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //corpo do app
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Adicione uma Tarefa",
                          labelStyle: TextStyle(fontSize: 20),
                          hintText: "Ex: Estudar prova",
                          errorText: errorText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;

                        if (text.isEmpty) {
                          setState(() {
                            errorText = 'Tarefa não pode ser vazio !';
                          });
                          return;
                        }

                        setState(() {
                          errorText = null;
                          Todo newTodo =
                              Todo(title: text, dataTime: DateTime.now());

                          todos.add(newTodo);
                          todoController.clear();
                          todoRepository.saveTodoList(todos);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        primary: Colors.indigoAccent,
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),

                //campo tarefas
                const SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoListItem(todo: todo, onDelete: onDelete),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),

                //n tarefas / clear app
                Row(
                  children: [
                    Expanded(
                      child:
                          Text("Você possui ${todos.length} tarefas pendentes"),
                    ),
                    ElevatedButton(
                      onPressed: dialogApagarTarefas,
                      child: Text("Limpar Tarefas"),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.indigoAccent,
                          padding: const EdgeInsets.all(16)),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    setState(() {
      deletedTodo = todo;
      deletedTodoPosicao = todos.indexOf(todo);
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Tarefa removida com sucesso !',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPosicao!, deletedTodo!);
            });
          },
          textColor: Colors.indigoAccent,
        ),
      ),
    );
  }

  void dialogApagarTarefas() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Deletar todas?"),
        content: Text('Você deseja mesmo apagar todas as tarefas'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              apagarTodas();
            },
            style: TextButton.styleFrom(primary: Colors.blueAccent),
            child: const Text('Confirmar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void apagarTodas() {
    setState(() {
      todos.clear();
      todoRepository.saveTodoList(todos);
    });
  }
}
