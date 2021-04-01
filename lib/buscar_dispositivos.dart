import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'main.dart';
import 'lista_dispositivos.dart';
import 'bluetooth_devices_custom.dart';

import 'package:flutter_scan_bluetooth/flutter_scan_bluetooth.dart';
import 'package:autolist/autolist.dart';
import 'package:percent_indicator/percent_indicator.dart';

class BuscarDispositivos extends StatefulWidget {
  final void Function(int) jumpToPage;
  const BuscarDispositivos({Key key, this.jumpToPage}) : super(key: key);

  @override
  _BuscarDispositivosState createState() => _BuscarDispositivosState();
}

class _BuscarDispositivosState extends State<BuscarDispositivos>
    with AutomaticKeepAliveClientMixin<BuscarDispositivos> {
  final controller = GetIt.I.get<ListaDispositivos>();

  bool _scanning = false;
  FlutterScanBluetooth _bluetooth = FlutterScanBluetooth();
  Color corBotao = Colors.green;
  var iconeBotao = Icons.search;
  List<int> colorCodes = <int>[100, 50];
  double _percentualAnimacaoBotaoBusca = 0.0;

  bool novoDispositivo = true;
  bool clicou = false;

  List<String> macsNovos = <String>[];
  double sizeBotaoNovoDispositivo = 20;
  double sizeBotaoAntigoDispositivo = 0;

  Color corTeste = Colors.amber;

  @override
  void initState() {
    getIt
        .isReady<ListaDispositivos>()
        .then((_) => getIt<ListaDispositivos>().addListener(update));

    super.initState();

    _bluetooth.devices.listen((device) {
      BluetoothDeviceCustom deviceTemp = BluetoothDeviceCustom(
          device.name, device.address, {device.nearby, device.paired});

      //var disposito = deviceTemp.name + ' (${deviceTemp.address})';
      if (controller.dispositivosEncontrados.length == 0) {
        macsNovos.clear();
      }

      for (var i = 0; i < controller.dispositivosEncontrados.length; i++) {
        if (controller.dispositivosEncontrados[i].address ==
            deviceTemp.address) {
          deviceTemp.name = controller.dispositivosEncontrados[i].name;
        }
      }

      if (controller.dispositivosEncontrados.indexOf(deviceTemp) == -1) {
        for (var i = 0; i < controller.dispositivosSalvos.length; i++) {
          if (controller.dispositivosSalvos[i].address == deviceTemp.address) {
            setState(
              () {
                novoDispositivo = false;
                controller.addEncontrados(controller.dispositivosSalvos[i]);
              },
            );
            debugPrint('Dispositivo ANTIGO: ' +
                controller.dispositivosSalvos[i].toString());
          }
        }
        if (novoDispositivo) {
          setState(
            () {
              controller.addEncontrados(deviceTemp);
              controller.addSalvos(deviceTemp);
              macsNovos.add(deviceTemp.address);
            },
          );
          debugPrint('Dispositivo NOVO: ' + deviceTemp.toString());
        } else {
          setState(
            () {
              novoDispositivo = true;
            },
          );
        }
      }
    });
    _bluetooth.scanStopped.listen((device) {
      debugPrint("busca encerrada");
      setState(() {
        _scanning = false;
        corBotao = Colors.green;
        iconeBotao = Icons.search;
        _percentualAnimacaoBotaoBusca = 0.0;
      });
      debugPrint('Dispositivos ENCONTRADOS: ' +
          controller.dispositivosEncontrados.toString());
      debugPrint(
          'Dispositivos SALVOS: ' + controller.dispositivosSalvos.toString());
      debugPrint('MACS NOVOS: ' + macsNovos.toString());
    });
  }

  @override
  void dispose() {
    getIt<ListaDispositivos>().removeListener(update);

    super.dispose();
  }

  void update() => setState(() => {});

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        AutoList<BluetoothDeviceCustom>(
          items: controller.dispositivosEncontrados,
          duration: Duration(milliseconds: 500),
          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
          itemBuilder: (context, item) {
            return Card(
              margin: EdgeInsets.only(top: 8),
              elevation: 2,
              clipBehavior: Clip.antiAlias,
              key: Key(item.toString()),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                color:
                    controller.dispositivosEncontradosAnimated.indexOf(item) !=
                            -1
                        ? Colors.green[100]
                        : Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      minVerticalPadding: 0,
                      contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                      horizontalTitleGap: 7,
                      leading: Container(
                        color: Colors.transparent,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: ClipOval(
                          child: Material(
                            color: Colors.transparent,
                            child: IconButton(
                              icon: Icon(Icons.playlist_add),
                              iconSize: 30,
                              padding: EdgeInsets.all(13),
                              color: controller.dispositivosEncontradosAnimated
                                          .indexOf(item) !=
                                      -1
                                  ? Colors.green[900]
                                  : Colors.black,
                              splashColor: !clicou
                                  ? Colors.black.withOpacity(0.1)
                                  : Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              disabledColor: Colors.grey,
                              onPressed: _buildPressed(item),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        item.name,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                        style: (TextStyle(
                          fontSize: 18,
                          color: controller.dispositivosEncontradosAnimated
                                      .indexOf(item) !=
                                  -1
                              ? Colors.green[900]
                              : Colors.black,
                        )),
                      ),
                      subtitle: Text(
                        item.address,
                        style: (TextStyle(
                          fontSize: 16,
                          color: controller.dispositivosEncontradosAnimated
                                      .indexOf(item) !=
                                  -1
                              ? Colors.green[900].withOpacity(0.7)
                              : Colors.grey[700],
                        )),
                      ),
                      trailing: Stack(
                        alignment: AlignmentDirectional.centerStart,
                        children: [
                          Container(
                            color: controller.dispositivosEncontradosAnimated
                                        .indexOf(item) !=
                                    -1
                                ? Colors.green[900].withOpacity(0.7)
                                : Colors.grey[700],
                            width: 1,
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              child: Icon(
                                Icons.redo_rounded,
                                size: 25,
                                color: controller
                                            .dispositivosEncontradosAnimated
                                            .indexOf(item) !=
                                        -1
                                    ? Colors.green[900]
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              child: Icon(
                                Icons.fiber_new,
                                size: (macsNovos.indexOf(item.address) > -1
                                    ? sizeBotaoNovoDispositivo
                                    : sizeBotaoAntigoDispositivo),
                                color: Colors.amber[600],
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.transparent,
                            margin: EdgeInsets.fromLTRB(9, 0, 0, 0),
                            child: ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  icon: Icon(Icons.devices_other),
                                  iconSize: 30,
                                  padding: EdgeInsets.all(13),
                                  color: controller
                                              .dispositivosEncontradosAnimated
                                              .indexOf(item) !=
                                          -1
                                      ? Colors.green[900]
                                      : Colors.black,
                                  splashColor: !clicou
                                      ? Colors.black.withOpacity(0.1)
                                      : Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  onPressed: () async {
                                    if (!clicou) {
                                      setState(() {
                                        clicou = true;
                                      });
                                      await new Future.delayed(
                                        const Duration(milliseconds: 200),
                                      );
                                      setState(() {
                                        controller.selecionarDispositivo(
                                            controller.dispositivosSalvos
                                                .indexOf(item));
                                        clicou = false;
                                      });
                                      widget.jumpToPage(2);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 8,
          right: 4,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              primary: Colors.transparent,
              padding: EdgeInsets.all(0),
            ),
            onPressed: () async {
              if (!clicou) {
                setState(() {
                  clicou = true;
                });
                try {
                  if (_scanning) {
                    await _bluetooth.stopScan();
                  } else {
                    setState(() {
                      controller.removeAllEncontrados();
                    });
                    await new Future.delayed(
                      const Duration(milliseconds: 200),
                    );
                    await _bluetooth.startScan(pairedDevices: false);
                    setState(() {
                      _scanning = true;
                      corBotao = Colors.red;
                      iconeBotao = Icons.stop;
                      _percentualAnimacaoBotaoBusca = 1.0;
                    });
                    debugPrint("\nbusca iniciada");
                  }
                } on PlatformException catch (e) {
                  debugPrint(e.toString());
                }
                setState(() {
                  clicou = false;
                });
              }
            },
            onLongPress: () async {
              if (!clicou) {
                setState(() {
                  clicou = true;
                });
                try {
                  if (_scanning) {
                    await _bluetooth.stopScan();
                  } else {
                    setState(() {
                      controller.removeAllEncontrados();
                    });
                    await new Future.delayed(
                      const Duration(milliseconds: 200),
                    );
                    await _bluetooth.startScan(pairedDevices: false);
                    setState(() {
                      _scanning = true;
                      corBotao = Colors.red;
                      iconeBotao = Icons.stop;
                      _percentualAnimacaoBotaoBusca = 1.0;
                    });
                    debugPrint("\nbusca iniciada");
                  }
                } on PlatformException catch (e) {
                  debugPrint(e.toString());
                }
                setState(() {
                  clicou = false;
                });
              }
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: ShapeDecoration(
                color: corBotao,
                shape: CircleBorder(),
              ),
              child: CircularPercentIndicator(
                radius: 55.0,
                animation: true,
                animationDuration: 14000,
                lineWidth: 5.0,
                percent: _percentualAnimacaoBotaoBusca,
                circularStrokeCap: CircularStrokeCap.round,
                backgroundColor: Colors.transparent,
                progressColor: corTeste,
                onAnimationEnd: () async {
                  if (_scanning) {
                    await _bluetooth.stopScan();
                  }
                },
                center: Icon(
                  iconeBotao,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _buildPressed(item) {
    if (controller.mapPresencas[controller.selectedDayData] == null) {
      return null;
    } else if (controller.mapPresencas[controller.selectedDayData]
        .contains(item)) {
      return null;
    }
    return () async {
      if (controller.mapPresencas[controller.selectedDayData].contains(item)) {
        setState(() {
          clicou = true;
        });
      } else {
        if (!clicou) {
          setState(() {
            clicou = true;
          });
          await new Future.delayed(
            const Duration(milliseconds: 200),
          );
          setState(() {
            controller
                .enviarDispositivo(controller.dispositivosSalvos.indexOf(item));
            clicou = false;
          });
          debugPrint('ITEM ENVIADO: ' + item.toString());
        }
      }
    };
  }

  @override
  bool get wantKeepAlive => true;
}
