# 🎯 ПЛАН МАСШТАБНОГО РЕФАКТОРИНГА КОНФИГУРАЦИИ

## 📊 Текущее состояние

**Статистика:**
- Всего .nix файлов: 114
- Самые большие файлы:
  - sing-box.nix: 397 строк (!)
  - hyprland/default.nix: 270 строк
  - waybar.nix: 260 строк
  - vscode.nix: 234 строки

**Проблемы:**
1. ❌ Неиспользуемый код (mangowc, dwl, alacritty)
2. ❌ Монолитные файлы (sing-box 400 строк!)
3. ❌ Дублирование настроек
4. ❌ Закомментированный код везде
5. ❌ Нет unified способа управления
6. ❌ Сложно добавлять новые фичи

---

## 🎨 ПРЕДЛОЖЕНИЯ ПО УЛУЧШЕНИЮ

### 1. 🗑️ УДАЛИТЬ НЕИСПОЛЬЗУЕМОЕ

**Удалить полностью:**
- `modules/home-manager/1-workspace/desktop/WMs/mangowc/` - вся директория
- `modules/home-manager/2-programs/applications/alacritty.nix`
- `modules/home-manager/4-appearance/colors/alacritty.nix`
- Упоминания dwl из helpers.nix и config.nix

**Очистить от комментариев:**
- Удалить 200+ строк закомментированного кода
- Оставить только важные TODOs с префиксом

---

### 2. 📦 СОЗДАТЬ PROFILES (готовые конфигурации)

**Новая структура:**
```
profiles/
├── base.nix              # Общее для всех
├── desktop/
│   ├── gaming.nix        # Desktop + gaming оптимизации
│   └── workstation.nix   # Desktop + development
├── laptop/
│   └── portable.nix      # Laptop + energy saving
└── server/
    └── minimal.nix       # Server без GUI
```

**Пример использования:**
```nix
# hosts/desktop/configuration.nix
imports = [
  ../../profiles/base.nix
  ../../profiles/desktop/gaming.nix
];
```

---

### 3. 🔨 РАЗБИТЬ МОНОЛИТНЫЕ ФАЙЛЫ

**sing-box.nix (397 строк) → разбить на:**
```
modules/nixos/4-services/sing-box/
├── default.nix           # Main config (50 строк)
├── rule-sets.nix        # Rule sets (50 строк)
├── dns.nix              # DNS config (80 строк)
├── inbounds.nix         # Inbounds (40 строк)
├── outbounds.nix        # Outbounds (40 строк)
└── routes.nix           # Routing rules (100 строк)
```

**waybar.nix (260 строк) → разбить на:**
```
modules/home-manager/1-workspace/desktop/waybar/
├── default.nix          # Main config
├── modules.nix          # Module definitions
└── style.nix            # CSS styling
```

**vscode.nix (234 строки) → разбить на:**
```
modules/home-manager/2-programs/development/vscode/
├── default.nix          # Main config
├── settings.nix         # Editor settings
├── keybindings.nix     # Key bindings
└── extensions.nix       # Extensions list
```

---

### 4. 🎭 СОЗДАТЬ OVERLAYS

**Структура:**
```
overlays/
├── default.nix
├── custom-kernel.nix    # Kernel tweaks
├── custom-packages.nix  # Modified packages
└── nvidia-fixes.nix     # NVIDIA specific patches
```

**Вынести туда:**
- Kernel overlay из boot.nix
- VSCode wrapper из vscode.nix
- sing-box wrapper

---

### 5. 🏠 УЛУЧШИТЬ HOME-MANAGER

**Создать роли:**
```
modules/home-manager/roles/
├── developer.nix        # VSCode, git, neovim
├── gamer.nix           # Steam, Discord, OBS
├── designer.nix        # GIMP, Inkscape, etc
└── minimal.nix         # Only essentials
```

**В hosts импортировать:**
```nix
imports = [
  ../../modules/home-manager/roles/developer.nix
  ../../modules/home-manager/roles/gamer.nix
];
```

---

### 6. 🛠️ ДОБАВИТЬ УТИЛИТЫ

**Создать:**
```
scripts/
├── rebuild.sh          # Умный rebuild с выбором хоста
├── update.sh           # Update + cleanup
├── backup.sh           # Backup конфигурации
├── test.sh            # Test перед apply
└── clean.sh           # Cleanup старых generations
```

**Makefile:**
```makefile
.PHONY: switch test update clean

switch:
	sudo nixos-rebuild switch --flake .

test:
	sudo nixos-rebuild test --flake .

update:
	nix flake update && make switch

clean:
	sudo nix-collect-garbage -d
```

