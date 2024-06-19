import 'package:crud_example/sql_helper.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLITE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> journals = [];
  bool isLoading = true;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void refreshJournals() async {
    final data = await SqlHelper.getItems();
    setState(() {
      journals = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    refreshJournals();
    print("nb items: ${journals.length}");
  }

  Future<void> _addItem() async {
    await SqlHelper.createItem(
        titleController.text, descriptionController.text);
    refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SqlHelper.updateItem(
        id, titleController.text, descriptionController.text);
    refreshJournals();
  }

  Future<void> _deleteItem(int id) async {
    await SqlHelper.deleteItem(id);
    //Mettre le show dialog du tuto shop_app_flutter > pages > cart_page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully deleted'),
      ),
    );
    refreshJournals();
  }

  void showForm(int? id) async {
    if (id != null) {
      //.firstWhere method pour une map
      //comme .length pour une liste

      //existingJournal devient un Map<String, dynamic>
      //car on l'initialise avec un element de journals
      //journals c'est une liste
      //mais un element de journal c'est une Map<String, dynamic>
      final existingJournal =
          journals.firstWhere((element) => element['id'] == id);
      titleController.text = existingJournal['title'];
      descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      //le _ c'est le BuildContext context
      builder: (_) => Container(
        padding: EdgeInsets.only(
            top: 15.0,
            right: 15.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
            left: 15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addItem();
                  }
                  if (id != null) {
                    await _updateItem(id);
                  }

                  titleController.text = '';
                  descriptionController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create a new one' : 'Update'))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL'),
      ),
      //show les données dans la database
      body: ListView.builder(
          itemCount: journals.length,
          itemBuilder: (context, index) {
            final journal = journals[index];
            return Card(
              color: Colors.orange,
              margin: const EdgeInsets.all(15),
              child: ListTile(
                title: Text(journal['title']),
                subtitle: Text(journal['description']),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => showForm(journal['id']),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => _deleteItem(journal['id']),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add), onPressed: () => showForm(null)),
    );
  }
}
