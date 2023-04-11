import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names_app/models/band.dart';

import 'package:band_names_app/services/socket_service.dart';

class HomePage extends StatefulWidget {

    const HomePage({Key? key}) : super(key: key);

    @override
    State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

    List<Band> bands = [
        /*Band(id: '1', name: 'Metallica', votes: 5),
        Band(id: '2', name: 'Queen', votes: 1),
        Band(id: '3', name: 'Héroes del Silencio', votes: 2),
        Band(id: '4', name: 'Bon Jovi', votes: 5),*/
    ];

    @override
    void initState() {
        final socketService = Provider.of<SocketService>(context, listen: false);
        socketService.socket.on('active-bands', _handleActiveBands);

        super.initState();
    }

    _handleActiveBands(dynamic payload) {
        bands = (payload as List)
            .map((band) => Band.fromMap(band)).toList();

        setState(() {});
    }

    @override
    void dispose() {
        final socketService = Provider.of<SocketService>(context, listen: false);
        socketService.socket.off('active-bands');

        super.dispose();
    }

    @override
    Widget build(BuildContext context) {

        final socketService = Provider.of<SocketService>(context);

        return Scaffold(
            appBar: AppBar(
                title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
                backgroundColor: Colors.white,
                elevation: 1,
                actions: <Widget>[
                    Container(
                        margin: const EdgeInsets.only(right: 10),
                        child:
                            (socketService.serverStatus == ServerStatus.Online) ?
                            Icon(Icons.check_circle, color: Colors.blue[300]) :
                            const Icon(Icons.offline_bolt, color: Colors.red),
                    )
                ],
            ),
            body:Column(
                children: <Widget>[
                    _showGraph(),

                    Expanded(
                        child: ListView.builder(
                            itemCount: bands.length,
                            itemBuilder: (BuildContext context, int index) => _bandTile(bands[index]
                        )                                ),
                    )
                ],
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: addNewBand,
                elevation: 1,
                child: const Icon(Icons.add),
            ),
        );

    }

    Widget _bandTile(Band band) {

        final socketService = Provider.of<SocketService>(context, listen: false);

        return Dismissible(
            key: Key(band.id),
            direction: DismissDirection.startToEnd,
            onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
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
                onTap: () => socketService.emit('vote-band', {'id': band.id}),
            ),
        );

    }

    addNewBand() {

        final textController = TextEditingController();

        if (Platform.isAndroid) {
            return showDialog(
                context: context,
                builder: (_) => AlertDialog(
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
                    ),

            );
        }

        return showCupertinoDialog(
            context: context,
            builder:(_) => CupertinoAlertDialog(
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
                )

        );

    }

    void addBandToList(String name) {
        if(name.length > 1) {
            final socketService = Provider.of<SocketService>(context, listen: false);

            socketService.emit('add-band', {'name': name});
        }

        Navigator.pop(context);
    }

    Widget _showGraph() {

        Map<String, double> dataMap = Map();

        bands.forEach((band) {
            dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
        });

        final List<Color> colorList = [
            Colors.blue,
            Colors.blueAccent,
            Colors.pink,
            Colors.pinkAccent,
            Colors.yellow,
            Colors.yellowAccent,
        ];

        return Container(
            padding: EdgeInsets.only(top: 10),
            width: double.infinity,
            height: 200,
            child: PieChart(
                dataMap: dataMap,
                animationDuration: Duration(milliseconds: 800),
                colorList: colorList,
                initialAngleInDegree: 0,
                chartType: ChartType.disc,
                ringStrokeWidth: 32,
                centerText: "BANDS",
                chartValuesOptions: ChartValuesOptions(
                    decimalPlaces: 0,
                    chartValueBackgroundColor: Colors.transparent
                ),
            )
        );
    }

}