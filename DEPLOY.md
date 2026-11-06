# Guia de despliegue - Macsa Tickets

Puesta en marcha del sistema de tickets de soporte tecnico de Grupo Macsa en
una red local (on-premise).

El sistema tiene tres piezas:

1. **SQL Server** con la base de datos `DB_MACSA_TICKETS`.
2. **API** Node.js (`ApiGrupoMacsa`) escuchando en el puerto 3000.
3. **Aplicacion Flutter** (web y Android) que consume la API.

---

## 1. Requisitos del servidor

| Componente | Requisito |
| --- | --- |
| Sistema operativo | Windows Server 2019/2022 o Windows 10/11 |
| SQL Server | 2019 o superior (Express es suficiente para planta pequena) |
| Node.js | 20 LTS o superior |
| Red | Puerto 3000 accesible desde la LAN |
| Espacio | ~2 GB (Node, dependencias, evidencias, base de datos) |

El servidor debe tener IP fija o nombre DNS resuelto en la red, por ejemplo
`192.168.1.50`. Ese valor se usara en todas las URLs.

---

## 2. Base de datos

### 2.1 Crear la instancia y el usuario

1. Instale SQL Server con autenticacion mixta (Windows + SQL).
2. Habilite TCP/IP y el puerto `1433` (SQL Server Configuration Manager).
3. Verifique que el servicio SQL Server Browser este en ejecucion.

### 2.2 Crear la base de datos

Copie la carpeta `ApiGrupoMacsa` al servidor y ejecute:

```powershell
cd C:\Apps\ApiGrupoMacsa
npm install
Copy-Item .env.example .env
notepad .env
```

Ajuste como minimo:

```env
NODE_ENV=production
PORT=3000
CORS_ORIGINS=http://192.168.1.50
PUBLIC_BASE_URL=http://192.168.1.50:3000
DB_SERVER=localhost
DB_PORT=1433
DB_NAME=DB_MACSA_TICKETS
DB_USER=sa
DB_PASSWORD=SU_PASSWORD_SEGURA
JWT_SECRET=UN_SECRETO_DE_AL_MENOS_32_CARACTERES
```

Luego:

```powershell
npm run db:setup
npm run seed:users
```

Esto crea tablas, indices, llaves foraneas, triggers de auditoria, vistas,
catalogos demo y usuarios con contrasena bcrypt.

> `npm run db:reset` elimina y recrea la base de datos. Usarlo solo en
> instalaciones nuevas, nunca en produccion con datos reales.

### 2.3 Verificar

```powershell
sqlcmd -S localhost -U sa -P "SU_PASSWORD_SEGURA" -I -Q "SELECT COUNT(*) FROM DB_MACSA_TICKETS.dbo.Tickets"
```

---

## 3. API en produccion

### 3.1 Compilar

```powershell
cd C:\Apps\ApiGrupoMacsa
npm run typecheck
npm run build
npm start
```

Compruebe:

- `http://192.168.1.50:3000/api/health` devuelve `status: ok`.
- `http://192.168.1.50:3000/api/docs` abre Swagger.

### 3.2 Registrar como servicio de Windows

