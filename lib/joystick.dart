import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class Joystick extends StatefulWidget {
  Joystick({Key key, this.server}) : super(key: key);

  final BluetoothDevice server;

  //final Function onPressed;

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  BluetoothConnection connection;
  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;
  bool isDisconnecting = false;

  bool _buttonPressed = false;
  bool _loopActive = false;

  @override
  void initState() {
    super.initState();
    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      _showToast(context, 'Connected to the device');
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
    }).catchError((error) {
      _showToast(context, 'Cannot connect, exception occured');
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Joystick'),
      ),
      body: GridView.count(crossAxisCount: 3, children: <Widget>[
        Container(),
        Listener(
          onPointerDown: (details) {
            _buttonPressed = true;
            _increaseCounterWhilePressed('forward');
          },
          onPointerUp: (details) {
            _buttonPressed = false;
          },
          child: Container(
            child: Icon(
              Icons.arrow_upward,
              size: 100,
            ),
          ),
        ),
        Container(),
        Listener(
          onPointerDown: (details) {
            _buttonPressed = true;
            _increaseCounterWhilePressed('left');
          },
          onPointerUp: (details) {
            _buttonPressed = false;
          },
          child: Container(
            child: Icon(
              Icons.arrow_back,
              size: 100,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.stop, size: 100),
          onPressed: () {
            _sendMessage('stop');
            print('stop');
          },
        ),
        Listener(
          onPointerDown: (details) {
            _buttonPressed = true;
            _increaseCounterWhilePressed('right');
          },
          onPointerUp: (details) {
            _buttonPressed = false;
          },
          child: Container(
            child: Icon(
              Icons.arrow_forward,
              size: 100,
            ),
          ),
        ),
        Container(),
        Listener(
          onPointerDown: (details) {
            _buttonPressed = true;
            _increaseCounterWhilePressed('backward');
          },
          onPointerUp: (details) {
            _buttonPressed = false;
          },
          child: Container(
            child: Icon(
              Icons.arrow_downward,
              size: 100,
            ),
          ),
        )
      ]),
    );
  }

// Send command message and wait for button to be released before stopping
  void _increaseCounterWhilePressed(String command) async {
    if (_loopActive) return; // check if loop is active

    _loopActive = true;
    _sendMessage(command + '\r\n');
    print(command);
    while (_buttonPressed) {
      // wait a second
      await Future.delayed(Duration(milliseconds: 50));
    }
    _sendMessage('stop\r\n');
    print('stop');
    _loopActive = false;
  }

  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'HIDE', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
