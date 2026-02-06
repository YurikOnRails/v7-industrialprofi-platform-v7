# V7 Industrialprofi Platform V7

This application is built using the "Modern Monolith" stack, leveraging the latest features of Rails 8 combined with a modern React frontend via Inertia.js and Vite.

## Tech Stack & Versions

We strictly adhere to specific versions to ensure stability and compatibility.

### Core
*   **Ruby:** `3.4.1`
*   **Rails:** `8.0.1`
*   **Node.js:** `22.12.0` (LTS)
*   **Database:** SQLite3 (configured with WAL mode & `synchronous: normal` for production performance)

### Frontend
*   **Framework:** React 19 (via Inertia.js Rails Adapter)
*   **Build Tool:** Vite 7 (via `vite_rails`)
*   **Styling:** Tailwind CSS 3.4
*   **Package Manager:** npm

### Rails 8 "Solid" Infrastructure
*   **Queue:** Solid Queue (DB-backed)
*   **Cache:** Solid Cache (DB-backed)
*   **Cable:** Solid Cable (DB-backed)

## Prerequisites

We use **[mise](https://mise.jdx.dev/)** to manage language versions. Please ensure it is installed on your system.

## Setup

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd v7-industrialprofi-platform-v7
    ```

2.  **Install Language Versions (Ruby & Node):**
    ```bash
    mise install
    ```

3.  **Install Dependencies:**
    ```bash
    gem install bundler
    bundle install
    npm install
    ```

4.  **Database Setup:**
    ```bash
    bin/rails db:prepare
    ```

## Running the Application

To start the Rails server and the Vite dev server concurrently:

```bash
bin/dev
```

Visit `http://localhost:3000`.

## Debugging: Split Logs with Tmux

For a better development experience, it is recommended to run the Backend (Rails) and Frontend (Vite) in separate consoles. This keeps the logs clean and readable.

**Manual Setup:**
1.  Open **Terminal 1** (Backend):
    ```bash
    bin/rails s
    ```
2.  Open **Terminal 2** (Frontend):
    ```bash
    bin/vite dev
    ```

**Tmux One-Liner:**
If you use `tmux`, you can launch both in a split view with a single command:

```bash
tmux new-session -s dev "bin/rails s" \; split-window -h "bin/vite dev" \; attach
```

## Directory Structure

*   `app/frontend`: All frontend assets (React components, styles, entrypoints).
*   `app/javascript`: (Legacy/Unused) Standard Rails JS folder.
*   `config/database.yml`: SQLite optimized configuration.
*   `vite.config.ts`: Vite configuration.
