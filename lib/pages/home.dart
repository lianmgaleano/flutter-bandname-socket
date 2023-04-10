import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names_app/models/band.dart';

class HomePage extends StatefulWidget {

    const HomePage({Key? key}) : super(key: key);

    @override
    State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

    List<Band> bands = [
        Band(id: '1', name: 'Metallica', votes: 5),
        Band(id: '2', name: 'Queen', votes: 1),
        Band(id: '3', name: 'Héroes del Silencio', votes: 2),
        Band(id: '4', name: 'Bon Jovi', votes: 5),
    ];

    @override
    Widget build(BuildContext context) {

        return Scaffold(
            appBar: AppBar(
                title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
                backgroundColor: Colors.white,
                elevation: 1,
            ),
            body: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (BuildContext context, int index) => _bandTile(bands[index])
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: addNewBand,
                elevation: 1,
                child: const Icon(Icons.add),
            ),
        );

    }

    Widget _bandTile(Band band) {

        return Dismissible(
            key: Key(band.id),
            direction: DismissDirection.startToEnd,
            onDismissed: (DismissDirection direction) {
                print('Direction: $direction');
            },
            background: Container(
                padding: const EdgeInsets.only(left: 8.0),
                color: Colors.red,
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Delete band', style: TextStyle(color: Colors.white))
                ),
            ),
            child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(band.name.substring(0, 2)),
                ),
                title: Text(band.name),
                trailing: Text('${band.votes}', style: const TextStyle(fontSize: 20)),
                onTap: () {
                    print(band.name);
                },
            ),
        );

    }

    addNewBand() {

        final textController = TextEditingController();

        if (Platform.isAndroid) {
            return showDialog(
                context: context,
                builder: (context) {

                    return AlertDialog(
                        title: const Text('New band name:'),
                        content: TextField(
                            controller: textController,
                        ),
                        actions: <Widget>[
                            MaterialButton(
                                onPressed: () => addBandToList(textController.text),
                                elevation: 5,
                                textColor: Colors.blue,
                                child: const Text('Add'),
                            )
                        ],
                    );

                }
            );
        }

        return showCupertinoDialog(
            context: context,
            builder:(_) {
                return CupertinoAlertDialog(
                    title: const Text('New band name:'),
                    content: CupertinoTextField(
                        controller: textController,
                    ),
                    actions: <Widget>[
                        CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () => addBandToList(textController.text),
                            child: const Text('Add'),
                        ),
                        CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Dismiss'),
                        ),
                    ],
                );
            }
        );

    }

    void addBandToList(String name) {
        print(name);
        if(name.length > 1) {
            bands.add(Band(id: DateTime.now().toString(), name: name, votes: 0));
            setState(() {});
        }

        Navigator.pop(context);
    }

}