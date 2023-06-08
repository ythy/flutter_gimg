import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Event{
  String? content;
  String name;
  Event(this.name);
}

var testData = [
  Event("maoxin"),
  Event("maohuitong"),
];


void main() => runApp(MyApp(
  dataList: testData
));

class MyApp extends StatefulWidget  {
  const MyApp({
    super.key,
    required this.dataList
  });
  final List<Event> dataList;

  @override
  State<MyApp> createState() => _MyAppState(dataList);
}

class _MyAppState extends State<MyApp> {
  _MyAppState(List<Event> dataList){
    _dataList = dataList;
  }
  late List<Event> _dataList;

  static const platform = MethodChannel('app.channel.shared.data');
  String dataShared = 'No data';
  List<Event>? _dataListFromNative;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handlePlatform);
    getSharedText();
  }

  Future<dynamic> _handlePlatform(MethodCall methodCall) async {
    final String method = methodCall.method;
    if(method == 'updateList'){
      final List<dynamic> args = methodCall.arguments as List<dynamic>;
      setState(() {
        _dataListFromNative = args.map((e) => Event(e.toString())).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event List',
      home: Scaffold(
        body: Column(
            children: _dataListFromNative == null ? [..._dataList.map((e) =>
                EventRow(
                    data: e
                )
            ).toList(), Text(dataShared)] : [..._dataListFromNative!.map((e) =>
                EventRow(
                    data: e
                )
            ).toList(), Text(dataShared)]
        ),
      ),
    );
  }

  Future<void> getSharedText() async {
    var sharedData = await platform.invokeMethod('getSharedText');
    if (sharedData != null) {
      setState(() {
        dataShared = sharedData;
      });
    }
  }



}


class EventRow extends StatelessWidget {
  const EventRow({
    super.key,
    required this.data
  });

  final Event data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Row(
        children: [
          FavoriteWidget(
            content: data.name,
          )
        ],
      ),
    );
  }
}



class FavoriteWidget extends StatefulWidget {
  const FavoriteWidget({
    super.key,
    this.content = ""
  });

  final String content;

  @override
  State<FavoriteWidget> createState() => _FavoriteWidgetState(content);

}

class _FavoriteWidgetState extends State<FavoriteWidget> {

  _FavoriteWidgetState(String content){
    _content = content;
  }
  late String _content;
  bool _isFavorited = true;


  void _toggleFavorite() {
    setState(() {
      if (_isFavorited) {
        _isFavorited = false;
      } else {
        _isFavorited = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(0),
          child: IconButton(
            padding: const EdgeInsets.all(0),
            alignment: Alignment.centerRight,
            icon: (_isFavorited
                ? const Icon(Icons.star)
                : const Icon(Icons.star_border)),
            color: Colors.red[500],
            onPressed: _toggleFavorite,
          ),
        ),
        SizedBox(
          width: 100,
          child: SizedBox(
            child: Text('$_content'),
          ),
        ),
      ],
    );
  }

}


