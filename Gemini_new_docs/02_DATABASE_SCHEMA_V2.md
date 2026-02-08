# 🗄️ 02. Database Schema v2 (Solid & React Flow Optimized)

## Обзор изменений
1.  **Solid Stack:** Добавлены стандартные таблицы для `solid_queue`, `solid_cache`, `solid_cable` (управляются гемами, но присутствуют в схеме).
2.  **React Flow Optimization:**
    *   В `skills` добавлены поля `position_x` и `position_y` для хранения координат узлов (даже если они рассчитываются библиотекой, полезно иметь возможность сохранить "идеальную" расстановку).
    *   Добавлены поля для группировки узлов (`group_id` / `parent_id`).
3.  **Упрощение:** Убрана сущность `Topics` в пользу плоской структуры или групп внутри React Flow.

## DBML Схема

```dbml
// --- SOLID INFRASTRUCTURE (Managed by Rails Engines) ---
// Примечание: Эти таблицы создаются миграциями solid_queue, solid_cache, solid_cable.
// Здесь они указаны для полноты картины.

Table solid_queue_jobs {
  id integer [pk, increment]
  queue_name varchar
  class_name varchar
  arguments text
  priority integer
  active_job_id varchar
  scheduled_at datetime
  finished_at datetime
  concurrency_key varchar
}

Table solid_cache_entries {
  id integer [pk, increment]
  key binary [unique]
  value binary
  created_at datetime
}

// --- CORE CONTENT (Roadmaps & Skills) ---

Table roadmaps {
  id integer [pk, increment]
  title varchar [not null]
  slug varchar [unique, not null] // URL: /roadmaps/welder
  description text
  
  // UI Settings
  theme_color varchar [default: '#blue'] 
  is_published boolean [default: false]
  
  created_at datetime [not null]
  updated_at datetime [not null]
}

Table skill_categories {
  id integer [pk, increment]
  roadmap_id integer [ref: > roadmaps.id]
  title varchar [not null] // "Safety Basics", "Advanced Welding"
  color varchar // Цвет группы узлов в React Flow
  position integer [default: 0] // Порядок сортировки
  created_at datetime [not null]
  updated_at datetime [not null]
}

Table skills {
  id integer [pk, increment]
  roadmap_id integer [ref: > roadmaps.id]
  skill_category_id integer [ref: > skill_categories.id, null] // Опциональная привязка к категории
  
  // React Flow Node Data
  key varchar [unique, not null] // Уникальный ID узла в графе (string)
  title varchar [not null]
  description text
  
  // Coordinates (Optional, if using auto-layout these might be transient)
  position_x float [default: 0]
  position_y float [default: 0]
  
  // Node Type Logic
  skill_type varchar [default: 'skill'] // 'skill', 'permit', 'milestone'
  
  // Permit Logic (if skill_type == 'permit')
  expiration_months integer [note: "Срок действия допуска в месяцах"]
  is_mandatory boolean [default: true]

  created_at datetime [not null]
  updated_at datetime [not null]

  indexes {
    (roadmap_id, key) [unique]
  }
}

// Ребра графа (Edges)
Table skill_dependencies {
  id integer [pk, increment]
  from_skill_id integer [ref: > skills.id]
  to_skill_id integer [ref: > skills.id]
  kind varchar [default: "required"] // 'required', 'optional'
  
  created_at datetime [not null]
  updated_at datetime [not null]

  indexes {
    (from_skill_id, to_skill_id) [unique]
  }
}

Table skill_resources {
  id integer [pk, increment]
  skill_id integer [ref: > skills.id]
  title varchar [not null]
  url varchar [not null]
  kind varchar [not null] // 'video', 'article', 'official_doc'
  created_at datetime [not null]
  updated_at datetime [not null]
}

// --- USERS & ORGANIZATIONS ---

Table users {
  id integer [pk, increment]
  email varchar [unique, not null]
  password_digest varchar [not null]
  
  full_name varchar
  role varchar [default: 'employee'] // 'employee', 'manager', 'admin'
  department varchar
  job_title varchar
  
  created_at datetime [not null]
  updated_at datetime [not null]
}

// --- PROGRESS TRACKING ---

Table user_progresses {
  id integer [pk, increment]
  user_id integer [ref: > users.id]
  skill_id integer [ref: > skills.id]
  
  // Status Flow
  status varchar [default: 'todo'] // 'todo', 'in_progress', 'review_pending', 'completed', 'expired'
  
  // Verification
  verified_at datetime
  verifier_id integer [ref: > users.id]
  
  // Permit Specifics
  certificate_number varchar
  issued_at date
  expires_at date
  
  notes text // Комментарии при проверке

  created_at datetime [not null]
  updated_at datetime [not null]

  indexes {
    (user_id, skill_id) [unique]
    status
    expires_at
  }
}
```

## Индексы и Оптимизация

### 1. JSON Generation Optimization
Для быстрой отдачи графа (основная фича) необходимы составные индексы.
*   `add_index :skills, [:roadmap_id]` — Быстрая выборка всех узлов карты.
*   `add_index :skill_dependencies, [:from_skill_id, :to_skill_id]` — Контроль уникальности связей.

### 2. Status Tracking
Для дашборда "Истекающие допуски" критичен индекс по дате истечения.
*   `add_index :user_progresses, [:status, :expires_at]` — Позволяет мгновенно находить просроченные сертификаты.

### 3. Solid Cache Strategy
Мы будем кэшировать **структуру** графа (nodes/edges без пользовательских данных) в `Solid Cache`, так как она меняется редко.
Ключ кэша: `roadmap_structure/v1/{roadmap_id}/{updated_at}`.
Данные пользователя накладываются поверх кэшированной структуры в Runtime.
