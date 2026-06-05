# Donatello's Pizza App

Proyecto full-stack para una app de pedidos de pizza con estilo visual inspirado en Donatello/TMNT. Incluye una app mobile en Flutter y un backend Laravel con autenticacion por API usando Sanctum.

## Que hace

- Permite registrar usuarios clientes.
- Permite iniciar sesion desde la app mobile.
- Guarda sesion localmente en el dispositivo.
- Muestra pantallas de inicio, login, registro, productos, detalle, carrito y recuperacion de contrasena.
- Expone API REST desde Laravel.
- Levanta backend, Nginx, MySQL y phpMyAdmin con Docker.

## Tecnologias

- Flutter / Dart para la app mobile.
- Laravel / PHP para el backend.
- MySQL 8 para base de datos.
- Laravel Sanctum para tokens de autenticacion.
- Docker Compose para entorno local.
- Nginx como servidor web del backend.

## Estructura

```text
.
├── backend/
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── nginx/default.conf
│   └── src/              # Laravel API
└── mobile/               # Flutter app
```

## Requisitos

- Git
- Docker y Docker Compose
- Flutter SDK
- Android Studio o emulador/dispositivo fisico para correr la app

## Bajar proyecto

```bash
git clone https://github.com/alejoo548/DonatellospizzaApp.git
cd DonatellospizzaApp
```

## Levantar backend con Docker

Entra a carpeta backend:

```bash
cd backend
```

Levanta contenedores:

```bash
docker compose up -d --build
```

Instala dependencias Laravel dentro del contenedor:

```bash
docker compose exec app composer install
```

Crea archivo `.env`:

```bash
cp src/.env.example src/.env
```

Edita `backend/src/.env` y usa estos valores para Docker:

```env
APP_NAME="Donatellos Pizza"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8010

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=donatellos_db
DB_USERNAME=donatellos_user
DB_PASSWORD=donatellos_pass

SESSION_DRIVER=database
QUEUE_CONNECTION=database
CACHE_STORE=database
```

Genera key y corre migraciones:

```bash
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate
```

Backend queda en:

```text
http://localhost:8010
```

phpMyAdmin queda en:

```text
http://localhost:8081
```

Credenciales MySQL:

```text
Servidor: mysql
Base de datos: donatellos_db
Usuario: donatellos_user
Password: donatellos_pass
Root password: root
```

## Probar API

Registro:

```bash
curl -X POST http://localhost:8010/api/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Alejandro",
    "lastname": "Hernandez",
    "email": "alejandro@test.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

Login:

```bash
curl -X POST http://localhost:8010/api/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "alejandro@test.com",
    "password": "password123"
  }'
```

## Correr app mobile

Abre otra terminal desde raiz del proyecto:

```bash
cd mobile
flutter pub get
flutter run
```

Antes de correr, revisa URL de API en:

```text
mobile/lib/services/api_service.dart
```

Valor actual:

```dart
static const String _baseUrl = 'http://192.168.3.85:8010/api';
```

Usa valor correcto segun donde corras:

```text
Android emulator: http://10.0.2.2:8010/api
Telefono fisico:  http://TU_IP_LOCAL:8010/api
Linux/Desktop:    http://localhost:8010/api
```

Para ver IP local de computadora:

```bash
ip addr
```

Busca IP de Wi-Fi o red local, por ejemplo `192.168.1.25`, y pon:

```dart
static const String _baseUrl = 'http://192.168.1.25:8010/api';
```

## Flujo de uso

1. Levanta backend con Docker.
2. Corre migraciones.
3. Abre app Flutter.
4. Crea cuenta en pantalla de registro.
5. Inicia sesion.
6. Navega productos, detalle y carrito.

## Comandos utiles

Ver contenedores:

```bash
docker compose ps
```

Ver logs:

```bash
docker compose logs -f
```

Entrar al contenedor Laravel:

```bash
docker compose exec app bash
```

Apagar backend:

```bash
docker compose down
```

Apagar y borrar volumen MySQL:

```bash
docker compose down -v
```

## Notas

- No subas `.env` a GitHub.
- Si cambia IP de computadora, actualiza `_baseUrl` en Flutter.
- Si Android emulador no conecta con `localhost`, usa `10.0.2.2`.
- Si telefono fisico no conecta, confirma que telefono y computadora esten en misma red Wi-Fi.
