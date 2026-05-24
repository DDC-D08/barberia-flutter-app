# Barberia Flutter App (esqueleto)

Requisitos:
- Flutter >= 3.7
- Android emulator (usar `10.0.2.2` como `baseUrl` para el backend en `AuthProvider`)

Instalación y ejecución:

```bash
cd c:\proyectos\barberia_flutter_app
flutter pub get
flutter run
```

Notas:
- El `ApiClient` añade automáticamente `Authorization: Bearer <token>` salvo en `/api/auth/login`.
- Token se guarda en `flutter_secure_storage`.
- `HomeScreen` cachea servicios en `SharedPreferences` bajo la clave `cache_servicios`.

Repositorio GitHub (crear y subir)
--------------------------------

1. Crear un repo nuevo en GitHub (por ejemplo `barberia-flutter-app`) o usar la CLI `gh`:

```bash
cd c:\proyectos\barberia_flutter_app
git init
git add .
git commit -m "Initial commit - Flutter app"
# crear repo en GitHub (requiere gh CLI autenticada)
gh repo create DDC-D08/barberia-flutter-app --public --source=. --remote=origin --push
```

Si no usas `gh`, crea el repo en la web y luego añade el remoto:

```bash
git remote add origin https://github.com/OWNER/REPO.git
git branch -M main
git push -u origin main
```

Configurar URL del backend
---------------------------

El `ApiClient` admite definir la `API_BASE_URL` en tiempo de compilación/ejecución. Ejemplos:

- Ejecutar en emulador Android apuntando al host local (`10.0.2.2`):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
```

- Ejecutar en dispositivo real apuntando a la máquina dev (usando ngrok o tunel) o la IP de la máquina:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.100:8080/api
```

GitHub Actions (opcional)
-------------------------

Se incluye un workflow que compila la app y ejecuta `flutter analyze` y `flutter test` en cada push/PR a `main`.


Pruebas rápidas:
- Asegúrate de tener el backend corriendo en `http://localhost:8080`.
- En emulador Android el host del host machine es `10.0.2.2`, por eso el `baseUrl` está configurado así.

Siguientes pasos recomendados:
- Añadir `BookingScreen` y `CitasScreen`.
- Añadir validaciones de formularios y manejo 409 en POST `/api/citas`.
- Añadir tests unitarios para `AuthProvider` y `ApiClient`.
