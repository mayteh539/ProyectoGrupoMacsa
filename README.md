# Macsa Tickets - Aplicacion Flutter

Aplicacion web y Android del sistema de tickets de soporte tecnico de
**Grupo Macsa**, construida con Flutter y Clean Architecture.

Consume la API del proyecto hermano `ApiGrupoMacsa`
(Node.js + TypeScript + SQL Server + Socket.io).

## Funcionalidades

### Por rol

- **ADMIN_IT**
  - Ve todos los tickets y sus indicadores.
  - Asigna y reasigna tecnicos.
  - Cambia estados, agrega notas y evidencias.
  - Acceso al dashboard y a los reportes.
- **TECNICO_IT**
  - Ve los tickets del departamento de IT.
  - Inicia y resuelve los tickets que tiene asignados.
  - Agrega notas y evidencias.
- **SOLICITANTE**
  - Crea tickets con evidencia fotografica.
  - Consulta el estado y el kardex de sus tickets.
  - Cancela tickets en `ABIERTO` o `ASIGNADO`.
  - Responde la encuesta obligatoria cuando el ticket esta `RESUELTO`.

### Generales

- Login con JWT y almacenamiento seguro del token.
- Listado con busqueda, filtros por estado/prioridad y paginacion infinita.
- Detalle con linea de tiempo del kardex y galeria de evidencias.
- Dashboard con KPIs, tendencia, distribucion por estado y satisfaccion.
- Reportes por categoria, prioridad, departamento, equipos, solicitantes y
  tiempos de resolucion (graficas con `fl_chart`).
- Catalogo de equipos con filtro por departamento.
- Perfil con cambio de contrasena y cierre de sesion.
- Notificaciones y actualizacion en tiempo real con Socket.io.
- Tema claro, interfaz en espanol y diseno responsive (movil, tablet, web).

## Arquitectura

Clean Architecture estricta por funcionalidad:

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/        AppConfig (URL de API, timeouts)
│   ├── models/        PagedResult, UploadFile
│   ├── network/       ApiClient (Dio), ApiException
│   ├── providers/     Providers base (cliente, storage, socket)
│   ├── router/        GoRouter, AppShell con navegacion inferior
│   ├── sockets/       SocketService
│   ├── storage/       TokenStorage (flutter_secure_storage)
│   ├── theme/         AppTheme
│   ├── utils/         Formatters, Validators
│   └── widgets/       Widgets compartidos (cards, estados, badges)
└── features/
    ├── auth/
    ├── assets/
    ├── tickets/
    ├── survey/
    └── reports/
        ├── domain/         Entidades y contratos de repositorio
        ├── data/           Modelos JSON, datasources y repositorios
        └── presentation/   Providers, paginas y widgets
```

Reglas de dependencia:

- `domain` no importa `data` ni `presentation`.
- `data` implementa los contratos de `domain`.
- `presentation` solo conoce `domain` (y providers de Riverpod).
- La subida de archivos usa `UploadFile` (`name` + `bytes`) en `domain`,
  de modo que el dominio no dependa de `XFile` ni de `dart:io`.

### Stack

| Area | Paquete |
| --- | --- |
| Estado | `flutter_riverpod` 3.x |
| Navegacion | `go_router` 16.x |
| HTTP | `dio` 5.x |
| Tiempo real | `socket_io_client` 3.x |
| Token seguro | `flutter_secure_storage` 9.x |
| Imagenes | `image_picker`, `cached_network_image` |
| Graficas | `fl_chart` 0.69.x |
| Formatos | `intl` |

Los modelos JSON se escriben a mano (sin `build_runner`).

## Requisitos

- Flutter 3.47 o superior (canal stable).
- Android SDK para compilar el APK.
- API `ApiGrupoMacsa` en ejecucion.

## Configuracion de la API

La URL se resuelve en `lib/core/config/app_config.dart`:

| Plataforma | URL por defecto |
| --- | --- |
| Web | `http://localhost:3000` |
| Emulador Android | `http://10.0.2.2:3000` |
| Otros | `http://localhost:3000` |

Para apuntar a otro servidor (dispositivo fisico o planta), use
`--dart-define`:

```powershell
flutter run --dart-define=API_URL=http://192.168.1.50:3000
```

El valor tambien aplica a Socket.io y a las URLs de evidencias.

## Ejecucion

```powershell
cd C:\Users\mayte\Documents\ProyectoGrupoMacsa
flutter pub get
flutter run -d chrome --dart-define=API_URL=http://localhost:3000
flutter run -d <device-id> --dart-define=API_URL=http://192.168.1.50:3000
```

## Compilacion

```powershell
# Web (build\web)
flutter build web --release --dart-define=API_URL=http://192.168.1.50:3000

# Android (build\app\outputs\flutter-apk\app-release.apk)
flutter build apk --release --dart-define=API_URL=http://192.168.1.50:3000
```

## Calidad

```powershell
flutter analyze    # 0 issues
flutter test       # pruebas unitarias de formatters, validators, modelos
```

## Usuarios demo

| Usuario | Contrasena | Rol |
| --- | --- | --- |
| `admin` | `Macsa2026!` | ADMIN_IT |
| `tecnico1` | `Tecnico2026!` | TECNICO_IT |
| `tecnico2` | `Tecnico2026!` | TECNICO_IT |
| `solicitante1` | `Solicitante2026!` | SOLICITANTE |
| `solicitante2` | `Solicitante2026!` | SOLICITANTE |
| `solicitante3` | `Solicitante2026!` | SOLICITANTE |

## Flujo de un ticket

1. El solicitante crea el ticket (`ABIERTO`) con asunto, descripcion,
   categoria, prioridad y evidencia opcional.
2. El administrador lo asigna a un tecnico (`ASIGNADO`).
3. El tecnico inicia la atencion (`EN_PROCESO`).
4. El tecnico lo marca como resuelto (`RESUELTO`).
5. El solicitante responde la encuesta (solucion, 1-5 estrellas, comentarios)
   y el ticket pasa a `CERRADO`.
6. Cada paso genera una entrada en el kardex visible en el detalle.

## APK

El APK compilado se copia a `..\ApiGrupoMacsa\apk\MacsaTickets-v1.0.0.apk`
para su distribucion en planta y se publica en `http://<servidor>:3000/apk/`.

> El build release usa la clave de debug de Flutter. Antes de una distribucion
> formal, configure un keystore propio (ver `DEPLOY.md`).

## Despliegue

Consulte `DEPLOY.md` para la puesta en marcha completa (base de datos, API,
servicio de Windows, red, web y APK).
