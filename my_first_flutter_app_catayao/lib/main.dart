import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First Flutter App Catayao',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const MyHomePage(title: 'My First Flutter App Catayao'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

 
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter = (_counter ?? 0) + 1;
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter = _counter! - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
       
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
       
        title: Text(widget.title),
      ),
      body: Center(

        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "My First Flutter App Catayao",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            SizedBox(height: 20),
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              '${_counter ?? 0}',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      
       

        


     floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _counter != null && _counter! > 0 ? _decrementCounter : null,
            tooltip: 'Decrement',
            child: const Icon(Icons.arrow_left_sharp),
          ), // FloatingActionButton
          FloatingActionButton(
            onPressed: () => setState(() {
              _counter = 0;
            }),
            tooltip: 'Reset',
            child: const Icon(Icons.restore),
          ), // FloatingActionButton
          FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.arrow_right_sharp),
          ), // FloatingActionButton
        ],
      ), // Row
    );
  }
}
