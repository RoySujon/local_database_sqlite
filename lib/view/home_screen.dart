import 'package:flutter/material.dart';
import 'package:local_database/sql_helper/sql_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _journal = [];
  bool _isLoading = true;

  void _refreshJournal() async {
    final data = await SQLHelper.getAllItems();
    setState(() {
      _journal = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _refreshJournal();
  }

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
//Add Item
  Future<void> addItem() async {
    if (_descriptionController.text.isNotEmpty) {
      await SQLHelper.createItem(
          _titleController.text.isNotEmpty
              ? _titleController.text
              : 'Unknown Person',
          _descriptionController.text,
          _phoneController.text);
      _titleController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    }

    _refreshJournal();
    print(_journal.length.toString());
  }

//Update Iteme
  Future<void> updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleController.text,
        _descriptionController.text, _phoneController.text);
    _refreshJournal();
    _titleController.clear();
    Navigator.pop(context);
    _descriptionController.clear();
    print(_journal.length.toString());
  }

  void _showForm(int? id) {
    if (id != null) {
      final existingJournal =
          _journal.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(hintText: 'Title'),
          ),
          SizedBox(height: 40),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(hintText: 'Description'),
          ),
          SizedBox(height: 40),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(hintText: 'Phone'),
          ),
          SizedBox(height: 40),
          TextButton(
            onPressed: () async {
              if (id == null) {
                await addItem();
              } else {
                await updateItem(id);
              }
            },
            child: Text(id == null ? 'Add New Items' : 'Update Data'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(_journal.length.toString());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(null);
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (context) {
                    final _passwordController = TextEditingController();
                    return AlertDialog(actions: [
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(hintText: 'Pasword'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel')),
                          TextButton(
                              onPressed: () async {
                                if (_passwordController.text.trim() ==
                                    '12345') {
                                  final db = await SQLHelper.db();
                                  db.delete('items');
                                  _refreshJournal();
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: Text('OK'))
                        ],
                      )
                    ]);
                  },
                );
              },
              icon: Icon(Icons.delete_sharp))
        ],
        title: Text('SQLITE DB'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => Card(
          child: ListTile(
            onLongPress: () {
              _showForm(_journal[index]['id']);
              _refreshJournal();
            },
            leading: CircleAvatar(
              child: Text(_journal[index]['title'] != null
                  ? _journal[index]['title'].toString().characters.first
                  : 'ABC'.characters.first),
            ),
            title: Text(_journal[index]['title'].toString()),
            subtitle: Text(_journal[index]['description'].toString()),
            trailing: IconButton(
                onPressed: () {
                  SQLHelper.deleteItem(_journal[index]['id'])
                      .then((value) => _refreshJournal());
                },
                icon: Icon(Icons.delete)),
          ),
        ),
        itemCount: _journal.length,
      ),
    );
  }
}
