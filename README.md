r4# Rails 8 Starter Kit

> A production-grade, AI-native fullstack starter kit for Rails 8.
> Zero-config Docker. Parallel tests. Real-time WebSockets. Premium dark UI.
> From `git clone` to running app in one command.

```
docker compose up
```

That's it. The `setup` container creates your database, seeds sample data, and the `tests` container validates everything with parallel linting and specs — all before your app boots.

---

## What's Inside

| Layer | Technology | Why |
|---|---|---|
| **Framework** | Rails 8.1 (edge) + Ruby 4.0 | Latest Rails with all modern defaults |
| **Frontend** | Hotwire (Turbo + Stimulus) + Tailwind CSS v4 + DaisyUI | SPA-like UX without a JS build step |
| **Real-time** | AnyCable + AnyCable-Go + Turbo Streams | WebSocket broadcasting at scale |
| **Database** | PostgreSQL 17.5 + PgBouncer | Connection pooling out of the box |
| **Background Jobs** | Sidekiq + Sidekiq-Cron | Reliable async processing with recurring jobs |
| **Object Storage** | Active Storage + LocalStack (S3) | Production-parity file uploads locally |
| **3D Graphics** | Three.js (via importmap) | Ready for WebGL/3D without bundlers |
| **Testing** | RSpec + Capybara + Parallel Tests | Full-stack E2E with headless Chromium |
| **Code Quality** | RuboCop (Shopify) + Brakeman + Reek + Flog + Flay | 8 linters running in parallel |
| **Auth Framework** | CanCanCan | Authorization scaffolding baked in |
| **Security** | Rack::Attack + SSRF Filter + Bundler Audit | Rate limiting and vulnerability scanning |
| **Deployment** | Kamal + Thruster + Multi-stage Dockerfile | Production-ready container deployment |
| **CI** | GitHub Actions + Dependabot | Automated testing and dependency updates |
| **Dev Tools** | Foreman + jemalloc + Bootsnap | Fast boot, low memory, process management |

---

## Quick Start

### Docker (recommended)

```bash
git clone https://github.com/{owner}/rails-8-AI-native-starter-kit.git
cd rails-8-AI-native-starter-kit
docker compose up
```

The startup pipeline runs automatically:

```
setup  → creates DB, runs migrations, seeds data
tests  → runs all 8 linters + parallel specs
app    → boots Puma + Tailwind watcher + Sidekiq
ws     → boots AnyCable-Go WebSocket server
```

Your app is live at `http://localhost:3000`, WebSockets at `ws://localhost:8081/cable`.

### Local (without Docker)

Requirements: Ruby 4.0+, PostgreSQL, Redis, `anycable-go`

```bash
bin/setup           # install deps, create DB, seed, start server
bin/check-fast      # run all linters in parallel
bin/prspec           # run specs with parallel_tests
```

---

## Architecture

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Browser   │◄──►│  Puma :3000  │◄──►│ PostgreSQL  │
│             │    │  (Rails 8)   │    │  + PgBouncer │
└──────┬──────┘    └──────┬───────┘    └─────────────┘
       │                  │
       │ WebSocket        │ Pub/Sub
       ▼                  ▼
┌──────────────┐    ┌──────────┐    ┌─────────────┐
│ AnyCable-Go  │◄──►│  Redis   │◄──►│   Sidekiq   │
│    :8081     │    │          │    │  (workers)  │
└──────────────┘    └──────────┘    └─────────────┘
                                         │
                                    ┌────▼────────┐
                                    │ LocalStack   │
                                    │ (S3) :4566   │
                                    └──────────────┘