---

### 7. 📝 УЛУЧШИТЬ ДОКУМЕНТАЦИЮ

**Создать:**
```
docs/
├── README.md              # Quick start
├── STRUCTURE.md          # Структура проекта
├── ADDING_FEATURES.md    # Как добавить новую фичу
├── TROUBLESHOOTING.md    # Решение проблем
└── PROFILES.md           # Описание profiles
```

---

### 8. 🎯 ОПТИМИЗИРОВАТЬ СТРУКТУРУ

**Текущая проблема:**
```
modules/nixos/0-base/
├── boot.nix (80 строк - kernel overlay внутри!)
├── environment.nix (76 строк - всё вперемешку)
├── network.nix (130 строк - desktop и server вместе)
```

**Новая структура:**
```
modules/nixos/base/
├── boot/
│   ├── default.nix
│   ├── grub.nix
│   └── kernel.nix
├── environment/
│   ├── default.nix
│   ├── wayland.nix
│   ├── nvidia.nix
│   └── desktop.nix
└── network/
    ├── default.nix
    ├── desktop.nix
    └── server.nix
```

---

### 9. 🔧 УНИФИЦИРОВАТЬ ENABLE СИСТЕМУ

**Текущая проблема:**
- Иногда `hasIn "workspace" "hyprland"`
- Иногда `helpers.isWM`
- Иногда `helpers.isDesktop`

**Предложение - создать единый формат:**
```nix
# shared/features.nix
{
  features = {
    desktop = {
      wm = "hyprland";
      terminal = "foot";
      browser = "zen";
    };

    hardware = {
      gpu = "nvidia";
      cpu = "intel";
    };

    roles = [
      "developer"
      "gamer"
    ];
  };
}
```

---

### 10. 🎨 ДОБАВИТЬ ТЕМЫ

**Создать theme system:**
```
themes/
├── default.nix
├── ayu-dark.nix       # Текущая тема
├── catppuccin.nix
└── nord.nix
```

**В config выбирать:**
```nix
theme = "ayu-dark";
```

---

## 📋 ПРИОРИТЕТЫ

### Фаза 1: Очистка (1 день)
1. ✅ Удалить mangowc, alacritty, dwl
2. ✅ Удалить закомментированный код
3. ✅ Исправить критические баги из аудита

### Фаза 2: Разбиение монолитов (2 дня)
4. ✅ Разбить sing-box.nix
5. ✅ Разбить waybar.nix
6. ✅ Разбить vscode.nix
7. ✅ Разбить boot.nix, environment.nix, network.nix

### Фаза 3: Profiles и Roles (1 день)
8. ✅ Создать profiles/
9. ✅ Создать roles/
10. ✅ Переделать hosts/ на использование profiles

### Фаза 4: Утилиты и документация (1 день)
11. ✅ Создать scripts/
12. ✅ Создать Makefile
13. ✅ Написать docs/

### Фаза 5: Оптимизация (опционально)
14. ⏸️ Создать overlays/
15. ⏸️ Унифицировать enable систему
16. ⏸️ Добавить theme system

---

## 🎯 ОЖИДАЕМЫЙ РЕЗУЛЬТАТ

**До рефакторинга:**
```
❌ 114 файлов
❌ Самый большой файл: 397 строк
❌ Много дублирования
❌ Неиспользуемый код
❌ Сложно найти нужное
❌ Нет documentation
```

**После рефакторинга:**
```
✅ ~90 файлов (удалим 24 файла мусора)
✅ Максимум 150 строк на файл
✅ Zero дублирование
✅ Только используемый код
✅ Логичная структура с profiles
✅ Полная documentation
✅ Scripts для автоматизации
✅ Makefile для быстрых команд
```

---

## 💡 БОНУСЫ

### 1. Pre-commit hooks
```
.git/hooks/pre-commit:
#!/bin/sh
nix flake check
nixfmt --check .
```

### 2. CI/CD (GitHub Actions)
```yaml
.github/workflows/check.yml:
- name: Check flake
  run: nix flake check
```

### 3. Auto-update bot
Можно настроить бота для автоматического обновления flake inputs

---

## 🤔 ЧТО ХОТИТЕ РЕАЛИЗОВАТЬ?

Выберите что важно:
1. **Быстрая очистка** (Фаза 1) - удалить мусор
2. **Полный рефакторинг** (Фазы 1-4) - всё переделать
3. **Постепенно** - делать по частям

Или у вас есть свои идеи? 🚀
