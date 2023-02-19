import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:stream_provider_ble/src/ble/ble_device_interactor.dart';

class DeviceInteractorScreen extends StatelessWidget {
  final String deviceId;
  const DeviceInteractorScreen({Key? key, required this.deviceId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer2<ConnectionStateUpdate, BleDeviceInteractor>(
          builder: (_, connectionStateUpdate, deviceInteractor, __) {
            if (connectionStateUpdate.connectionState ==
                DeviceConnectionState.connected) {
              return DeviceInteractor(
                deviceId: deviceId,
                deviceInteractor: deviceInteractor,
              );
            } else if (connectionStateUpdate.connectionState ==
                DeviceConnectionState.connecting) {
              return const Text('connecting');
            } else {
              return const Text('error');
            }
          },
        ),
      ),
    );
  }
}

class DeviceInteractor extends StatefulWidget {
  final BleDeviceInteractor deviceInteractor;

  final String deviceId;
  const DeviceInteractor(
      {Key? key, required this.deviceInteractor, required this.deviceId})
      : super(key: key);

  @override
  State<DeviceInteractor> createState() => _DeviceInteractorState();
}

class _DeviceInteractorState extends State<DeviceInteractor> {
  final Uuid _myServiceUuid =
      Uuid.parse("19b10000-e8f2-537e-4f6c-6969768a1214");
  final Uuid _myCharacteristicUuid =
      Uuid.parse("19b10001-e8f2-537e-4f6c-6969768a1214");

  Stream<List<int>>? subscriptionStream;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    // Connect to the BLE device here, and then call the writeCharacteristicWithResponse method
    // after the connection is established.
    final services = widget.deviceInteractor.discoverServices(widget.deviceId);
    print(services);
    widget.deviceInteractor.writeCharacterisiticWithResponse(
        QualifiedCharacteristic(
            characteristicId:
                Uuid.parse("19b10001-e8f2-537e-4f6c-d104768a1215"),
            serviceId: Uuid.parse("19b10000-e8f2-537e-4f6c-d104768a1214"),
            deviceId: widget.deviceId),
        [79, 70, 70]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('connected'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: subscriptionStream != null
                  ? null
                  : () async {
                      setState(() {
                        subscriptionStream =
                            widget.deviceInteractor.subScribeToCharacteristic(
                          QualifiedCharacteristic(
                              characteristicId: _myCharacteristicUuid,
                              serviceId: _myServiceUuid,
                              deviceId: widget.deviceId),
                        );
                      });
                    },
              child: const Text('subscribe'),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('disconnect'),
            ),
            const SizedBox(
              width: 20,
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     widget.deviceInteractor.readCharacteristic(
            //       QualifiedCharacteristic(
            //           characteristicId:
            //               Uuid.parse("19b10001-e8f2-537e-4f6c-d104768a1214"),
            //           serviceId:
            //               Uuid.parse("00000000-0000-0000-0000-000000000000"),
            //           deviceId: widget.deviceId),
            //     );
            //   },
            //   child: const Text('read caracteristic'),
            // ),
            const SizedBox(
              width: 20,
            ),
            // crear un boton para leer los servicios
            ElevatedButton(
              onPressed: () {
                widget.deviceInteractor.writeCharacterisiticWithResponse(
                    QualifiedCharacteristic(
                        characteristicId:
                            Uuid.parse("19b10001-e8f2-537e-4f6c-d104768a1215"),
                        serviceId:
                            Uuid.parse("19b10000-e8f2-537e-4f6c-d104768a1214"),
                        deviceId: widget.deviceId),
                    [79, 70, 70]);
              },
              child: const Text('read services'),
            ),
          ],
        ),
        subscriptionStream != null
            ? StreamBuilder<List<int>>(
                stream: subscriptionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data);
                    return Text(snapshot.data.toString());
                  }
                  return const Text('No data yet');
                })
            : const Text('Stream not initalized')
      ],
    );
  }
}
