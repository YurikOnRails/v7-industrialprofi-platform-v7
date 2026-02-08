# 📡 04. Data Flow & Controllers (Ruby -> Inertia Props)

## 1. Архитектура контроллеров

Мы не используем REST API (`render json: ...`).
Мы используем **Inertia Responses** (`render inertia: ...`).

### `RoadmapsController`

Основная точка входа для просмотра карты.
Отдаёт **всю структуру графа** и прогресс пользователя **одним запросом** (Eager Loading).

```ruby
class RoadmapsController < ApplicationController
  def show
    roadmap = Roadmap.includes(skills: [:skill_dependencies, :skill_resources]).find_by!(slug: params[:id])
    
    # Оптимизация: N+1 запрос прогресса пользователя
    user_progress = current_user.user_progresses.where(skill_id: roadmap.skill_ids).index_by(&:skill_id)
    
    render inertia: 'Roadmaps/Show', props: {
      roadmap: RoadmapSerializer.render_as_hash(roadmap),
      userProgress: user_progress.transform_values { |p| UserProgressSerializer.render_as_hash(p) },
      # Для сайдбара (если передан параметр ?skill_id=...)
      activeSkillId: params[:skill_id]
    }
  end
end
```

---

## 2. Payload Structure (Props)

Inertia передаёт данные как JSON-объект в корневой компонент React.
Нам нужно заранее трансформировать модели Rails в структуру, удобную для React Flow (`nodes` и `edges`).

### Пример JSON ответа (`roadmap` prop):

```json
{
  "id": 1,
  "title": "Industrial Welder",
  "slug": "welder",
  "nodes": [
    {
      "id": "101", // Skill ID (String for React Flow)
      "type": "skillNode", // Custom node type in React Flow
      "position": { "x": 0, "y": 0 }, // Placeholder, layout happens on client
      "data": {
        "label": "Safety Basics",
        "category": "safety",
        "isPermit": true,
        "status": "completed" // Computed on backend or merged on frontend
      }
    },
    {
      "id": "102",
      "type": "skillNode",
      "data": { "label": "MIG Welding", "status": "todo" }
    }
  ],
  "edges": [
    {
      "id": "e101-102",
      "source": "101",
      "target": "102",
      "type": "smoothstep"
    }
  ]
}
```

**Важно:** Статус прохождения (`status`) лучше мержить на фронтенде или передавать отдельным словарем `userProgress`, чтобы кэшировать структуру графа (`nodes/edges`) для всех пользователей одинаково.

---

## 3. Flash Messages & Errors

Inertia автоматически прокидывает `flash` сообщения.
Мы настраиваем `HandleInertiaRequests` middleware.

```ruby
# app/controllers/concerns/inertia_flash.rb
def share_flash
  {
    flash: {
      success: flash.notice,
      error: flash.alert
    }
  }
end
```

**React Component (`Layout.tsx`):**
```tsx
const { flash } = usePage().props;

useEffect(() => {
  if (flash.success) toast.success(flash.success);
  if (flash.error) toast.error(flash.error);
}, [flash]);
```

---

## 4. UserProgressController (Mutations)

Когда пользователь отмечает навык "Изучил":

```ruby
class UserProgressController < ApplicationController
  def update
    skill = Skill.find(params[:id])
    progress = current_user.user_progresses.find_or_initialize_by(skill: skill)
    
    if progress.update(status: 'in_progress')
      redirect_back fallback_location: root_path, notice: "Навык отмечен!"
    else
      redirect_back fallback_location: root_path, alert: "Ошибка сохранения"
    end
  end
end
```

**Optimistic UI на клиенте:**
Inertia позволяет делать запросы без полной перезагрузки страницы, но с обновлением пропсов (`only: ['userProgress']`).
Мы можем мгновенно обновить UI (поставить галочку) до ответа сервера, используя локальный React State или `router.visit` с опцией `preserveState`.

