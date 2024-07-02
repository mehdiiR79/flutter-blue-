import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}
List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';
Future Connecttodevice ()async{
  String deviceidpath="";
   BluetoothConnection? connection;
 BluetoothConnection.toAddress(deviceidpath).then((_connection) {
      
      
      // print('Connected to the device');
      connection = _connection;

     
       
        

        connection!.input!.listen(_onDataReceived).onDone(() {});
     
    }).catchError((error){
      //print Error
    });
}
 void _onDataReceived(Uint8List data) {
    
    
    String message = '';
    String dataStr = ascii.decode(data);
    message += dataStr;
    if (dataStr.contains('\n')) {
     
      message = ''; //clear buffer to accept new string
    }
   
   
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        // print("data [i] :" + data[i].toString());
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
   
    String dataString = String.fromCharCodes(buffer);
    //print recive data
  

    int index = buffer.indexOf(13);
    if (~index != 0) {
      // print("__message buffer 1 :" + _messageBuffer);
      
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
        // print("__message buffer 2:" + _messageBuffer);
      
    } else {
      // print("__message buffer 3:" + _messageBuffer);
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
      // print("__message buffer 4:" + _messageBuffer);
    }
  }