```

---

## Testing

### Parallel Execution

Tests run across all available CPU cores via `parallel_tests`:

```bash
bin/prspec                    # parallel specs (default)
bin/check-fast                # 8 linters + specs, all parallel
bin/check --parallel=rubocop,rspec --then=brakeman
```

### Headless Browser Testing

Capybara system specs run with headless Chromium. The driver auto-detects the environment:
- **Docker**: uses `/usr/bin/chromium` (pre-installed in `Dockerfile.dev`)
- **macOS/Linux**: uses Selenium Manager to find native Chrome

Animations and transitions are automatically disabled in `RAILS_ENV=test` for deterministic, fast specs.

### Test Pipeline in Docker

```bash
docker compose up              # setup → tests → app (sequential gates)
docker compose run --rm tests  # run tests only
```

The `tests` service uses `service_completed_successfully` as a gate — your app literally won't boot unless every linter and spec passes.

---

## Code Quality Gates

| Linter | Purpose |
|---|---|
| `rubocop` | Style enforcement (Shopify conventions) |
| `brakeman` | Static security analysis |
| `bundler-audit` | Known CVE scanning in dependencies |
| `reek` | Code smell detection |
| `flog` | Complexity scoring |
| `flay` | Duplication detection |
| `haml-syntax` | Template validation |
| `rspec` | Unit + system specs (parallel) |

All 8 run in parallel via `bin/check-fast`. Sequential chains are supported with `bin/check --then=`.

---

## Docker Compose Services

| Service | Image | Port | Role |
|---|---|---|---|
| `postgres` | `postgres:17.5` | 5432 | Primary database with tuned config |
| `pgbouncer` | `edoburu/pgbouncer` | — | Transaction-mode connection pooling |
| `redis` | `redis:8.4-alpine` | 6379 | Pub/sub + cache + job queue backend |
| `localstack` | `localstack:4.13.1` | 4566 | S3-compatible object storage |
| `ws` | `anycable-go:1.6` | 8081 | WebSocket server |
| `setup` | (app image) | — | DB creation, migrations, seeds |
| `tests` | (app image) | — | Linters + parallel specs gate |
| `app` | (app image) | 3000 | Rails + Tailwind + Sidekiq |

All three app-derived containers (`setup`, `tests`, `app`) share a single Docker image build to prevent wasteful rebuilds.

---

## Key Decisions

### Why AnyCable over Action Cable?

AnyCable-Go handles WebSocket connections in a dedicated Go process, keeping Ruby threads free for business logic. It's a drop-in replacement — the Rails side uses standard Action Cable APIs via `anycable-rails`.

### Why PgBouncer?

Transaction-mode connection pooling prevents the "too many connections" problem in production. The `setup` and `tests` services bypass PgBouncer and connect directly to Postgres (required for `CREATE DATABASE`).

### Why Sidekiq over Solid Queue?

Sidekiq provides battle-tested async processing with a mature web UI, cron scheduling (`sidekiq-cron`), and deep Redis integration. The `recurring.yml` has example jobs pre-configured.

### Why jemalloc?

`LD_PRELOAD=/usr/local/lib/libjemalloc.so` — reduces Ruby memory fragmentation by 30-40% in production. Pre-configured in both Dockerfiles.

### Why Bootsnap Cache Isolation?

Each Docker container gets an anonymous volume (`/rails/tmp/cache`) to prevent concurrent Bootsnap compilation from crashing on shared macOS mounts.

---

## Demo Content

> ⚠️ **The following components exist purely for demonstration.** They show how each layer of the stack works together. **Delete them when starting a real application.**

| Component | Files | Demonstrates |
|---|---|---|
| **Todo CRUD** | `app/models/todo.rb`, `app/controllers/todos_controller.rb`, `app/views/todos/`, `db/migrate/*_create_todos.rb` | Model → Controller → View with Turbo Frames |
| **Turbo Stream broadcasting** | `after_create_commit` in `todo.rb`, `turbo_stream_from` in `index.html.erb` | Real-time push via AnyCable |
| **Stimulus controller** | `app/javascript/controllers/hello_controller.js` | Basic Stimulus wiring |
| **Three.js import** | `config/importmap.rb` (the `three` pin) | Importmap-based JS library usage |
| **Sample seed** | `db/seeds.rb` (the `Todo.create!` block) | Idempotent database seeding |
| **System spec** | `spec/system/todos_spec.rb` | Capybara + headless Chromium E2E test |
| **Home controller** | `app/controllers/home_controller.rb`, `app/views/home/` | Static page routing |
| **Example job** | `app/jobs/example_recurring_job.rb`, `config/recurring.yml` | Sidekiq-Cron recurring task |

---

## Project Structure

```
├── app/
│   ├── assets/tailwind/    # Tailwind v4 + DaisyUI theme (Halloween dark)
│   ├── controllers/        # Rails controllers
│   ├── javascript/         # Stimulus controllers + application.js
│   ├── models/             # ActiveRecord models
│   └── views/              # ERB + HAML templates
├── bin/
│   ├── check               # Orchestrator: parallel + sequential task runner
│   ├── check-fast           # Fast CI mode (8 linters in parallel)
│   ├── prspec              # Parallel RSpec runner
│   ├── setup               # One-command dev environment setup
│   └── linters/            # Individual linter scripts
├── config/
│   ├── cable.yml           # AnyCable adapter config
│   ├── database.yml        # PostgreSQL (env-driven, PgBouncer-aware)
│   └── recurring.yml       # Sidekiq-Cron job schedules
├── docker-compose.yml      # Full 8-service development stack
├── Dockerfile              # Multi-stage production image
├── Dockerfile.dev          # Development image (with Chromium)
└── spec/
    ├── support/capybara.rb # Cross-env headless browser driver
    └── system/             # E2E browser specs
```

---

## Environment Variables

All configuration is driven by environment variables with sensible defaults. See `env.example` for the complete list. Key variables:

| Variable | Default | Purpose |
|---|---|---|
| `DB_HOST` | `localhost` | PostgreSQL host (use `pgbouncer` in Docker) |
| `DB_DIRECT_HOST` | `localhost` | Direct PG host (bypasses PgBouncer for migrations) |
| `REDIS_URL` | `redis://localhost:6379/1` | Redis connection string |
| `RAILS_MASTER_KEY` | from `config/master.key` | Credentials decryption key |

---

## For AI Agents

This repository is optimized for LLM-assisted development:

- **Deterministic setup**: `docker compose up` produces identical environments
- **Fast feedback**: `bin/check-fast` validates all changes in seconds
- **Clear conventions**: Shopify Ruby style, RSpec, Stimulus naming
- **Minimal surface area**: one model, one controller, flat config files
- **No magic**: explicit imports, no metaprogramming in app code

To modify this project, start by reading:
1. `config/routes.rb` — all routes
2. `Gemfile` — all dependencies
3. `docker-compose.yml` — full infrastructure
4. `bin/check-fast` — validation pipeline

---

## License

MIT
