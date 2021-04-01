import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'lista_dispositivos.dart';
import 'lista_presenca.dart';
import 'buscar_dispositivos.dart';
import 'dispositivos_salvos.dart';

// This is our global ServiceLocator
GetIt getIt = GetIt.instance;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  getIt.registerSingleton<ListaDispositivos>(ListaDispositivosImplementation(),
      signalsReady: true);

  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Lista de Presença via Bluetooth'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _selectedPageIndex;
  List<Widget> _pages;
  PageController pageController;
  final controller = GetIt.I.get<ListaDispositivos>();

  @override
  void initState() {
    getIt
        .isReady<ListaDispositivos>()
        .then((_) => getIt<ListaDispositivos>().addListener(update));

    super.initState();
    _selectedPageIndex = 0;

    _pages = [
      ListaPresenca(jumpToPage: jumpToPage),
      BuscarDispositivos(jumpToPage: jumpToPage),
      DispositivosSalvos(jumpToPage: jumpToPage),
    ];

    controller.inicializarApp();

    pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    getIt<ListaDispositivos>().removeListener(update);
    pageController.dispose();

    super.dispose();
  }

  void update() => setState(() => {});

  void jumpToPage(int index) {
    setState(() {
      _selectedPageIndex = index;
      pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
          future: getIt.allReady(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(widget.title),
                ),
                body: PageView(
                  controller: pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: _pages,
                ),
                backgroundColor: Colors.green[50],
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Colors.green,
                  items: [
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Icon(
                          Icons.playlist_add_check,
                        ),
                      ),
                      label: 'Lista de Presença',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Icon(
                          Icons.bluetooth_searching,
                        ),
                      ),
                      label: 'Buscar Aparelhos',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        child: Icon(
                          Icons.devices_other,
                        ),
                      ),
                      label: 'Aparelhos Salvos',
                    ),
                  ],
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white54,
                  selectedIconTheme: IconThemeData(size: 30),
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  currentIndex: _selectedPageIndex,
                  onTap: (selectedPageIndex) {
                    if (controller.appInicializado) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      setState(() {
                        _selectedPageIndex = selectedPageIndex;
                        jumpToPage(selectedPageIndex);
                      });
                    } else {
                      if (selectedPageIndex != 0) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            action: SnackBarAction(
                              label: 'Fechar',
                              onPressed: () {},
                            ),
                            content: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.info_outline,
                                    color: Colors.yellow,
                                  ),
                                ),
                                Text('Selecione uma data primeiro'),
                              ],
                            ),
                            duration: const Duration(milliseconds: 2000),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      }
                    }
                  },
                ),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Inicializando, aguarde...'),
                  SizedBox(
                    height: 16,
                  ),
                  CircularProgressIndicator(),
                ],
              );
            }
          }),
    );
  }
}
