import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'token_storage.dart';

class SocketClient {
  SocketClient._();
  static IO.Socket? _socket;

  static IO.Socket get socket => _socket!;

  static Future<void> connect() async {
    if (_socket != null && _socket!.connected) return;

    final token = await TokenStorage.getAccessToken();

    _socket = IO.io(
      'https://api-prod.uidehub.tech',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({
            if (token != null) 'Authorization': 'Bearer $token',
          })
          .build(),
    );

    _socket!.connect();
  }

  static void joinObjeto(String objetoId) {
    _socket?.emit('join_objeto', {'objetoId': objetoId});
  }

  static void leaveObjeto(String objetoId) {
    _socket?.emit('leave_objeto', {'objetoId': objetoId});
  }

  static void onComentarioNuevo(void Function(dynamic data) handler) {
    _socket?.on('comentario_nuevo', handler);
  }

  static void offComentarioNuevo() {
    _socket?.off('comentario_nuevo');
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
