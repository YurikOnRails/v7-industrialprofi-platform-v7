# 🚀 PostgreSQL Migration Guide

> **Статус:** ✅ Выполнено! Проект мигрирован на PostgreSQL с Day 1  
> **Дата решения:** Февраль 2026  
> **Причина:** Enterprise-ready архитектура для российского рынка

---

## 📋 Чек-Лист Миграции (Уже Сделано)

### ✅ Обновлена Документация

- [x] `docs/02_ARCHITECTURE.md` — добавлено обоснование PostgreSQL
- [x] `docs/03_DATABASE.md` — добавлены поля для 1С (`external_1c_id`) + таблица `versions` (paper_trail)

### ✅ Обновлены Конфиги

- [x] `Gemfile` — `gem "pg"` вместо `"sqlite3"`, добавлен `"paper_trail"`
- [x] `config/database.yml` — PostgreSQL конфигурация
- [x] `docker-compose.yml` — локальное окружение с PostgreSQL 16

---

## 🔧 Команды для Начала Работы

### 1. Установка Зависимостей

```bash
# Установить gems
bundle install

# Установить npm packages
npm install
```

**Ожидаемый результат:**
```
Bundle complete! X Gemfile dependencies, Y gems now installed.
...
added XXX packages
```

---

### 2. Запуск PostgreSQL (Docker Compose)

```bash
# Запустить PostgreSQL контейнер
docker-compose up -d

# Проверить что PostgreSQL запустился
docker-compose ps

# Логи (если нужно отладить)
docker-compose logs postgres
```

**Ожидаемый вывод:**
```
NAME                        IMAGE                COMMAND                  SERVICE    STATUS
industrialprofi_postgres    postgres:16-alpine   "docker-entrypoint.s…"   postgres   Up 5 seconds
```

**Доступ к PostgreSQL:**
- Host: `localhost`
- Port: `5432`
- User: `postgres`
- Password: `postgres`
- Database: `industrialprofi_development`

---

### 3. Создание БД и Миграций

```bash
# Создать базы данных (уже созданы через init.sql, но на всякий случай)
bin/rails db:create

# Запустить миграции (когда будут созданы)
bin/rails db:migrate

# Залить seeds (типовые допуски СНГ + публичные roadmaps)
bin/rails db:seed
```

**Ожидаемый результат:**
```
Created database 'industrialprofi_development'
Created database 'industrialprofi_test'
```

---

### 4. Проверка Подключения

```bash
# Rails console
bin/rails console

# В консоли проверить подключение
>> ActiveRecord::Base.connection.execute("SELECT version()").first
=> {"version"=>"PostgreSQL 16.x ..."}

>> ActiveRecord::Base.connection.adapter_name
=> "PostgreSQL"
```

---

## 🎯 Первая Миграция (День 1 Плана Разработки)

### Создание Основных Таблиц

```bash
# Organization
bin/rails g model Organization name:string slug:string:uniq plan_type:string subscription_status:string

# User (с полем для 1С!)
bin/rails g model User organization:references email:string:uniq password_digest:string full_name:string role:string department:string external_1c_id:string synced_from_1c_at:datetime metadata:jsonb

# Session (Rails 8 auth)
bin/rails g model Session user:references ip_address:string user_agent:string

# Запустить миграции
bin/rails db:migrate
```

### Установка paper_trail (Audit Trail)

```bash
# Сгенерировать миграцию для versions таблицы
bin/rails generate paper_trail:install --with-changes

# Запустить миграцию
bin/rails db:migrate
```

**Ожидаемая таблица `versions`:**
```sql
CREATE TABLE versions (
  id bigserial PRIMARY KEY,
  item_type varchar NOT NULL,
  item_id bigint NOT NULL,
  event varchar NOT NULL,
  whodunnit varchar,
  object jsonb,
  object_changes jsonb,
  created_at timestamp
);
```

### Подключение paper_trail к Моделям

```ruby
# app/models/user_progress.rb
class UserProgress < ApplicationRecord
  has_paper_trail on: [:create, :update, :destroy],
                  ignore: [:updated_at],
                  meta: { organization_id: :organization_id }
end

# app/models/user.rb
class User < ApplicationRecord
  has_paper_trail only: [:email, :role, :department, :full_name]
end
```

---

## 🧪 Тестирование

### Проверка PostgreSQL JSONB

