import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'main.dart';
import 'bluetooth_devices_custom.dart';

abstract class ListaDispositivos extends ChangeNotifier {
  void addSalvos(bluetoothDeviceCustom);
  void addEncontrados(bluetoothDeviceCustom);
  void addEncontradosAnimated(bluetoothDeviceCustom);
  void setSelectDay(day);
  void setSelectedDayData(dayString);
  void addDay();
  void addPresenca(bluetoothDeviceCustom);
  void editSalvos(address, name);
  void editEncontrados(address, name);
  void removeSalvos(bluetoothDeviceCustom);
  void removeEncontrados(bluetoothDeviceCustom);
  void removeEncontradosAnimated(bluetoothDeviceCustom, esperar);
  void removeAllEncontrados();
  void removePresenca(bluetoothDeviceCustom);
  void selecionarDispositivo(index);
  void enviarDispositivo(index);
  void selecionarDispositivoLista(index);
  void inicializarApp();
  void toogleStatusApp();
  List<BluetoothDeviceCustom> dispositivosSalvos;
  List<BluetoothDeviceCustom> dispositivosEncontrados;
  List<BluetoothDeviceCustom> dispositivosEncontradosAnimated;
  int dispositivoSelecionado;
  int dispositivoEnviado;
  int dispositivoSelecionadoLista;
  bool appInicializado;
  DateTime selectedDay;
  String selectedDayData;
  Map<String, List<BluetoothDeviceCustom>> mapPresencas;
  Map<DateTime, List> events;
}

class ListaDispositivosImplementation extends ListaDispositivos {
  List<BluetoothDeviceCustom> _dispositivosSalvos = <BluetoothDeviceCustom>[];
  List<BluetoothDeviceCustom> _dispositivosEncontrados =
      <BluetoothDeviceCustom>[];
  List<BluetoothDeviceCustom> _dispositivosEncontradosAnimated =
      <BluetoothDeviceCustom>[];
  int _dispositivoSelecionado = -1;
  int _dispositivoEnviado = -1;
  int _dispositivoSelecionadoLista = -1;
  bool _appInicializado = false;
  DateTime _selectedDay = DateTime.now();
  String _selectedDayData = '';
  Map<String, List<BluetoothDeviceCustom>> _mapPresencas = {};
  Map<DateTime, List> _events = {};

  ListaDispositivosImplementation() {
    Future.delayed(Duration(seconds: 3)).then((_) => getIt.signalReady(this));
  }

  @override
  List<BluetoothDeviceCustom> get dispositivosSalvos => _dispositivosSalvos;

  @override
  List<BluetoothDeviceCustom> get dispositivosEncontrados =>
      _dispositivosEncontrados;

  @override
  List<BluetoothDeviceCustom> get dispositivosEncontradosAnimated =>
      _dispositivosEncontradosAnimated;

  @override
  int get dispositivoSelecionado => _dispositivoSelecionado;

  @override
  int get dispositivoEnviado => _dispositivoEnviado;

  @override
  int get dispositivoSelecionadoLista => _dispositivoSelecionadoLista;

  @override
  bool get appInicializado => _appInicializado;

  @override
  DateTime get selectedDay => _selectedDay;

  @override
  String get selectedDayData => _selectedDayData;

  @override
  Map<String, List<BluetoothDeviceCustom>> get mapPresencas => _mapPresencas;

  @override
  Map<DateTime, List> get events => _events;

  @override
  void addSalvos(bluetoothDeviceCustom) {
    _dispositivosSalvos.add(bluetoothDeviceCustom);
    notifyListeners();
  }

  @override
  void addEncontrados(bluetoothDeviceCustom) {
    _dispositivosEncontrados.add(bluetoothDeviceCustom);
    addEncontradosAnimated(bluetoothDeviceCustom);
    notifyListeners();
  }

  @override
  void addEncontradosAnimated(bluetoothDeviceCustom) {
    _dispositivosEncontradosAnimated.add(bluetoothDeviceCustom);
    notifyListeners();
    removeEncontradosAnimated(bluetoothDeviceCustom, true);
  }

  @override
  void setSelectDay(day) {
    _selectedDay = day;
    notifyListeners();
  }

  @override
  void setSelectedDayData(dayString) {
    _selectedDayData = dayString;
    notifyListeners();
  }

  @override
  void addDay() {
    if (!_mapPresencas.containsKey(_selectedDayData)) {
      _mapPresencas.addAll({_selectedDayData: []});
    }
    notifyListeners();
  }

