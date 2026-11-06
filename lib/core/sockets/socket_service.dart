import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

class TicketSocketEvent {
  const TicketSocketEvent(this.event, this.payload);

  final String event;
  final Map<String, dynamic> payload;

  String get mensaje {
    final custom = payload['mensaje'];
    if (custom is String && custom.isNotEmpty) return custom;
    final folio = payload['codigo_ticket'] ?? 'Ticket';
    switch (event) {
      case 'ticket:creado':
        return 'Nuevo ticket $folio';
      case 'ticket:asignado':
        return 'Ticket $folio asignado';
      case 'ticket:actualizado':
        return 'Ticket $folio actualizado';
      default:
        return 'Actualizacion de $folio';
    }
  }
}

/// Conexion Socket.io autenticada con JWT.
class SocketService {
  final StreamController<TicketSocketEvent> _controller =
      StreamController<TicketSocketEvent>.broadcast();

  io.Socket? _socket;
  String? _connectedToken;

  Stream<TicketSocketEvent> get events => _controller.stream;
  bool get isConnected => _socket?.connected ?? false;

  void connect({required String url, required String token}) {
    if (_connectedToken == token && isConnected) return;
    disconnect();
    _connectedToken = token;

    final socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setAuth({'token': token})
          .enableReconnection()
          .build(),
    );

    void bind(String event) {
      socket.on(event, (data) {
        if (data is Map) {
          _controller.add(
            TicketSocketEvent(event, Map<String, dynamic>.from(data)),
          );
        }
      });
    }

    bind('ticket:creado');
    bind('ticket:asignado');
    bind('ticket:actualizado');

    socket.connect();
    _socket = socket;
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
    _connectedToken = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
