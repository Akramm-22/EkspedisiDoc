# 🚚 EkspedisiDoc

EkspedisiDoc is a web-based logistics and expedition management system built with Laravel 11. The application helps manage shipment operations, customer services, payments, tracking, and administration through a modern and efficient workflow.

## ✨ Features

- Customer Authentication
- Shipment Management
- Shipment Tracking
- Payment Integration (Midtrans)
- Branch Management
- Vehicle Management
- Rate Management
- Role-Based Access Control
- Admin Dashboard
- Customer Dashboard

## 🛠️ Tech Stack

- Laravel 11
- PHP 8.3+
- MySQL
- Blade
- Alpine.js
- Inertia.js
- Vue 3
- Tailwind CSS
- Sanctum
- Midtrans Snap API

## 🚀 Installation

```bash
composer install
cp .env.example .env
php artisan key:generate

php artisan migrate --seed

npm install
npm run dev

php artisan serve
```

## ⚙️ Environment

Configure the required environment variables in the `.env` file before running the application.

Example:

```env
APP_NAME=EkspedisiDoc
DB_DATABASE=your_database
DB_USERNAME=your_username
DB_PASSWORD=your_password

MIDTRANS_SERVER_KEY=your_server_key
MIDTRANS_CLIENT_KEY=your_client_key
```

> Never commit your real API keys or credentials to GitHub.

## 📄 License

This project is intended for educational and development purposes.