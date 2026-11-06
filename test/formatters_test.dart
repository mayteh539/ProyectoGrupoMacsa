import 'package:flutter_test/flutter_test.dart';
import 'package:macsa_tickets_app/core/models/paged_result.dart';
import 'package:macsa_tickets_app/core/utils/formatters.dart';
import 'package:macsa_tickets_app/core/utils/validators.dart';
import 'package:macsa_tickets_app/features/tickets/domain/entities/ticket.dart';

void main() {
  group('formatters', () {
    test('formatDuracion convierte minutos a texto legible', () {
      expect(formatDuracion(null), 'Sin datos');
      expect(formatDuracion(45), '45 min');
      expect(formatDuracion(90), '1h 30m');
      expect(formatDuracion(60 * 26), '1d 2h');
    });

    test('iniciales toma la primera letra del nombre y del apellido', () {
      expect(iniciales('Juan Perez'), 'JP');
      expect(iniciales('Ana'), 'A');
      expect(iniciales('   '), '?');
    });
  });

  group('validators', () {
    test('required rechaza vacios', () {
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('valor'), isNull);
    });

    test('email valida el formato', () {
      expect(Validators.email('mal-correo'), isNotNull);
      expect(Validators.email('usuario@grupomacsa.com'), isNull);
    });
  });

  group('PagedResult', () {
    test('mapea datos y metadatos', () {
      final result = PagedResult<int>.fromJson(
        {
          'data': [
            {'valor': 1},
            {'valor': 2},
          ],
          'meta': {'page': 1, 'limit': 20, 'total': 2, 'totalPages': 1},
        },
        (json) => json['valor'] as int,
      );

      expect(result.data, [1, 2]);
      expect(result.total, 2);
      expect(result.hasMore, isFalse);
    });
  });

  group('Ticket', () {
    test('folio y pendienteEncuesta derivan del estado', () {
      const ticket = Ticket(
        idTicket: 7,
        asunto: 'Sin red',
        descripcionProblema: 'No hay conexion',
        prioridad: 'ALTA',
        estado: 'RESUELTO',
        fechaCreacion: '2026-01-01T10:00:00Z',
        fechaActualizacion: '2026-01-01T11:00:00Z',
        idSolicitante: 4,
        solicitante: 'Solicitante Uno',
        usuarioSolicitante: 'solicitante1',
        idEquipo: 1,
        codigoActivo: 'PC-001',
        nombreEquipo: 'PC Empaque',
        categoriaEquipo: 'PC',
        idCategoria: 1,
        nombreCategoria: 'Red',
        idDepartamento: 1,
        nombreDepartamento: 'Produccion',
        totalAdjuntos: 0,
      );

      expect(ticket.folio, 'TCK-7');
      expect(ticket.pendienteEncuesta, isTrue);
      expect(ticket.estaResuelto, isTrue);
      expect(ticket.estaCerrado, isFalse);
    });
  });
}
