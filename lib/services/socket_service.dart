import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart';

enum ServerStatus {
    Online,
    Offline,
    Connecting
}

class SocketService with ChangeNotifier {

    ServerStatus _serverStatus = ServerStatus.Connecting;
    late Socket _socket;

    Function get emit => _socket.emit;

    SocketService() {
        _initConfig();
    }

    ServerStatus get serverStatus => _serverStatus;
    Socket get socket => _socket;

    void _initConfig() {

        _socket = io(
            'http://localhost:3000/',
            OptionBuilder()
                .setTransports(['websocket'])
                .build()
        );

        _socket.onConnect((_) {
            _serverStatus = ServerStatus.Online;
            notifyListeners();
        });

        _socket.onDisconnect((_) {
            _serverStatus = ServerStatus.Offline;
            notifyListeners();
        });

    }

}