  @override
  void addPresenca(bluetoothDeviceCustom) {
    // debugPrint('\n-----INICIO-------------------');
    // debugPrint('bluetoothDeviceCustom: ' + bluetoothDeviceCustom.toString());

    _mapPresencas.forEach((key, value) {
      if (key == _selectedDayData) {
        value.add(bluetoothDeviceCustom);
        _dispositivosSalvos[_dispositivosSalvos.indexOf(bluetoothDeviceCustom)]
            .presencas
            .add(_selectedDayData);

        var dataFormatada = DateFormat('dd/MM/yyyy').parse(_selectedDayData);
        if (!_events.containsKey(dataFormatada)) {
          _events.addAll({
            dataFormatada: [bluetoothDeviceCustom]
          });
        } else {
          _events[dataFormatada].add(bluetoothDeviceCustom);
        }
      }
    });

    // _holidays.update(_selectedDay, (value) => ['A']);
    // _holidays.update(_selectedDay, (value) => ['B']);

    // debugPrint(_holidays.toString());

    // _holidays.forEach((key, value) {
    //   debugPrint(key.toString());
    //   debugPrint(value.toString());
    // });

    //_mapPresencas.addAll({_selectedDay: bluetoothDeviceCustom});
    //_mapPresencas[_selectedDay].add(bluetoothDeviceCustom);
    // debugPrint(_mapPresencas.toString());
    // debugPrint('-----FIM-------------------');
    notifyListeners();
  }

  @override
  void editSalvos(address, name) {
    for (var i = 0; i < _dispositivosSalvos.length; i++) {
      if (_dispositivosSalvos[i].address == address) {
        _dispositivosSalvos[i].name = name;
      }
    }
    notifyListeners();
  }

  @override
  void editEncontrados(address, name) {
    for (var i = 0; i < _dispositivosEncontrados.length; i++) {
      if (_dispositivosEncontrados[i].address == address) {
        _dispositivosEncontrados[i].name = name;
      }
    }
    notifyListeners();
  }

  @override
  void removeSalvos(bluetoothDeviceCustom) {
    _dispositivosSalvos.remove(bluetoothDeviceCustom);
    removeEncontrados(bluetoothDeviceCustom);
    notifyListeners();
  }

  @override
  void removeEncontrados(bluetoothDeviceCustom) {
    _dispositivosEncontrados.remove(bluetoothDeviceCustom);
    notifyListeners();
    removeEncontradosAnimated(bluetoothDeviceCustom, false);
  }

  @override
  Future<void> removeEncontradosAnimated(bluetoothDeviceCustom, esperar) async {
    if (esperar) {
      await new Future.delayed(
        const Duration(milliseconds: 500),
      );
    }
    _dispositivosEncontradosAnimated.remove(bluetoothDeviceCustom);
    notifyListeners();
  }

  @override
  void removeAllEncontrados() {
    _dispositivosEncontrados.clear();
    notifyListeners();
  }

  @override
  void removePresenca(bluetoothDeviceCustom) {
    // debugPrint('\n-----INICIO-------------------');
    // debugPrint('bluetoothDeviceCustom: ' + bluetoothDeviceCustom.toString());

    _mapPresencas.forEach((key, value) {
      if (key == _selectedDayData) {
        value.remove(bluetoothDeviceCustom);
        _dispositivosSalvos[_dispositivosSalvos.indexOf(bluetoothDeviceCustom)]
            .presencas
            .remove(_selectedDayData);

        var dataFormatada = DateFormat('dd/MM/yyyy').parse(_selectedDayData);
        if (value.length == 0) {
          _events.remove(dataFormatada);
        } else {
          _events[dataFormatada].remove(bluetoothDeviceCustom);
        }
      }
    });

    // debugPrint(_mapPresencas.toString());
    // debugPrint('-----FIM-------------------');
    notifyListeners();
  }

  @override
  void selecionarDispositivo(index) {
    _dispositivoSelecionado = index;
    notifyListeners();
  }

  @override
  void enviarDispositivo(index) {
    _dispositivoEnviado = index;
    addPresenca(_dispositivosSalvos[index]);
    notifyListeners();
  }

  @override
  void selecionarDispositivoLista(index) {
    _dispositivoSelecionadoLista = index;
    notifyListeners();
  }

  @override
  Future<void> inicializarApp() async {
    _selectedDayData = DateFormat.yMd('pt_BR').format(DateTime.now());
    _mapPresencas.addAll({_selectedDayData: []});
    await new Future.delayed(
      const Duration(milliseconds: 3000),
    );
    _appInicializado = true;
    notifyListeners();
  }

  @override
  toogleStatusApp() {
    _appInicializado = !_appInicializado;
    notifyListeners();
  }
}