```ruby
# В rails console
user = User.create!(
  email: "test@test.com",
  full_name: "Иван Иванов",
  metadata: { personnel_number: "00001234" }
)

# JSONB запросы работают!
User.where("metadata->>'personnel_number' = ?", "00001234").first
# => #<User id: 1, ...>
```

### Проверка paper_trail

```ruby
user = User.first
user.update(full_name: "Петр Петров")

user.versions.last
# => #<PaperTrail::Version item_type: "User", event: "update", ...>

user.versions.last.changeset
# => {"full_name"=>["Иван Иванов", "Петр Петров"]}
```

---

## 🐳 Docker Commands (Шпаргалка)

```bash
# Запуск PostgreSQL
docker-compose up -d

# Остановка
docker-compose down

# Остановка + удаление данных (ОСТОРОЖНО!)
docker-compose down -v

# Логи
docker-compose logs -f postgres

# Вход в psql
docker-compose exec postgres psql -U postgres -d industrialprofi_development

# Запуск pgAdmin (GUI) - опционально
docker-compose --profile tools up -d
# Открыть http://localhost:5050
# Email: admin@industrialprofi.local
# Password: admin
```

---

## 🔄 Миграция Данных (Если Были на SQLite)

> **Примечание:** Для нас не актуально, так как проект мигрирован до написания кода.  
> Но на будущее, если понадобится:

```bash
# Вариант 1: pgloader (быстро)
brew install pgloader
pgloader storage/development.sqlite3 postgresql://postgres:postgres@localhost/industrialprofi_development

# Вариант 2: Custom rake task
bin/rails db:migrate:sqlite_to_postgres
```

---

## 📊 Production Deployment (Kamal 2 + PostgreSQL)

### Environment Variables

```bash
# .env.production
DATABASE_NAME=industrialprofi_production
DATABASE_HOST=<your-postgres-host>
DATABASE_PORT=5432
DATABASE_USER=industrialprofi_user
DATABASE_PASSWORD=<secure-password>

CACHE_DATABASE_NAME=industrialprofi_cache
QUEUE_DATABASE_NAME=industrialprofi_queue
CABLE_DATABASE_NAME=industrialprofi_cable
```

### Kamal Deploy

```bash
# Setup (первый раз)
kamal setup

# Deploy
kamal deploy

# Run migrations on production
kamal app exec 'bin/rails db:migrate'

# Seed production (типовые допуски)
kamal app exec 'bin/rails db:seed'
```

---

## 🎉 Результат Миграции

### Что Получили:

✅ **PostgreSQL 16** — enterprise-ready СУБД  
✅ **paper_trail** — audit trail для compliance  
✅ **JSONB поля** — гибкость для 1С интеграции  
✅ **Docker Compose** — простое локальное окружение  
✅ **Архитектура под масштабирование** — готовность к on-premise  

### Стоимость Миграции:

- **Время:** +1 день разработки (vs +2-3 недели если бы делали потом)
- **Complexity:** Минимальная (ActiveRecord абстракция)
- **Риски:** Нулевые (сделано до написания кода)

### Будущие Возможности (Разблокировано):

- ✅ 1С:ЗУП интеграция через ODBC
- ✅ On-premise deployment (800K₽ единоразово)
- ✅ pgaudit для гос. контрактов
- ✅ Репликация master-slave
- ✅ Full-text search по русским текстам

---

## 💡 Troubleshooting

### Проблема: `PG::ConnectionBad: could not connect to server`

**Решение:**
```bash
# Проверить что PostgreSQL запущен
docker-compose ps

# Перезапустить
docker-compose restart postgres

# Проверить логи
docker-compose logs postgres
```

### Проблема: `ActiveRecord::NoDatabaseError`

**Решение:**
```bash
# Создать базы
bin/rails db:create

# Если не помогло - пересоздать
bin/rails db:drop db:create
```

### Проблема: `Gem::LoadError: pg gem not installed`

**Решение:**
```bash
# Переустановить gems
bundle install

# Если MacOS - может потребоваться:
brew install postgresql@16
bundle install
```

---

## 📚 Дополнительные Ресурсы

- [PostgreSQL Documentation](https://www.postgresql.org/docs/16/)
- [paper_trail Gem](https://github.com/paper-trail-gem/paper_trail)
- [Rails Multi-Database Guide](https://guides.rubyonrails.org/active_record_multiple_databases.html)
- [Kamal Deployment](https://kamal-deploy.org/)

---

**Автор:** IndustrialPROFI Team  
**Дата:** Февраль 2026  
**Версия:** 1.0
