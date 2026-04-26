# Student Article Publication Platform

## Stack
- Laravel Breeze + Inertia React
- Material UI
- Jodit editor
- Spatie Laravel Permission
- MySQL + Docker Compose

## Setup
```bash
composer install
npm install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
```

## Seeded Accounts
- Writer: `writer@example.com` / `password`
- Editor: `editor@example.com` / `password`
- Student: `student@example.com` / `password`

## Role Routes
| Role | Method | Route | Name |
|---|---|---|---|
| Writer | GET | `/writer/dashboard` | `writer.dashboard` |
| Writer | POST | `/articles` | `articles.store` |
| Writer | POST | `/articles/{article}/submit` | `articles.submit` |
| Writer | PUT | `/articles/{article}/revise` | `articles.revise` |
| Editor | GET | `/editor/dashboard` | `editor.dashboard` |
| Editor | POST | `/articles/{article}/revision` | `articles.revision` |
| Editor | POST | `/articles/{article}/publish` | `articles.publish` |
| Student | GET | `/student/dashboard` | `student.dashboard` |
| Student | POST | `/articles/{article}/comment` | `articles.comment` |

## Lifecycle
`Draft -> Submitted -> Needs Revision -> Published`

Comments are available on published articles.
