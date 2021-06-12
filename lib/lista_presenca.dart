import 'package:autolist/autolist.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'bluetooth_devices_custom.dart';
import 'lista_dispositivos.dart';
import 'main.dart';

import 'package:table_calendar/table_calendar.dart';

class ListaPresenca extends StatefulWidget {
  final void Function(int) jumpToPage;
  const ListaPresenca({Key key, this.jumpToPage}) : super(key: key);

  @override
  _ListaPresencaState createState() => _ListaPresencaState();
}

class _ListaPresencaState extends State<ListaPresenca>
    with
        AutomaticKeepAliveClientMixin<ListaPresenca>,
        TickerProviderStateMixin {
  final controller = GetIt.I.get<ListaDispositivos>();
  bool clicou = false;
  bool _dividerExpanded = true;
  bool _dispositivosExpanded = true;
  bool _calendarioExpanded = false;
  Color corBotao = Colors.white;
  int flexLista = 1;
  int flexCalendario = 0;

  CalendarController _calendarController;
  AnimationController _animationController;
  AnimationController _animationControllerNull;
  Animation _animation;
  Animation _animationNull;

  String _selectedDaySemana = '';

  void _toogleDividerExpanded() {
    setState(() {
      _dividerExpanded = !_dividerExpanded;
    });
  }

  void _toogleCorBotao() {
    setState(() {
      if (corBotao == Colors.white) {
        corBotao = Colors.green[100];
      } else {
        corBotao = Colors.white;
      }
    });
  }

  void _toogleDispositivosExpanded() {
    setState(() {
      _dispositivosExpanded = !_dispositivosExpanded;
      if (flexLista == 1) {
        flexLista = 0;
      } else {
        flexLista = 1;
      }
    });
  }

  void _toogleCalendarioExpanded() {
    setState(() {
      _calendarioExpanded = !_calendarioExpanded;
      if (flexCalendario == 1) {
        flexCalendario = 0;
      } else {
        flexCalendario = 1;
      }
    });
  }

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
    _calendarController = CalendarController();
    _formatarDataInicial(controller.selectedDay);
  }

  @override
  void dispose() {
    getIt<ListaDispositivos>().removeListener(update);
    _calendarController.dispose();
    _animationController.dispose();
    _animationControllerNull.dispose();
    super.dispose();
  }

  void update() => setState(() => {});

  void _onDaySelected(DateTime day, List events, List holidays) {
    setState(() {
      controller.setSelectDay(day);
      controller.setSelectedDayData(
          DateFormat.yMd('pt_BR').format(controller.selectedDay));
      _selectedDaySemana =
          DateFormat('EEEEE', 'pt_BR').format(controller.selectedDay);
    });
  }

  void _formatarDataInicial(DateTime day) {
    setState(() {
      // controller.setSelectedDayData(
      //     DateFormat.yMd('pt_BR').format(controller.selectedDay));
      _selectedDaySemana =
          DateFormat('EEEEE', 'pt_BR').format(controller.selectedDay);
    });
  }

  Future<void> _displayTextAlert(
      BuildContext context, BluetoothDeviceCustom item) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Excluir presença'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Excluir presença de ' + item.name + '?',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.red,
                backgroundColor: Colors.white,
              ),
              child: Text('NÃO'),
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
              child: Text('SIM'),
              onPressed: () async {
                _animationController.forward();
                await new Future.delayed(
                  const Duration(milliseconds: 400),
                );
                setState(() {
                  controller.selecionarDispositivoLista(-1);
                  controller.removePresenca(item);
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
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        controller.selecionarDispositivoLista(-1);
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Card(
                margin: EdgeInsets.fromLTRB(8, 8, 8, 8),
                elevation: 2,
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        color: corBotao,
                        child: ListTile(
                          minVerticalPadding: 0, 
                          contentPadding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                          horizontalTitleGap: 7,
                          leading: Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: [
                              Positioned(
                                left: 16,
                                top: 21,
                                child: Container(
                                  child: Icon(
                                    Icons.stop,
                                    size: 15,
                                    color: corBotao == Colors.white
                                        ? Colors.black
                                        : Colors.green[900],
                                  ),
                                ),
                              ),
                              Container(
                                color: Colors.transparent,
                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: ClipOval(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: IconButton(
                                      icon: Icon(Icons.calendar_today),
                                      iconSize: 30,
                                      padding: EdgeInsets.all(13),
                                      color: Colors.black,
                                      disabledColor: corBotao == Colors.white
                                          ? Colors.black
                                          : Colors.green[900],
                                      onPressed: null,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            controller.selectedDayData,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style: (TextStyle(
                              fontSize: 18,
                              color: corBotao == Colors.white
                                  ? Colors.black
                                  : Colors.green[900],
                            )),
                          ),
                          subtitle: Text(
                            _selectedDaySemana,
                            style: (TextStyle(
                              fontSize: 16,
                              color: corBotao == Colors.white
                                  ? Colors.grey[700]
                                  : Colors.green[900].withOpacity(0.7),
                            )),
                          ),
                          trailing: Stack(
                            alignment: AlignmentDirectional.centerStart,
                            children: [
                              Container(
                                color: corBotao == Colors.white
                                    ? Colors.grey[700]
                                    : Colors.green[900].withOpacity(0.7),
                                width: 1,
                              ),
                              Positioned(
                                right: 18,
                                top: 21,
                                child: Container(
                                  child: Icon(
                                    Icons.cached_rounded,
                                    size: corBotao == Colors.white ? 20 : 0,
                                    color: corBotao == Colors.white
                                        ? Colors.black
                                        : Colors.green[900],
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
                                      icon: Icon(corBotao == Colors.white
                                          ? Icons.calendar_today
                                          : Icons.check_circle_outline_rounded),
                                      iconSize:
                                          corBotao == Colors.white ? 30 : 35,
                                      padding: EdgeInsets.all(
                                          corBotao == Colors.white ? 13 : 10.5),
                                      color: corBotao == Colors.white
                                          ? Colors.black
                                          : Colors.green[900],
                                      splashColor: !clicou
                                          ? corBotao == Colors.white
                                              ? Colors.black.withOpacity(0.1)
                                              : Colors.green.withOpacity(0.5)
                                          : Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      onPressed: () async {
                                        if (!clicou) {
                                          setState(() {
                                            clicou = true;
                                          });
                                          if (_dispositivosExpanded) {
                                            debugPrint('LISTA PARA CALENDÁRIO');
                                            _toogleDispositivosExpanded();
                                            _toogleDividerExpanded();
                                            await new Future.delayed(
                                              const Duration(milliseconds: 550),
                                            );
                                            _toogleCorBotao();
                                            _toogleCalendarioExpanded();
                                            controller
                                                .selecionarDispositivoLista(-1);
                                          } else {
                                            debugPrint('CALENDÁRIO PARA LISTA');
                                            _toogleCalendarioExpanded();
                                            _toogleCorBotao();
                                            controller.addDay();
                                            await new Future.delayed(
                                              const Duration(milliseconds: 550),
                                            );
                                            _toogleDividerExpanded();
                                            _toogleDispositivosExpanded();
                                            ScaffoldMessenger.of(context)
                                                .removeCurrentSnackBar();
                                          }
                                          setState(() {
                                            clicou = false;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedPadding(
                      duration: Duration(milliseconds: 500),
                      padding: _dividerExpanded
                          ? EdgeInsets.fromLTRB(8, 0, 8, 4)
                          : EdgeInsets.fromLTRB(0, 0, 0, 4),
                      child: Divider(
                        height: 1,
                        thickness: 1.0,
                        color: corBotao == Colors.white
                            ? Colors.grey[700]
                            : Colors.green[900].withOpacity(0.7),
                      ),
                    ),
                    Flexible(
                      flex: flexCalendario,
                      child: SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.all(0),
                          child: Column(
                            children: <Widget>[
                              ExpandedSection(
                                expand: _calendarioExpanded,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(6, 0, 6, 6),
                                  child: TableCalendar(
                                    locale: 'pt_BR',
                                    calendarController: _calendarController,
                                    events: controller.events,
                                    startingDayOfWeek: StartingDayOfWeek.sunday,
                                    calendarStyle: CalendarStyle(
                                      contentPadding:
                                      EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      cellMargin: EdgeInsets.all(3),
                                      selectedColor: Colors.green[900],
                                      todayColor: Colors.green[100],
                                      markersAlignment: Alignment.bottomCenter,
                                      markersColor: Colors.green,
                                      markersPositionBottom: 7.0,
                                      weekendStyle: TextStyle(
                                        color: Colors.red,
                                      ),
                                      outsideStyle: TextStyle(
                                        color: Colors.black.withOpacity(0.2),
                                      ),
                                      outsideWeekendStyle: TextStyle(
                                        color: Colors.red.withOpacity(0.2),
                                      ),
                                      outsideDaysVisible: true,
                                    ),
                                    headerStyle: HeaderStyle(
                                      formatButtonVisible: false,
                                      headerMargin: EdgeInsets.all(0),
                                      headerPadding: EdgeInsets.all(0),
                                      centerHeaderTitle: true,
                                    ),
                                    availableGestures:
                                    AvailableGestures.horizontalSwipe,
                                    onDaySelected: _onDaySelected,
                                    daysOfWeekStyle: DaysOfWeekStyle(
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                      ),
                                      weekdayStyle: TextStyle(
                                        color: Colors.green[900],
                                      ),
                                    ),
                                    builders: CalendarBuilders(
                                      markersBuilder:
                                          (context, date, events, holidays) {
                                        var children = <Widget>[];

                                        if (events.isNotEmpty) {
                                          children.add(
                                            Positioned(
                                              right: 1,
                                              bottom: 1,
                                              child: _buildEventsMarker(
                                                date,
                                                events,
                                              ),
                                            ),
                                          );
                                        }
                                        return children;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: flexLista,
                      child: ExpandedSection(
                        expand: _dispositivosExpanded,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: _buildListaPresenca(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaPresenca() {
    if (controller.mapPresencas[controller.selectedDayData] == null) {
      return Container(
        child: Text('NULO UAI'),
      );
    } else if (controller.mapPresencas[controller.selectedDayData].isEmpty) {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: 1,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            minVerticalPadding: 0,
            contentPadding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            title: Text(
              'SEM PRESENÇAS REGISTRADAS',
              textAlign: TextAlign.center,
            ),
          );
        },
      );
    }
    return AutoList<BluetoothDeviceCustom>(
      items: controller.mapPresencas[controller.selectedDayData],
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(0),
      itemBuilder: (context, item) {
        return GestureDetector(
          onTap: () {
            controller.selecionarDispositivoLista(
                controller.dispositivosSalvos.indexOf(item));
          },
          child: Visibility(
            visible: controller.mapPresencas[controller.selectedDayData]
                        .indexOf(item) !=
                    -1
                ? true
                : false,
            child: FadeTransition(
              opacity: controller.dispositivosSalvos.indexOf(item) ==
                      controller.dispositivoSelecionadoLista
                  ? _animation
                  : _animationNull,
              child: Container(
                key: Key(item.toString()),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  color: controller.dispositivosSalvos.indexOf(item) ==
                          controller.dispositivoSelecionadoLista
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
                            color:
                                controller.dispositivosSalvos.indexOf(item) ==
                                        controller.dispositivoSelecionadoLista
                                    ? Colors.green[900]
                                    : Colors.black,
                          )),
                        ),
                        subtitle: Text(
                          item.address,
                          style: (TextStyle(
                            fontSize: 16,
                            color:
                                controller.dispositivosSalvos.indexOf(item) ==
                                        controller.dispositivoSelecionadoLista
                                    ? Colors.green[900].withOpacity(0.7)
                                    : Colors.grey[700],
                          )),
                        ),
                        trailing: Stack(
                          alignment: AlignmentDirectional.centerStart,
                          children: [
                            Container(
                              color:
                                  controller.dispositivosSalvos.indexOf(item) ==
                                          controller.dispositivoSelecionadoLista
                                      ? Colors.green[900].withOpacity(0.7)
                                      : Colors.grey[700],
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              width: 1,
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(9, 0, 0, 0),
                              child: ElevatedButton(
                                child: Icon(
                                  Icons.delete,
                                  size: 30,
                                  color: controller.dispositivosSalvos
                                              .indexOf(item) ==
                                          controller.dispositivoSelecionadoLista
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
                                                  .dispositivoSelecionadoLista
                                          ? Colors.green[100].withOpacity(0.0)
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
                                    controller.selecionarDispositivoLista(
                                        controller.dispositivosSalvos
                                            .indexOf(item));
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
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.green[100]
            : _calendarController.isToday(date)
                ? Colors.green[900]
                : Colors.green[100],
      ),
      width: 14.0,
      height: 14.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: _calendarController.isSelected(date)
                ? Colors.black
                : _calendarController.isToday(date)
                    ? Colors.white
                    : Colors.black,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ExpandedSection extends StatefulWidget {
  final Widget child;
  final bool expand;
  ExpandedSection({this.expand = false, this.child});

  @override
  _ExpandedSectionState createState() => _ExpandedSectionState();
}

class _ExpandedSectionState extends State<ExpandedSection>
    with SingleTickerProviderStateMixin {
  AnimationController expandController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (widget.expand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void didUpdateWidget(ExpandedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
        axisAlignment: 1.0, sizeFactor: animation, child: widget.child);
  }
}

class ConstrainedFlexView extends StatelessWidget {
  final Widget child;
  final double minSize;
  final Axis axis;

  const ConstrainedFlexView(this.minSize, {Key key, this.child, this.axis})
      : super(key: key);

  bool get isHz => axis == Axis.horizontal;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        double viewSize = isHz ? constraints.maxWidth : constraints.maxHeight;
        if (viewSize > minSize) return child;
        return SingleChildScrollView(
          scrollDirection: axis ?? Axis.vertical,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: isHz ? double.infinity : minSize,
                maxWidth: isHz ? minSize : double.infinity),
            child: child,
          ),
        );
      },
    );
  }
}