Con [NSSM](https://nssm.cc/):

```powershell
nssm install MacsaTicketsApi "C:\Program Files\nodejs\node.exe" "C:\Apps\ApiGrupoMacsa\dist\server.js"
nssm set MacsaTicketsApi AppDirectory "C:\Apps\ApiGrupoMacsa"
nssm set MacsaTicketsApi AppStdout "C:\Apps\ApiGrupoMacsa\logs\api-out.log"
nssm set MacsaTicketsApi AppStderr "C:\Apps\ApiGrupoMacsa\logs\api-err.log"
nssm set MacsaTicketsApi Start SERVICE_AUTO_START
nssm start MacsaTicketsApi
```

Alternativa con PM2:

```powershell
npm install -g pm2 pm2-windows-startup
pm2 start dist/server.js --name macsa-tickets-api
pm2 save
pm2-startup install
```

### 3.3 Firewall

```powershell
New-NetFirewallRule -DisplayName "Macsa Tickets API" -Direction Inbound `
  -Protocol TCP -LocalPort 3000 -Action Allow
```

### 3.4 Evidencias

Las imagenes se guardan en `C:\Apps\ApiGrupoMacsa\uploads\tickets`.
Incluya esta carpeta en el respaldo y asegurese de que el usuario del servicio
tenga permisos de escritura.

---

## 4. Aplicacion web

### 4.1 Compilar apuntando al servidor

```powershell
cd C:\Apps\ProyectoGrupoMacsa
flutter pub get
flutter build web --release --dart-define=API_URL=http://192.168.1.50:3000
```

Resultado: `build\web`.

### 4.2 Publicar

Opcion A - IIS:

1. Instale IIS con el modulo `URL Rewrite`.
2. Cree un sitio apuntando a `C:\Apps\ProyectoGrupoMacsa\build\web`.
3. Agregue un `web.config` para que las rutas de `go_router` funcionen al
   recargar (fallback a `index.html`):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="SPA fallback" stopProcessing="true">
          <match url=".*" />
          <conditions logicalGrouping="MatchAll">
            <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
            <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
          </conditions>
          <action type="Rewrite" url="/index.html" />
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
```

Opcion B - Servidor estatico simple (sin IIS):

```powershell
npm install -g serve
serve -s build\web -l 8080
```

Luego publique `http://192.168.1.50:8080` en la intranet.

> Si la web se sirve desde un puerto distinto al de la API, agregue ese origen
> en `CORS_ORIGINS` del `.env` y reinicie la API.

---

## 5. APK para Android

### 5.1 Compilar

```powershell
cd C:\Apps\ProyectoGrupoMacsa
flutter build apk --release --dart-define=API_URL=http://192.168.1.50:3000
```

El APK queda en `build\app\outputs\flutter-apk\app-release.apk`.

### 5.2 Distribuir

Copielo a la carpeta publicada por la API:

```powershell
Copy-Item build\app\outputs\flutter-apk\app-release.apk `
  C:\Apps\ApiGrupoMacsa\apk\MacsaTickets-v1.0.0.apk -Force
```

Los usuarios pueden descargarlo desde
`http://192.168.1.50:3000/apk/MacsaTickets-v1.0.0.apk`.

Notas:

- El APK release se firma actualmente con la **clave de debug** de Flutter
  (`android/app/build.gradle.kts`). Funciona para instalar en planta, pero para
  una distribucion formal configure un keystore propio en
  `android/key.properties` y cambie `signingConfig` en `build.gradle.kts`.
- La app usa HTTP en la LAN, por eso el manifiesto habilita
  `usesCleartextTraffic`. Si migra a HTTPS, puede desactivarlo.
- En el emulador de Android use `http://10.0.2.2:3000`; en un telefono fisico
  use la IP real del servidor.

---

## 6. Checklist de puesta en marcha

- [ ] SQL Server escuchando en `1433` y base `DB_MACSA_TICKETS` creada.
- [ ] `npm run db:setup` y `npm run seed:users` ejecutados.
- [ ] `.env` con credenciales reales y `JWT_SECRET` de 32+ caracteres.
- [ ] `http://<servidor>:3000/api/health` responde `ok`.
- [ ] Swagger accesible en `/api/docs`.
- [ ] Servicio de Windows de la API en ejecucion automatica.
- [ ] Regla de firewall del puerto 3000 creada.
- [ ] Web compilada con `--dart-define=API_URL=http://<servidor>:3000`.
- [ ] APK compilado con la misma URL y copiado a `ApiGrupoMacsa\apk`.
- [ ] Contrasenas demo cambiadas.
- [ ] Respaldo programado de la base de datos y de `uploads\tickets`.

---

## 7. Respaldos

Base de datos:

```powershell
sqlcmd -S localhost -U sa -P "SU_PASSWORD_SEGURA" -Q `
  "BACKUP DATABASE DB_MACSA_TICKETS TO DISK='C:\Respaldos\DB_MACSA_TICKETS.bak' WITH INIT"
```

Evidencias:

```powershell
Compress-Archive -Path C:\Apps\ApiGrupoMacsa\uploads\tickets\* `
  -DestinationPath C:\Respaldos\uploads-$(Get-Date -Format yyyyMMdd).zip
```

Programe ambas tareas con el Programador de tareas de Windows.

---

## 8. Solucion de problemas

| Sintoma | Causa probable | Solucion |
| --- | --- | --- |
| `health` devuelve 503 | SQL Server no accesible | Revise servicio, puerto 1433, `DB_*` en `.env` |
| Login falla con 401 | Usuarios no sembrados o clave incorrecta | Ejecute `npm run seed:users` |
| La web carga pero no hay datos | `API_URL` incorrecta o CORS | Recompile con la IP correcta y ajuste `CORS_ORIGINS` |
| Las imagenes no cargan en Android | URL de adjunto con host inaccesible | Use la IP del servidor en `--dart-define`; la app reescribe `/uploads/` |
| Error `QUOTED_IDENTIFIER` en SQL | Scripts ejecutados sin `-I` | Ejecute `sqlcmd` con `-I` o use `npm run db:setup` |
| El ticket no cierra | Falta la encuesta | Solo `CERRADO` se alcanza respondiendo la encuesta |
| No llegan notificaciones | Socket bloqueado | Verifique firewall y que el token siga vigente |

### Logs

- API: salida del servicio (NSSM/PM2) o `logs\api-out.log`.
- Base de datos: SQL Server Management Studio > SQL Server Logs.
- Flutter web: consola del navegador (F12).
- Android: `adb logcat | Select-String flutter`.

---

## 9. Actualizacion de version

```powershell
# API
cd C:\Apps\ApiGrupoMacsa
git pull            # o copie los archivos nuevos
npm install
npm run build
nssm restart MacsaTicketsApi

# Web / APK
cd C:\Apps\ProyectoGrupoMacsa
git pull
flutter pub get
flutter build web --release --dart-define=API_URL=http://192.168.1.50:3000
flutter build apk --release --dart-define=API_URL=http://192.168.1.50:3000
```

Si hay cambios de esquema, aplique los scripts SQL correspondientes antes de
reiniciar la API.
