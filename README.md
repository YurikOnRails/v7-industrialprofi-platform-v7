# V7 Industrialprofi Platform V7

Платформа построена на современном монолитном стеке с использованием последних функций Rails 8 в сочетании с современным React frontend через Inertia.js и Vite.

## 📚 Документация

### Для начала работы
- 📗 **[guides/QUICK_REFERENCE.md](guides/QUICK_REFERENCE.md)** - Быстрая шпаргалка (начните здесь!)
- 📗 **[guides/DEVELOPMENT_WORKFLOW.md](guides/DEVELOPMENT_WORKFLOW.md)** - Полное руководство по разработке
- 📗 **[guides/TMUX_SETUP.md](guides/TMUX_SETUP.md)** - Настройка tmux окружения

### Техническая документация
- 📘 **[docs/README.md](docs/README.md)** - Оглавление технической документации
- 📘 **[docs/02_ARCHITECTURE.md](docs/02_ARCHITECTURE.md)** - Архитектура проекта
- 📘 **[docs/03_DATABASE.md](docs/03_DATABASE.md)** - Структура базы данных

### Структура документации
- 📄 **[DOCS_STRUCTURE.md](DOCS_STRUCTURE.md)** - Организация документации

---

## Tech Stack & Versions

### Core
- **Ruby:** `3.4.1`
- **Rails:** `8.0.1`
- **Node.js:** `22.12.0` (LTS)
- **Database:** PostgreSQL (через Docker)

### Frontend
- **Framework:** React 19 (via Inertia.js)
- **Build Tool:** Vite 7
- **Styling:** Tailwind CSS 3.4
- **Package Manager:** npm

### Rails 8 "Solid" Infrastructure
- **Queue:** Solid Queue (DB-backed)
- **Cache:** Solid Cache (DB-backed)
- **Cable:** Solid Cable (DB-backed)

---

## 🚀 Quick Start

### Prerequisites

Используем **[mise](https://mise.jdx.dev/)** для управления версиями языков.

### Setup

```bash
# 1. Clone repository
git clone <repository_url>
cd v7-industrialprofi-platform-v7

# 2. Install language versions
mise install

# 3. Install dependencies
gem install bundler
bundle install
npm install

# 4. Setup Git workflow (один раз)
./bin/git-setup

# 5. Start database
docker-compose up -d

# 6. Database setup
bin/rails db:prepare
```

### Running the Application

**Рекомендуемый способ (tmux):**
```bash
./bin/tmux-dev
```

**Альтернативный способ:**
```bash
bin/dev
```

**Ручной запуск:**
```bash
# Terminal 1 - Rails
bin/rails s

# Terminal 2 - Vite
bin/vite dev
```

Откройте `http://localhost:3000`

---

## 📁 Directory Structure

```
v7-industrialprofi-platform-v7/
├── app/
│   ├── frontend/          # React компоненты, стили
│   ├── models/            # Rails модели
│   ├── controllers/       # Rails контроллеры
│   └── views/             # Rails views (минимальные)
│
├── docs/                  # 📘 Техническая документация (для ИИ)
│   ├── README.md
│   ├── 02_ARCHITECTURE.md
│   └── ...
│
├── guides/                # 📗 Руководства (для разработчика)
│   ├── QUICK_REFERENCE.md
│   ├── DEVELOPMENT_WORKFLOW.md
│   └── TMUX_SETUP.md
│
├── bin/                   # Скрипты
│   ├── dev               # Запуск Rails + Vite
│   ├── tmux-dev          # Tmux окружение
│   ├── git-setup         # Настройка Git
│   ├── backup-db         # Backup базы
│   └── restore-db        # Restore базы
│
├── config/
│   ├── database.yml
│   └── vite.json
│
└── docker-compose.yml     # PostgreSQL
```

---

## 🛠️ Полезные команды

### Development

```bash
# Запуск приложения (tmux)
./bin/tmux-dev

# База данных
docker-compose up -d              # Запустить
docker-compose ps                 # Статус
docker-compose logs -f postgres   # Логи

# Backup/Restore
./bin/backup-db                   # Создать backup
./bin/restore-db backups/db/file.sql

# Rails
rails c                           # Console
rails db:migrate                  # Миграции
rails routes                      # Маршруты
rails test                        # Тесты
```

### Git Workflow

```bash
# Новая фича
git checkout -b feature/my-feature

# Частые коммиты
git add .
git commit -m "Add feature"

# Merge в main
git checkout main
git merge feature/my-feature --no-ff
git push origin main
```

Подробнее: [guides/QUICK_REFERENCE.md](guides/QUICK_REFERENCE.md)

---

## 🎯 Процесс разработки

1. **Начните с руководства:** [guides/DEVELOPMENT_WORKFLOW.md](guides/DEVELOPMENT_WORKFLOW.md)
2. **Настройте Git:** `./bin/git-setup`
3. **Изучите структуру:** [docs/02_ARCHITECTURE.md](docs/02_ARCHITECTURE.md)
4. **Коммитьте часто:** Каждые 30-60 минут
5. **Main всегда рабочий:** Работайте через feature ветки

---

## 📖 Contributing

См. [guides/DEVELOPMENT_WORKFLOW.md](guides/DEVELOPMENT_WORKFLOW.md) для полной информации о процессе разработки.

---

*Последнее обновление: февраль 2026*
