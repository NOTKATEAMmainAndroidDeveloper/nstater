import 'package:flutter/material.dart';
import 'package:nstater/ncontroller.dart';
import 'package:nstater/nfield.dart';
import 'package:nstater/nstate.dart';
import 'package:nstater/nvar.dart';

void main() {
  runApp(MaterialApp(title: 'Flutter Demo', home: const MyHomePage()));
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NState(
      create: () => ExampleController(),
      builder:
          (ExampleController ctl) => Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text('NStater Example'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('You have pushed the button this many times:'),
                  NField(
                    data: ctl.counter,
                    builder: (data) => Text('$data', style: Theme.of(context).textTheme.headlineMedium),
                  ),
                  SizedBox(height: 16),
                  const Text('You have pushed the button this many times after update:'),
                  Text('${ctl.counter.value}', style: Theme.of(context).textTheme.headlineMedium),
                ],
              ),
            ),
            floatingActionButton: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(onPressed: ctl.increment, tooltip: 'Increment', child: const Icon(Icons.add)),
                SizedBox(width: 16),
                FloatingActionButton(onPressed: ctl.updateCtl, tooltip: 'Update', child: const Icon(Icons.update)),
              ],
            ),
          ),
    );
  }
}

class ExampleController extends NController<ExampleController> {
  NVar<int> counter = NVar(0);

  /// this method increment [counter] and rebuild NField widget where [counter] is used
  void increment() {
    counter.value++;
  }

  /// this method rebuild child widget
  void updateCtl() {
    update();
  }
}
