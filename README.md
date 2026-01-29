# TUTU - Мультимодальная система бронирования билетов

Комплексное Ruby on Rails приложение для бронирования билетов на различные виды транспорта: поезда, самолёты и автобусы. Аналог [tutu.ru](https://tutu.ru).

## Возможности

### Для пользователей
- **Мультимодальный поиск** - Поиск поездов, самолётов и автобусов в едином интерфейсе
- **Интерактивный выбор мест** - Визуальные карты мест для каждого типа транспорта
- **Корзина** - Добавление нескольких билетов перед оплатой
- **Управление заказами** - Отслеживание заказов и статуса оплаты
- **Профиль пользователя** - Личные данные, паспорт, история поездок
- **Избранные маршруты** - Сохранение часто используемых маршрутов
- **Напоминания о поездках** - Email-уведомления за 24 часа до отправления

### Для администратора
- **Панель управления** - Обзор пользователей, заказов, транспорта, статистики
- **Управление транспортом** - CRUD для поездов, самолётов, автобусов
- **Управление станциями** - Ж/Д станции, аэропорты, автовокзалы
- **Управление вагонами/салонами** - Настройка мест и цен
- **Управление заказами** - Просмотр и управление всеми заказами
- **Статистика** - Отчёты о выручке, популярные маршруты, тренды бронирования

### API (v1)
- RESTful JSON API с токен-аутентификацией
- Эндпоинты для поиска, транспорта, мест, корзины, заказов, профиля
- CORS для интеграции с фронтендом

## Технологии

- **Ruby** 3.2.2
- **Rails** 7.0+
- **PostgreSQL** - База данных
- **Bootstrap 5** - UI-фреймворк
- **Devise** - Аутентификация
- **Sidekiq** - Фоновые задачи
- **Pundit** - Авторизация
- **Pagy** - Пагинация

## Установка

### Требования
- Ruby 3.2.2
- PostgreSQL
- Node.js
- Redis (для Sidekiq)

### Настройка

```bash
# Клонирование репозитория
git clone https://github.com/yourusername/tutu.git
cd tutu

# Установка зависимостей
bundle install

# Настройка базы данных
rails db:create
rails db:migrate
rails db:seed

# Запуск сервера
rails server
```

### Запуск фоновых задач

```bash
# Запуск Redis
redis-server

# Запуск Sidekiq
bundle exec sidekiq
```

## Тестовые учётные данные

После выполнения `rails db:seed` доступны следующие аккаунты:

| Роль   | Email              | Пароль       |
|--------|-------------------|--------------|
| Админ  | admin@tutu.ru     | password123  |
| Юзер   | user@example.com  | password123  |

## Структура проекта

```
app/
├── controllers/
│   ├── admin/           # Админ-контроллеры
│   ├── api/v1/          # API-контроллеры
│   ├── carts_controller.rb
│   ├── orders_controller.rb
│   ├── profiles_controller.rb
│   ├── searches_controller.rb
│   └── seats_controller.rb
├── models/
│   ├── station.rb       # Базовый (STI: RailwayStation, Airport, BusStation)
│   ├── vehicle.rb       # Базовый (STI: Train, Plane, Bus)
│   ├── compartment.rb   # Базовый (STI: TrainCompartment, AirplaneCabin, BusSection)
│   ├── seat.rb
│   ├── cart.rb
│   ├── order.rb
│   └── ...
├── services/
│   ├── transport_search.rb
│   ├── seat_reservation.rb
│   ├── payment_processor.rb
│   └── price_calculator.rb
├── jobs/
│   ├── trip_reminder_job.rb
│   ├── cart_cleanup_job.rb
│   └── process_payment_job.rb
└── views/
    ├── searches/        # Интерфейс поиска
    ├── seats/           # Карты мест
    ├── carts/           # Корзина
    ├── orders/          # Управление заказами
    ├── profiles/        # Профиль пользователя
    └── admin/           # Админ-панель
```

## Документация API

### Аутентификация

```bash
# Вход
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

# Ответ
{
  "success": true,
  "token": "your-api-token",
  "expires_at": "2025-03-01T00:00:00Z"
}
```

### Поиск

```bash
# Поиск транспорта
POST /api/v1/searches
Authorization: Bearer your-api-token
Content-Type: application/json

{
  "start_station_id": 1,
  "end_station_id": 2,
  "transport_type": "all",
  "date": "2025-02-15"
}
```

### Операции с корзиной

```bash
# Просмотр корзины
GET /api/v1/cart
Authorization: Bearer your-api-token

# Добавление в корзину
POST /api/v1/cart/add_item
Authorization: Bearer your-api-token

{
  "seat_id": 123,
  "passenger_name": "Иван Иванов",
  "passenger_passport": "1234567890"
}

# Оформление заказа
POST /api/v1/cart/checkout
Authorization: Bearer your-api-token
```

## Схема базы данных

### Основные таблицы
- `stations` - Все типы станций (STI)
- `vehicles` - Все типы транспорта (STI)
- `compartments` - Вагоны, салоны, секции (STI)
- `seats` - Места с ценами
- `tickets` - Забронированные билеты
- `carts` / `cart_items` - Корзина
- `orders` / `order_items` - Заказы
- `users` - Пользователи
- `api_tokens` - Токены API

## Функциональность

### Страница поиска
Мультимодальный поиск с выбором типа транспорта, станций и даты.

### Выбор мест
Интерактивные карты мест с отображением доступности и цен в реальном времени.

### Админ-панель
Обзор ключевых метрик с быстрым доступом к функциям управления.

## Лицензия

Проект с открытым исходным кодом, доступен под лицензией [MIT](LICENSE).
