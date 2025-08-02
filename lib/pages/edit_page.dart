import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPage extends StatefulWidget {
  final String editData;
  final int id;
  const EditPage({super.key, required this.editData, required this.id});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  SupabaseClient supabase = Supabase.instance.client;

  Future<void> updateData() async {
    if (titleController.text.isNotEmpty && titleController.text != '') {
      setState(() {
        isLoading = true;
      });
      try {
        await supabase
            .from('todos')
            .update({'title': titleController.text}).match({'id': widget.id});
        Navigator.pop(context);
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong"),
          ),
        );
      }
    }
  }

  Future<void> removeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await supabase.from('todos').delete().match({'id': widget.id});
      if (mounted) {
        Navigator.pop(context, 'remove');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong"),
        ),
      );
    }
  }

  @override
  void initState() {
    titleController.text = widget.editData;
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Data"),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter the title",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: updateData,
                          child: const Text("update"),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Divider(),
                      ElevatedButton.icon(
                        onPressed: removeData,
                        label: Text("Delete"),
                        icon: const Icon(Icons.delete),
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(Colors.red),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.white)),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
