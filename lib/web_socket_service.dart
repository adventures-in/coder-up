import 'dart:async';

import 'package:web_socket_channel/web_socket_channel.dart';

const uriString = 'ws://web-socket-analysis-server-3rru3aooga-uc.a.run.app';

class WebSocketService {
  WebSocketService() {
    _webSocket = WebSocketChannel.connect(Uri.parse(uriString));
    _subscription = _webSocket.stream.listen((data) {
      _controller.add(data);
    }, onError: _error, onDone: _done);
  }

  late final WebSocketChannel _webSocket;
  late final StreamSubscription _subscription;
  final _controller = StreamController<String>();

  publish(String message) => _webSocket.sink.add(message);

  Stream get stream => _controller.stream;

  _error(err) => print('${DateTime.now()} > CONNECTION ERROR: $err');

  _done() =>
      '${DateTime.now()} > CONNECTION DONE! closeCode=${_webSocket.closeCode}, closeReason= ${_webSocket.closeReason}';

  Future<dynamic> close() async {
    await _subscription.cancel();
    return _webSocket.sink.close();
  }
}
