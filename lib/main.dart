import 'package:flutter/material.dart';
import 'package:tag_input_field_example/tag_input_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tag input field"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            children: [
              Text("Type and place comma at end"),
              SizedBox(height: 24),
              SizedBox(
                width: double.maxFinite,
                child: TagInputField(
                  hint: "Tags",
                  onBeforeTagAdded: (_)=>true,
                  onBeforeTagsAdded: (_)=>true,
                  onItemWillBeDeleted: (_)=>true,
                  onTagAdded: (_){},
                  onTagsAdded: (_){},
                  onTagDeleted: (_){},
                  autocomplete: true,
                  optionBuilder: (tev){
                    var text = tev.text;
                    if(text.isEmpty){
                      return [];
                    }
                    return [
                      "$text 1",
                      "$text 2",
                      "$text 3",
                      "$text 4",
                    ];
                  },
                ),
              ),
            ],
          ),
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
