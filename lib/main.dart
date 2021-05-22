import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';
import './ChatPage.dart';

BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
BluetoothConnection connection;
String _address = "...";
String _name = "...";

Timer _discoverableTimeoutTimer;
int _discoverableTimeoutSecondsLeft = 0;


bool _autoAcceptPairingRequests = false;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromRGBO(227,244,252,1),
        primarySwatch: Colors.blue,
      ),
      home: HomePage(title: 'Assistant19'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

    @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),

      ),
      body: StreamBuilder(
    stream: Stream.periodic(const Duration(seconds: 1)),
    builder: (context, snapshot) {
      return Center(
        child: Column(
          children: <Widget>[
            Image.asset('assets/images/robot.png'),
            Divider(),
            Text(
              DateFormat('hh:mm:ss').format(DateTime.now()),
              style: TextStyle(fontSize: 40.0),
            ),
            Divider(),
            Container(

              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  new TextButton(
                    child: new Image.asset('assets/images/iconocarga.png',height: 100,
                      width: 100),
                    style: ElevatedButton.styleFrom(
                    primary: Colors.transparent, // background
                    onPrimary: Colors.transparent, // foreground
                     ),
                      onPressed: () => {
                                        print(sendData('0'))
                                      },
                  ),


                  new TextButton(
                    child: new Image.asset('assets/images/iconoinfo.png',height: 100,
                      width: 100),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black.withOpacity(0.0), // background
                      onPrimary: Colors.black.withOpacity(0.0), // foreground
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Info()),
                      );
                    },
                  ),


                ],
              )

            ),
            Container(

                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                    new TextButton(
                      child: new Image.asset('assets/images/iconollamado.png',height: 100,
                        width: 100),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent, // background
                        onPrimary: Colors.transparent, // foreground
                      ),
                      onPressed: () => {
                                        print(sendData('2'))
                                      },
                    ),

                    new TextButton(
                      child: new Image.asset('assets/images/iconobt.png',height: 100,
                          width: 100),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.transparent, // background
                        onPrimary: Colors.transparent, // foreground
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Bluetooth()),
                        );
                      },
                    ),





                  ],
                )

            ),
              Container(

              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  new TextButton(
                    child: new Image.asset('assets/images/iconostop.png',height: 80,
                      width: 80),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black.withOpacity(0.0), // background
                      onPrimary: Colors.black.withOpacity(0.0), // foreground
                    ),
                      onPressed: () => {
                                        print(sendData('1'))
                                      },
                  ),


                ],
              )

            ),


          ],
        ),
      );
    })

    );
  }
}



class Info extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
          centerTitle: true,
          title: Text('Info'),

      ),
      body: Center(
      child: Column(
      children: <Widget>[
          Image.asset('assets/images/robot.png'),
                      Divider(),
          Text("Autores:",style: TextStyle(fontSize: 40.0)),
                      Divider(),
          Text(
             'Nicolas Velandia Sanabria',
              style: TextStyle(fontSize: 20.0),

            ),
        SizedBox(height: 10),
                  Text(
             'Valeria Ferreira Nocua',
              style: TextStyle(fontSize: 20.0),

            ),   SizedBox(height: 10),
                  Text(
             'Camilo Andres Silva Rodriguez',
              style: TextStyle(fontSize: 20.0),


            ),
                     SizedBox(height: 10),
                  Text(
             'Kiara Nicole Velasquez Ramirez',
              style: TextStyle(fontSize: 20.0),

            ),   SizedBox(height: 10),
        Text(
             'Cristian Andres Reinales Herrera',
              style: TextStyle(fontSize: 20.0),

            ),   SizedBox(height: 10),
                Text(
                  'Juan Andres Ortiz Pinzon',
              style: TextStyle(fontSize: 20.0),

            ), Divider(),
                        Text(
                  'Version de la APP: 1.0',
              style: TextStyle(fontSize: 40.0)),
        Divider()

          ]
          )
          )

      );

  }
}

class Bluetooth extends StatefulWidget {
  @override
  _BluetoothState createState() => _BluetoothState();

}

class _BluetoothState extends State<Bluetooth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conexion Bluetooth'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            SwitchListTile(
              title: const Text('Habilitar Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: const Text('Estado del Bluetooth'),
              subtitle: Text(_bluetoothState.toString()),
              trailing: ElevatedButton(
                child: const Text('Ajustes'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            ListTile(
              title: const Text('Direccion adaptador local'),
              subtitle: Text(_address),
            ),
            ListTile(
              title: const Text('Nombre adaptador local'),
              subtitle: Text(_name),
              onLongPress: null,
            ),
            ListTile(
              title: _discoverableTimeoutSecondsLeft == 0
                  ? const Text("Visibilidad del Dispositivo")
                  : Text(
                      "Visible por ${_discoverableTimeoutSecondsLeft}s"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _discoverableTimeoutSecondsLeft != 0,
                    onChanged: null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      print('Visibilidad solicitida');
                      final int timeout = await FlutterBluetoothSerial.instance
                          .requestDiscoverable(60);
                      if (timeout < 0) {
                        print('Modo Visibilidad denegado');
                      } else {
                        print(
                            'Visibilidad activada por $timeout segundos');
                      }
                      setState(() {
                        _discoverableTimeoutTimer?.cancel();
                        _discoverableTimeoutSecondsLeft = timeout;
                        _discoverableTimeoutTimer =
                            Timer.periodic(Duration(seconds: 1), (Timer timer) {
                          setState(() {
                            if (_discoverableTimeoutSecondsLeft < 0) {
                              FlutterBluetoothSerial.instance.isDiscoverable
                                  .then((isDiscoverable) {
                                if (isDiscoverable) {
                                  print(
                                      "Discoverable after timeout... might be infinity timeout :F");
                                  _discoverableTimeoutSecondsLeft += 1;
                                }
                              });
                              timer.cancel();
                              _discoverableTimeoutSecondsLeft = 0;
                            } else {
                              _discoverableTimeoutSecondsLeft -= 1;
                            }
                          });
                        });
                      });
                    },
                  )
                ],
              ),
            ),
            Divider(),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Lista Dispositivos Encontrados'),
                  onPressed: () async {
                    final BluetoothDevice selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return DiscoveryPage();
                        },
                      ),
                    );

                    if (selectedDevice != null) {
                      print('Visibilidad -> seleccionado ' + selectedDevice.address);
                    } else {
                      print('Visibilidad -> ningun dispositivo seleccionado');
                    }
                  }),
            ),

            Divider(),

          ],
        ),
      ),
    );
  }
}

Future sendData(String text) async {
       try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;
      }
      catch (e) {
          print("Error enviando.");

      }

      }

