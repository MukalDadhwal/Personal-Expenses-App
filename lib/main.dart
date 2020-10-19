import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import './widgets/chart.dart';
import './modals/transaction.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        // errorColor: ,
        // if only this is defined then all text in the app takes this fontFamily
        fontFamily: 'Quicksand',
        // Defining a different theme for text
        textTheme: ThemeData.dark().textTheme.copyWith(
              headline6: TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              headline5: TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14.5,
              ),
              button: TextStyle(
                color: Colors.white,
              ),
            ),
        // This is for appbars theme
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.dark().textTheme.copyWith(
              headline6: TextStyle(fontFamily: 'OpenSans', fontSize: 18.0)),
        ),
      ),
      title: 'Personal Expenses',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  // String titleInput;
  // String amountInput;
  void _startAddNewTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
          child: NewTransaction(_addNewTransactions),
          onTap: () {},
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  final List<Transaction> _userTransactions = [];
  bool _showChart = false;

  @override
  void initState() {
    super.initState();
    // adding a listener to listen the AppLifecycle events
    // This calls didChangeAppLifecycleState() whenever applifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    /*
      paused -> app is running but in the background
      inactive -> the user is not interacing with the app
      resumed -> the app is called again from the background
      detached -> when the app is closed(can be used in backbutton press)
     */
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(DateTime.now().subtract(
        Duration(days: 7),
      ));
    }).toList();
  }

  void _addNewTransactions(String title, double amount, DateTime chosenDate) {
    final newTs = Transaction(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: chosenDate,
    );

    setState(() {
      _userTransactions.add(newTs);
    });
  }

  void _deleteTransactions(String id) {
    setState(() {
      _userTransactions.removeWhere((element) {
        return element.id == id;
      });
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return Platform.isIOS
        ? CupertinoNavigationBar(
            middle: Text(
              'Personal Expenses',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(CupertinoIcons.add),
                  onTap: () => _startAddNewTransaction(context),
                ),
              ],
            ),
          )
        : AppBar(
            title: Text(
              'Personal Expenses',
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  _startAddNewTransaction(context);
                },
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // This will be true or false according to the device orientation
    final isLandScape = mediaQuery.orientation == Orientation.landscape;
    final appBar = _buildAppBar();

    /*
    Here we are subtracting the size the of appBar from the complete height so that we can get the actual screen size to add our widgets
    */
    final chart = Container(
      child: Chart(_recentTransactions),
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.3,
    );

    final txList = Container(
      child: TransactionList(_userTransactions, _deleteTransactions),
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
    );

    return Platform.isIOS
        ? CupertinoPageScaffold(
            child: CupertinoButton(child: Text('Button'), onPressed: () {}))
        : Scaffold(
            appBar: appBar,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isLandScape)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Show Chart',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Switch(
                          value: _showChart,
                          onChanged: (val) {
                            setState(() {
                              _showChart = val;
                            });
                          },
                        ),
                      ],
                    ),
                  // Logic to show different widgets on the basis of orientation
                  if (!isLandScape)
                    Column(children: [
                      chart,
                      txList,
                    ]),
                  if (isLandScape)
                    _showChart
                        ? Container(
                            child: Chart(_recentTransactions),
                            height: (mediaQuery.size.height -
                                    appBar.preferredSize.height -
                                    mediaQuery.padding.top) *
                                0.7,
                          )
                        : txList
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _startAddNewTransaction(context);
              },
              child: Icon(Icons.add),
            ),
          );
  }
}
