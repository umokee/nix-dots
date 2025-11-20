# 🔍 Анализ архитектуры NixOS конфигурации

## Текущее состояние

### modules/nixos/
```
0-base/          boot, environment, fonts, locale, network, packages, security, system, users
1-hardware/      amd, bluetooth, intel, nvidia, peripherals, power, print, sound
2-workspace/     display-manager, window-managers
3-programs/      appimage, gaming
4-services/      fail2ban, fstrim, kanata, mongodb, ms-sql, ollama, openssh, postgresql,
                 podman, sing-box, traefik, virtualization, xray, file-management
```

### modules/home-manager/
```
0-base/          environment, packages
1-workspace/     desktop (waybar, WMs, scripts, xdg), terminal (bash, foot)
2-programs/      applications, development, packages
3-services/      brightness, gammastep, kanshi
4-appearance/    colors, cursor, fonts, gtk, icons, qt
```

---

## 🔴 Проблемы текущей структуры

### 1. **Цифры вместо смысла**
- `0-base`, `1-hardware`, `2-workspace` - непонятный принцип нумерации
- Не ясно: это порядок загрузки? Приоритет? Просто нумерация?
- При добавлении нового модуля непонятно в какую цифру его класть

### 2. **nixos/0-base - свалка разнородных модулей**
Смешаны разные концепции:
- **Система**: boot, system
- **Сеть**: network
- **Безопасность**: security
- **Пользователи**: users
- **Локализация**: locale, fonts
- **Окружение**: environment, packages

### 3. **Дублирование packages**
- `nixos/0-base/packages.nix` - системные пакеты
- `nixos/3-programs/` - тоже пакеты (appimage, gaming)
- `home-manager/0-base/packages.nix` - пакеты пользователя
- `home-manager/2-programs/packages.nix` - тоже пакеты пользователя

### 4. **nixos/3-programs - почти пустая категория**
- Только 2 файла: appimage.nix, gaming.nix
- Не ясна разница между `programs` и `packages`

### 5. **nixos/4-services - смесь разных типов**
Нет разделения по назначению:
- Системные: openssh, fail2ban, fstrim, file-management
- Базы данных: postgresql, mongodb, ms-sql
- Прокси/VPN: sing-box, xray, traefik
- Виртуализация: podman, virtualization
- Утилиты: kanata, ollama

### 6. **Размазанность network по файлам**
- `nixos/0-base/network.nix` - firewall, sysctl
- `nixos/4-services/sing-box/` - routing, DNS, proxy
- `nixos/4-services/virtualization.nix` - bridge интерфейсы

---

## ✅ Предложение: Логичная архитектура

### Принцип организации: **По функциональному назначению**

```
modules/
├── nixos/
│   ├── core/              # Ядро системы (раньше 0-base)
│   │   ├── boot.nix
│   │   ├── system.nix
│   │   ├── users.nix
│   │   ├── locale.nix
│   │   └── fonts.nix
│   │
│   ├── network/           # Всё что связано с сетью (NEW!)
│   │   ├── base.nix              # firewall, sysctl
│   │   ├── sing-box/             # VPN/proxy
│   │   └── xray.nix              # Proxy
│   │
│   ├── security/          # Безопасность (NEW!)
│   │   ├── base.nix              # sudo, polkit, PAM
│   │   └── fail2ban.nix          # Защита от брутфорса
│   │
│   ├── hardware/          # Железо (без изменений)
│   │   ├── gpu/                  # NEW: группировка GPU
│   │   │   ├── nvidia.nix
│   │   │   ├── amd.nix
│   │   │   └── intel.nix
│   │   ├── sound.nix
│   │   ├── bluetooth.nix
│   │   ├── peripherals.nix
│   │   ├── power.nix
│   │   └── print.nix
│   │
│   ├── desktop/           # Рабочий стол (раньше workspace + programs)
│   │   ├── wm/                   # Window managers
│   │   ├── display-manager.nix
│   │   ├── gaming.nix
│   │   └── appimage.nix
│   │
│   ├── services/          # Системные сервисы
│   │   ├── system/               # NEW: системные
│   │   │   ├── openssh.nix
│   │   │   ├── fstrim.nix
│   │   │   └── file-management.nix
│   │   ├── database/             # NEW: базы данных
│   │   │   ├── postgresql.nix
│   │   │   ├── mongodb.nix
│   │   │   └── ms-sql.nix
│   │   ├── containers/           # NEW: контейнеры
│   │   │   ├── podman.nix
│   │   │   └── virtualization.nix
│   │   ├── web/                  # NEW: веб-сервисы
│   │   │   └── traefik.nix
│   │   └── other/                # NEW: остальное
│   │       ├── kanata.nix
│   │       └── ollama.nix
│   │
│   └── environment/       # Переменные окружения (NEW!)
│       └── base.nix
│
└── home-manager/
    ├── shell/             # Терминал и shell (раньше workspace/terminal)
    │   ├── bash.nix
    │   └── foot.nix
    │
    ├── desktop/           # Рабочий стол (раньше workspace/desktop)
    │   ├── wm/
    │   ├── waybar/
    │   ├── dunst.nix
    │   ├── tofi.nix
    │   └── xdg.nix
    │
    ├── programs/          # Приложения пользователя
    │   ├── browsers/             # NEW: группировка
    │   │   ├── firefox.nix
    │   │   └── zen-browser.nix
    │   ├── development/          # Без изменений
    │   │   ├── vscode/
    │   │   ├── git.nix
    │   │   └── languages.nix
    │   ├── media/                # NEW: группировка
    │   │   ├── obs.nix
    │   │   └── rclone.nix
    │   └── foot.nix
    │
    ├── services/          # Сервисы пользователя (без изменений)
    │   ├── brightness.nix
    │   ├── gammastep.nix
    │   └── kanshi.nix
    │
    ├── theme/             # Темы и внешний вид (раньше appearance)
    │   ├── colors/
    │   ├── fonts.nix
    │   ├── gtk.nix
    │   ├── qt.nix
    │   ├── cursor.nix
    │   └── icons.nix
    │
    └── base/              # Базовые настройки (без изменений)
        ├── environment.nix
        └── packages.nix
```

