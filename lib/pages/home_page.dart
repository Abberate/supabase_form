import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_form/pages/upload_page.dart';

import 'create_page.dart';
import 'edit_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Stream<List<Map<String, dynamic>>> _readStrem;

  Future<List> readData() async {
    var userId = supabase.auth.currentUser!.id;
    final result = supabase
        .from("todos")
        .select()
        .eq('user_id', userId)
        .order('id', ascending: false);
    return result;
  } //non stream

  Stream<List<Map<String, dynamic>>> buildStream() {
    final userId = supabase.auth.currentUser!.id;
    return supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('id', ascending: false);
  }

  @override
  void initState() {
    _readStrem = buildStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Supabase flutter",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadPage(),
                  ),
                );
              },
              icon: Icon(
                Icons.upload_file,
                color: Colors.white,
              )),
          IconButton(
            onPressed: () async {
              await supabase.auth.signOut();
            },
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: StreamBuilder(
          stream: _readStrem,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              final userId = supabase.auth.currentUser!.id;
              final filteredData = snapshot.data.toList();

              if (filteredData.isEmpty) {
                return const Center(child: Text("No Data available Now"));
              }

              return ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final data = filteredData[index];
                  return ListTile(
                    title: Text(data['title']),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.red),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPage(
                              editData: data['title'],
                              id: data['id'],
                            ),
                          ),
                        );

                        // Si supprimé, on force un refresh via setState
                        if (result == 'remove') {
                          setState(() {
                            _readStrem = buildStream();
                          });
                        }
                      },
                    ),
                  );
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePage(),
            ),
          );
        },
      ),
    );
  }
}
/*FutureBuilder(
          future: readData(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  snapshot.error.toString(),
                ),
              );
            }

            if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return const Center(
                  child: Text("Nos Data available Now"),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, int index) {
                    var data = snapshot.data[index];
                    return ListTile(
                      title: Text(data['title']),
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditPage(
                                  editData: data['title'], id: data['id']),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.red,
                        ),
                      ),
                    );
                  });
            }

            return Center(child: CircularProgressIndicator());
          }),*/

/* autre example de stream
  void listenToTodos() {
    final userId = supabase.auth.currentUser!.id;

    supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('id', ascending: false)
        .listen((data) {
          setState(() {
            todos = data; // met à jour la liste avec les données temps réel
          });
        });
  }
 */
