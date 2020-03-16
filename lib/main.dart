import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './widgets/new_transaction.dart';
import './widgets/transactions_list.dart';
import './models/transaction.dart';
import './widgets/chart.dart';

void main() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.amber,
        fontFamily: 'Quicksand',
        textTheme: ThemeData
            .light()
            .textTheme
            .copyWith(
          title: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          button: TextStyle(
            color: Colors.white,
          ),
        ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData
              .light()
              .textTheme
              .copyWith(
            title: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
            ),
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _userTransactions = [
    Transaction(
      id: DateTime.now().toString(),
      title: 'new stuff',
      amount: 25,
      date: DateTime.now(),
    ),
    Transaction(
      id: DateTime.now().toString(),
      title: 'new stuff',
      amount: 25,
      date: DateTime.now(),
    ),
    Transaction(
      id: DateTime.now().toString(),
      title: 'new stuff',
      amount: 25,
      date: DateTime.now(),
    ),
    Transaction(
      id: DateTime.now().toString(),
      title: 'new stuff',
      amount: 25,
      date: DateTime.now(),
    ),
    Transaction(
      id: DateTime.now().toString(),
      title: 'new stuff',
      amount: 25,
      date: DateTime.now(),
    ),
    Transaction(
      id: DateTime.now().toString(),
      title: 'new stuff',
      amount: 25,
      date: DateTime.now(),
    ),
  ];

  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(String title, double amount, DateTime date) {
    final newTx = Transaction(
      title: title,
      amount: amount,
      date: date,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((item) => item.id == id);
    });
  }

  bool _showChart = false;

  Widget _buildLandscapeContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text('show chart'),
        Switch.adaptive(
          value: _showChart,
          onChanged: (val) {
            setState(() {
              _showChart = val;
            });
          },
        ),
      ],
    );
  }

  List<Widget> _buildPortraitContent(MediaQueryData mediaQuery, AppBar appBar,
      Widget txListWidget) {
    return [
      Container(
        height: (mediaQuery.size.height -
            appBar.preferredSize.height -
            mediaQuery.padding.top) *
            0.3,
        child: Chart(_recentTransactions),
      ),
      txListWidget
    ];
  }

  Widget _buildIosAppBar() {
    return CupertinoNavigationBar(
      middle: Text('expenses app'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: () => _startAddNewTransaction(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidAppBar() {
    return AppBar(
      title: Text('flutter app'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
        ),
      ],
    );
  }

  Widget _buildAndroidScaffold(AppBar appBar, pageBody) {
    return Scaffold(
      appBar: appBar,
      body: pageBody,
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Platform.isIOS
          ? Container()
          : FloatingActionButton(
        backgroundColor: Theme
            .of(context)
            .accentColor,
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }

  Widget _buildIosScaffold(Widget appBar, pageBody) {
    return CupertinoPageScaffold(
      child: pageBody,
      navigationBar: appBar,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('build() main');
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final PreferredSizeWidget appBar =
    Platform.isIOS ? _buildIosAppBar() : _buildAndroidAppBar();
    final txListWidget = Container(
      height: (mediaQuery.size.height -
          appBar.preferredSize.height -
          mediaQuery.padding.top),
      child: TransactionList(_userTransactions, _deleteTransaction),
    );
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape) _buildLandscapeContent(),
            if (!isLandscape)
              ..._buildPortraitContent(mediaQuery, appBar, txListWidget),
            if (!isLandscape) txListWidget,
            _showChart
                ? Container(
              height: (mediaQuery.size.height -
                  appBar.preferredSize.height -
                  mediaQuery.padding.top) *
                  0.7,
              child: Chart(_recentTransactions),
            )
                : txListWidget,
          ],
        ),
      ),
    );
    return Platform.isIOS
        ? _buildIosScaffold(appBar, pageBody) : _buildAndroidScaffold(appBar, pageBody);
  }
}
