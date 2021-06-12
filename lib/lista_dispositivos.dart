import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import 'main.dart';
import 'bluetooth_devices_custom.dart';

import 'package:sqflite/sqflite.dart';

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

  void encerrarApp();

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
  var _database;

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
    if (!_dispositivosSalvos.contains(bluetoothDeviceCustom)) {
      _dispositivosSalvos.add(bluetoothDeviceCustom);
      addSalvosDatabase(bluetoothDeviceCustom);
    }

    selecionarDispositivo(_dispositivosSalvos.indexOf(bluetoothDeviceCustom));
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
    removeEncontradosAnimated(bluetoothDeviceCustom, true);
    notifyListeners();
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
    _mapPresencas.forEach((key, value) {
      if (key == _selectedDayData) {
        value.add(bluetoothDeviceCustom);
        _dispositivosSalvos[_dispositivosSalvos.indexOf(bluetoothDeviceCustom)]
            .presences
            .add(_selectedDayData);

        var dataFormatada = DateFormat('dd/MM/yyyy').parse(_selectedDayData);

        if (!_events.containsKey(dataFormatada)) {
          _events.addAll({
            dataFormatada: [bluetoothDeviceCustom]
          });
        } else {
          _events[dataFormatada].add(bluetoothDeviceCustom);
        }

        addPresencaDatabase(bluetoothDeviceCustom, _selectedDayData);
      }
    });

    notifyListeners();
  }

  @override
  void editSalvos(address, name) {
    for (var i = 0; i < _dispositivosSalvos.length; i++) {
      if (_dispositivosSalvos[i].address == address) {
        _dispositivosSalvos[i].name = name;
        updateSalvosDatabase(_dispositivosSalvos[i]);
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
    removeSalvosDatabase(bluetoothDeviceCustom);
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
    _mapPresencas.forEach((key, value) {
      if (key == _selectedDayData) {
        value.remove(bluetoothDeviceCustom);
        _dispositivosSalvos[_dispositivosSalvos.indexOf(bluetoothDeviceCustom)]
            .presences
            .remove(_selectedDayData);

        var dataFormatada = DateFormat('dd/MM/yyyy').parse(_selectedDayData);

        if (value.length == 0) {
          _events.remove(dataFormatada);
        } else {
          _events[dataFormatada].remove(bluetoothDeviceCustom);
        }

        removePresencaDatabase(bluetoothDeviceCustom, _selectedDayData);
      }
    });

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

    initDatabase()
        .whenComplete(() => loadDevicesFromDB())
        .whenComplete(() => loadPresencesFromDB())
        .whenComplete(() {
      _appInicializado = true;
      notifyListeners();
    });
  }

  @override
  toogleStatusApp() {
    _appInicializado = !_appInicializado;
    notifyListeners();
  }

  Future<void> initDatabase() async {
    _database = await openDatabase(
        join(await getDatabasesPath(), "lista_presenca_bt.db"),
        onUpgrade: (Database db, int version, int info) async {},
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE device (address TEXT, name TEXT, PRIMARY KEY(address))");
      await db.execute(
          "CREATE TABLE presence (event_date DATE, address TEXT, name TEXT, PRIMARY KEY(event_date, address))");
    }, version: 1);
  }

  Future<void> loadDevicesFromDB() async {
    List<Map<String, dynamic>> rows = await _database.query("device");

    rows.forEach((row) => _dispositivosSalvos
        .add(BluetoothDeviceCustom(row["name"], row["address"])));
  }

  Future<void> loadPresencesFromDB() async {
    List<Map<String, dynamic>> rows = await _database.query("presence");

    rows.forEach((row) {
      var device = BluetoothDeviceCustom(row["name"], row["address"]);
      var index = _dispositivosSalvos.indexOf(device);

      if (index > -1) {
        var eventDate = DateFormat('dd/MM/yyyy').parse(row['event_date']);
        var eventDateStr = DateFormat.yMd('pt_BR').format(eventDate);

        _dispositivosSalvos[index].presences.add(eventDateStr);

        if (_mapPresencas.containsKey(eventDateStr)) {
          _mapPresencas[eventDateStr].add(_dispositivosSalvos[index]);
        } else {
          _mapPresencas.addAll({
            eventDateStr: [_dispositivosSalvos[index]]
          });
        }

        if (_events.containsKey(eventDate)) {
          _events[eventDate].add(_dispositivosSalvos[index]);
        } else {
          _events.addAll({
            eventDate: [_dispositivosSalvos[index]]
          });
        }
      }
    });
  }

  Future<void> addSalvosDatabase(bluetoothDeviceCustom) async {
    await _database.rawInsert("INSERT INTO device(address, name) VALUES(?,?)",
        [bluetoothDeviceCustom.address, bluetoothDeviceCustom.name]);
  }

  Future<void> updateSalvosDatabase(bluetoothDeviceCustom) async {
    await _database.rawUpdate("UPDATE device SET name = ? WHERE address = ?",
        [bluetoothDeviceCustom.name, bluetoothDeviceCustom.address]);
  }

  Future<void> removeSalvosDatabase(bluetoothDeviceCustom) async {
    await _database.rawDelete("DELETE FROM device WHERE address = ?",
        [bluetoothDeviceCustom.address]);
  }

  Future<void> addPresencaDatabase(bluetoothDeviceCustom, data) async {
    await _database.rawInsert(
        "INSERT INTO presence(event_date, address, name) VALUES(?,?,?)",
        [data, bluetoothDeviceCustom.address, bluetoothDeviceCustom.name]);
  }

  Future<void> removePresencaDatabase(bluetoothDeviceCustom, data) async {
    await _database.rawDelete(
        "DELETE FROM presence WHERE event_date = ? AND address = ?",
        [data, bluetoothDeviceCustom.address]);
  }

  @override
  void encerrarApp() async {
    await _database.close;
  }
}