---

## 🎯 Ключевые изменения

### 1. **Убраны цифры - используются понятные имена**
- ❌ `0-base` → ✅ `core`, `base`
- ❌ `1-hardware` → ✅ `hardware`
- ❌ `2-workspace` → ✅ `desktop`, `shell`
- ❌ `3-programs` → ✅ `programs` (объединён)
- ❌ `4-services` → ✅ `services` (с подкатегориями)

### 2. **Разделение nixos/0-base по назначению**
- `core/` - ядро системы (boot, system, users)
- `network/` - вся сеть в одном месте
- `security/` - вся безопасность в одном месте
- `environment/` - переменные окружения

### 3. **Группировка services по типам**
- `system/` - системные (ssh, fstrim)
- `database/` - базы данных
- `containers/` - виртуализация и контейнеры
- `web/` - веб-сервисы
- `other/` - остальное

### 4. **Группировка похожих модулей**
- `hardware/gpu/` - все GPU драйверы вместе
- `programs/browsers/` - все браузеры вместе
- `programs/media/` - медиа приложения вместе
- `programs/development/` - dev tools вместе

### 5. **Единый принцип именования**
- home-manager: `shell`, `desktop`, `programs`, `services`, `theme`, `base`
- Понятно куда что класть при добавлении нового

---

## 📊 Преимущества новой структуры

### До (проблемы):
```
❌ Куда положить firewall? В base/network.nix
❌ Куда положить sing-box? В services/sing-box
❌ А они же оба про network! → размазаны
```

### После (решение):
```
✅ Всё про сеть → network/
   ├── base.nix (firewall, sysctl)
   ├── sing-box/ (proxy)
   └── xray.nix (proxy)
```

### До (путаница):
```
❌ Добавляю новый браузер - куда класть?
   home-manager/2-programs/applications/?
   home-manager/2-programs/?
   Какая разница между ними?
```

### После (ясность):
```
✅ Браузер → programs/browsers/
✅ Медиа → programs/media/
✅ Dev tools → programs/development/
```

---

## 🚀 План миграции

### Этап 1: Переименование директорий (структура)
1. nixos: `0-base` → `core`, создать `network`, `security`, `environment`
2. nixos: `1-hardware` → `hardware`, создать `gpu/`
3. nixos: `2-workspace` → `desktop`
4. nixos: удалить `3-programs`, перенести в `desktop`
5. nixos: `4-services` → `services`, создать подкатегории
6. home-manager: `1-workspace` → разделить на `shell` и `desktop`
7. home-manager: `4-appearance` → `theme`

### Этап 2: Перемещение файлов
1. Перенести network.nix → network/base.nix
2. Перенести security.nix → security/base.nix
3. Перенести environment.nix → environment/base.nix
4. Создать hardware/gpu/ и перенести драйверы
5. Реорганизовать services/ по подкатегориям
6. Группировка programs/ по типам

### Этап 3: Обновление импортов
1. Обновить все default.nix с новыми путями
2. Проверить что всё собирается

---

## ⚖️ Компромиссы

**Что ОСТАВЛЯЕМ как есть (хорошо работает):**
- ✅ `sing-box/` - разделение на модули полезно
- ✅ `waybar/` - разделение на modules/style удобно
- ✅ `vscode/` - разделение на settings/keybindings логично

**Что УПРОЩАЕМ (было избыточно):**
- ✅ environment.nix - один файл вместо 4
- ✅ boot.nix - один файл вместо 2

**Что НЕ ДЕЛАЕМ (избыточно):**
- ❌ Profiles/Roles - для 2-3 машин не нужно
- ❌ Theme system - работает и так
- ❌ Overlays в отдельную папку - пока не критично

---

## ✅ Финальная цель

**Простой ответ на вопрос: "Куда положить новый модуль?"**

- Драйвер GPU? → `hardware/gpu/`
- Firewall правило? → `network/base.nix`
- База данных? → `services/database/`
- Браузер? → `programs/browsers/`
- Window manager? → `desktop/wm/`

**Ясная логика = легкая поддержка** 🎯
