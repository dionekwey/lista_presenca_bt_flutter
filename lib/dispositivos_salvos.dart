import 'package:autolist/autolist.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'bluetooth_devices_custom.dart';
import 'lista_dispositivos.dart';
import 'main.dart';

class DispositivosSalvos extends StatefulWidget {
  final void Function(int) jumpToPage;
  const DispositivosSalvos({Key key, this.jumpToPage}) : super(key: key);

  @override
  _DispositivosSalvosState createState() => _DispositivosSalvosState();
}

class _DispositivosSalvosState extends State<DispositivosSalvos>
    with
        AutomaticKeepAliveClientMixin<DispositivosSalvos>,
        TickerProviderStateMixin {
  final controller = GetIt.I.get<ListaDispositivos>();
  TextEditingController _textFieldController = TextEditingController();
  bool clicou = false;
  bool clicouDel = false;

  AnimationController _animationController;
  AnimationController _animationControllerNull;
  Animation _animation;
  Animation _animationNull;

  @override
  void initState() {
    getIt
        .isReady<ListaDispositivos>()
        .then((_) => getIt<ListaDispositivos>().addListener(update));

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _animationControllerNull = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _animation = Tween(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController);
    _animationNull = Tween(
      begin: 1.0,
      end: 1.0,
    ).animate(_animationControllerNull);

    super.initState();
  }

  @override
  void dispose() {
    getIt<ListaDispositivos>().removeListener(update);
    _animationController.dispose();
    _animationControllerNull.dispose();
    super.dispose();
  }

  void update() => setState(() => {});

  Future<void> _displayTextInputDialog(
      BuildContext context, BluetoothDeviceCustom item) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar nome'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nome atual: ' + item.name,
              ),
              TextField(
                controller: _textFieldController,
                decoration: InputDecoration(hintText: 'Digite um novo nome'),
                autofocus: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.red,
                backgroundColor: Colors.white,
              ),
              child: Text('CANCELAR'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.green,
                backgroundColor: Colors.white,
              ),
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  if (_textFieldController.text != '' &&
                      item.name != _textFieldController.text) {
                    item.name = _textFieldController.text;
                    controller.editSalvos(item.address, item.name);
                  }
                  Navigator.pop(context);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _displayTextAlert(
      BuildContext context, BluetoothDeviceCustom item) async {
    bool vazio = item.presencas.isEmpty;
    debugPrint('VAZIO: ' + vazio.toString());
    List<String> presencasOrdenadasY = [];
    List<String> presencasOrdenadasD = [];

    if (!vazio) {
      for (var i = 0; i < item.presencas.length; i++) {
        DateTime inputDate = DateFormat('dd/MM/yyyy').parse(item.presencas[i]);
        String outputDate = DateFormat('yyyy/MM/dd').format(inputDate);
        presencasOrdenadasY.add(outputDate);
      }
      presencasOrdenadasY.sort((a, b) => a.compareTo(b));

      for (var i = 0; i < presencasOrdenadasY.length; i++) {
        DateTime inputDate =
            DateFormat('yyyy/MM/dd').parse(presencasOrdenadasY[i]);
        String outputDate = DateFormat('dd/MM/yyyy').format(inputDate);
        presencasOrdenadasD.add(outputDate);
      }
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(
                  Icons.info_outline,
                  color: vazio ? Colors.green : Colors.red,
                ),
              ),
              vazio ? Text('Excluir aparelho') : Text('Exclusão bloqueada'),
            ],
          ),
          content: vazio
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Excluir ' + item.name + '?'),
                  ],
                )
              : _buildBloqueioExclusao(context, item, presencasOrdenadasD),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: vazio ? Colors.red : Colors.green,
                backgroundColor: Colors.white,
              ),
              child: vazio ? Text('NÃO') : Text('FECHAR'),
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
            ),
            vazio
                ? TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.green,
                      backgroundColor: Colors.white,
                    ),
                    child: Text('SIM'),
                    onPressed: () async {
                      _animationController.forward();
                      await new Future.delayed(
                        const Duration(milliseconds: 400),
                      );
                      setState(() {
                        controller.selecionarDispositivo(-1);
                        controller.removeSalvos(item);
                        Navigator.pop(context);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          action: SnackBarAction(
                            label: 'Fechar',
                            onPressed: () {},
                          ),
                          content: Text(item.name + ' excluido com sucesso'),
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                      );
                      _animationController.reset();
                    },
                  )
                : null,
          ],
        );
      },
    );
  }

  Widget _buildBloqueioExclusao(BuildContext context,
      BluetoothDeviceCustom item, List<String> presencasOrdenadasD) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
          child: Row(
            children: [
              Text('Presenças registradas: '),
              Text(
                presencasOrdenadasD.length.toString(),
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Divider(
          height: 0,
          indent: 0.0,
          color: Colors.black,
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 181),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            itemCount: presencasOrdenadasD.length,
            separatorBuilder: (BuildContext context, int index) => Divider(
              height: 0,
              indent: 0.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                visualDensity: VisualDensity.compact,
                dense: true,
                contentPadding: EdgeInsets.all(0),
                leading: Text(
                  (index + 1).toString(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                horizontalTitleGap: 0,
                title: Text(
                  '${presencasOrdenadasD[index]}',
                  textAlign: TextAlign.start,
                ),
              );
            },
          ),
        ),
        Divider(
          height: 0,
          indent: 0.0,
          color: Colors.black,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              controller.selecionarDispositivo(-1);
            });
          },
          child: Container(color: Colors.transparent),
        ),
        AutoList<BluetoothDeviceCustom>(
          items: controller.dispositivosSalvos,
          duration: Duration(milliseconds: 300),
          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
          itemBuilder: (context, item) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  controller.selecionarDispositivo(
                      controller.dispositivosSalvos.indexOf(item));
                });
              },
              child: Visibility(
                visible: controller.dispositivosSalvos.indexOf(item) != -1
                    ? true
                    : false,
                child: FadeTransition(
                  opacity: controller.dispositivosSalvos.indexOf(item) ==
                          controller.dispositivoSelecionado
                      ? _animation
                      : _animationNull,
                  child: Card(
                    margin: EdgeInsets.only(top: 8),
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      color: controller.dispositivosSalvos.indexOf(item) ==
                              controller.dispositivoSelecionado
                          ? Colors.green[100]
                          : Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            minVerticalPadding: 0,
                            contentPadding: EdgeInsets.fromLTRB(12, 0, 8, 0),
                            title: Text(
                              item.name,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                              style: (TextStyle(
                                fontSize: 18,
                                color: controller.dispositivosSalvos
                                            .indexOf(item) ==
                                        controller.dispositivoSelecionado
                                    ? Colors.green[900]
                                    : Colors.black,
                              )),
                            ),
                            subtitle: Text(
                              item.address,
                              style: (TextStyle(
                                fontSize: 16,
                                color: controller.dispositivosSalvos
                                            .indexOf(item) ==
                                        controller.dispositivoSelecionado
                                    ? Colors.green[900].withOpacity(0.7)
                                    : Colors.grey[700],
                              )),
                            ),
                            trailing: Stack(
                              alignment: AlignmentDirectional.centerStart,
                              children: [
                                Container(
                                  color: controller.dispositivosSalvos
                                              .indexOf(item) ==
                                          controller.dispositivoSelecionado
                                      ? Colors.green[900].withOpacity(0.7)
                                      : Colors.grey[700],
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                  width: 1,
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: ElevatedButton(
                                    child: Icon(
                                      Icons.edit,
                                      size: 30,
                                      color: controller.dispositivosSalvos
                                                  .indexOf(item) ==
                                              controller.dispositivoSelecionado
                                          ? Colors.green[900]
                                          : Colors.black,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      shadowColor: Colors.transparent,
                                      onSurface: Colors.transparent,
                                      onPrimary: !clicou
                                          ? Colors.green.withOpacity(0.5)
                                          : controller.dispositivosSalvos
                                                      .indexOf(item) ==
                                                  controller
                                                      .dispositivoSelecionado
                                              ? Colors.green[100]
                                                  .withOpacity(0.0)
                                              : Colors.white.withOpacity(0.0),
                                      primary: Colors.transparent,
                                      minimumSize: Size(56, 56),
                                      padding: EdgeInsets.all(0),
                                      elevation: 0,
                                    ),
                                    onPressed: () async {
                                      if (!clicou) {
                                        setState(() {
                                          clicou = true;
                                        });
                                        setState(() {
                                          controller.selecionarDispositivo(
                                              controller.dispositivosSalvos
                                                  .indexOf(item));
                                          _textFieldController.clear();
                                        });
                                        debugPrint(item.toString());
                                        await new Future.delayed(
                                          const Duration(milliseconds: 400),
                                        );
                                        _displayTextInputDialog(context, item);
                                        setState(() {
                                          clicou = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                                  child: ElevatedButton(
                                    child: Icon(
                                      Icons.delete,
                                      size: 30,
                                      color: controller.dispositivosSalvos
                                                  .indexOf(item) ==
                                              controller.dispositivoSelecionado
                                          ? Colors.green[900]
                                          : Colors.black,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      shadowColor: Colors.transparent,
                                      onPrimary: !clicou
                                          ? Colors.green.withOpacity(0.5)
                                          : controller.dispositivosSalvos
                                                      .indexOf(item) ==
                                                  controller
                                                      .dispositivoSelecionado
                                              ? Colors.green[100]
                                                  .withOpacity(0.0)
                                              : Colors.white.withOpacity(0.0),
                                      primary: Colors.transparent,
                                      minimumSize: Size(56, 56),
                                      padding: EdgeInsets.all(0),
                                      elevation: 0,
                                    ),
                                    onPressed: () async {
                                      if (!clicou) {
                                        setState(() {
                                          clicou = true;
                                        });
                                        setState(() {
                                          controller.selecionarDispositivo(
                                              controller.dispositivosSalvos
                                                  .indexOf(item));
                                        });
                                        debugPrint(item.toString());
                                        await new Future.delayed(
                                          const Duration(milliseconds: 400),
                                        );
                                        _displayTextAlert(context, item);
                                        setState(() {
                                          clicou = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
