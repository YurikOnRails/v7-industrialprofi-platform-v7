# 🏗️ 03. Frontend Architecture (React 19 + Inertia + Vite)

## 1. Структура проекта (`app/frontend`)

Мы отказываемся от старого Asset Pipeline в пользу **Vite**. Весь JS/TS код живет в `app/frontend`.

```
app/frontend/
├── entrypoints/          # Точки входа Vite
│   ├── application.css   # Tailwind + Global Styles
│   ├── application.ts    # Main JS entry
│   └── inertia.tsx       # Inertia App Setup
├── components/           # Reusable UI Components
│   ├── ui/               # Базовые (Button, Card, Modal) - shadcn/ui style
│   ├── layout/           # AppShell, Navbar, Sidebar
│   └── roadmap/          # React Flow Components (Nodes, Edges)
├── pages/                # Inertia Page Components (1-to-1 with Controllers)
│   ├── Dashboard/        # User Dashboard
│   ├── Roadmaps/         # Roadmap Viewer (Graph)
│   └── Profile/          # User Settings
├── hooks/                # Custom React Hooks (useRoadmapStore, etc.)
├── types/                # TypeScript Interfaces (Shared with Backend)
└── utils/                # Helper functions (date formatting, graph layout)
```

## 2. Роутинг и Inertia

Inertia.js использует серверный роутинг Rails.
*   **Rails:** `config/routes.rb` определяет URL.
*   **React:** `Inertia.render('PageName', props)` рендерит компонент из `app/frontend/pages/PageName.tsx`.

### Пример маппинга:

| Rails Route | Controller Action | React Page Component |
| :--- | :--- | :--- |
| `GET /` | `DashboardController#index` | `Pages/Dashboard/Index.tsx` |
| `GET /roadmaps/:id` | `RoadmapsController#show` | `Pages/Roadmaps/Show.tsx` |
| `POST /progress/:id` | `UserProgressController#update` | *(No page, redirect back)* |

---

## 3. Реализация React Flow (Roadmap Viewer)

Мы заменяем Cytoscape на **React Flow** для лучшей производительности и DX в React-среде.

### Архитектура компонента `RoadmapGraph`

1.  **Nodes & Edges:** Данные приходят с бэкенда в *плоском* формате (JSON), мы трансформируем их в формат React Flow (`{ id, position, data }`) на клиенте или (предпочтительно) уже готовыми с сервера.
2.  **Layouting (Авто-раскладка):** Используем `dagre` или `elkjs` для автоматического вычисления позиций `x` и `y`. Хранить координаты в БД для MVP не обязательно, вычисляем при загрузке.

```typescript
// utils/graphLayout.ts
import dagre from 'dagre';
import { Node, Edge } from 'reactflow';

export const getLayoutedElements = (nodes: Node[], edges: Edge[]) => {
  const dagreGraph = new dagre.graphlib.Graph();
  dagreGraph.setDefaultEdgeLabel(() => ({}));
  
  // ... настройки dagre (dir: 'TB' или 'LR') ...
  
  // Возвращаем узлы с вычисленными x, y
  return { nodes: layoutedNodes, edges };
};
```

### Интерактивный "Sidebar" (Детали навыка)

Вместо Turbo Frames мы используем **URL State**.
*   **Клик по узлу:** `router.get('/roadmaps/1?skill_id=101', {}, { preserveState: true, replace: true })`
*   **URL:** Меняется на `/roadmaps/frontend?skill_id=css-basics`
*   **React:** Компонент страницы читает `usePage().props.params.skill_id` и рендерит `<SkillDetailsSidebar />` (Slide-over).

**Почему URL?**
1.  Можно скинуть ссылку коллеге прямо на навык.
2.  Работает кнопка "Назад" в браузере.
3.  Inertia `preserveState: true` не перезагружает граф, меняется только проп `activeSkill`.

---

## 4. Типизация (TypeScript)

Мы дублируем типы моделей Rails в TypeScript интерфейсы для строгой типизации пропсов.

```typescript
// types/models.ts

export interface Skill {
  id: number;
  title: string;
  description: string;
  is_permit: boolean;
  status: 'todo' | 'in_progress' | 'completed' | 'expired'; // Computed status for current user
}

export interface Roadmap {
  id: number;
  title: string;
  nodes: Skill[];
  edges: Array<{ from: number; to: number }>;
}

export interface PageProps<T = {}> {
  auth: { user: User };
  flash: { success?: string; error?: string };
  // ...
}
```

## 5. UI Kit & Styling

*   **Tailwind CSS:** Основной инструмент стилизации.
*   **Components:** Используем Headless UI или Radix UI (через shadcn/ui) для доступных модалок, диалогов и дропдаунов.
*   **Icons:** `lucide-react` (стандарт индустрии сейчас).
