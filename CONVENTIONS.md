# 📖 Конвенции структуры конфигурации

## Принцип организации

**Функциональное назначение** - каждая директория отвечает за свою область.

**Простота** - один файл на модуль, разделять только если >200 строк И есть логичные части.

---

## 🗂️ Структура modules/nixos/

```
modules/nixos/
├── core/           # Ядро системы (базовые компоненты + сеть + безопасность)
├── hardware/       # Железо и драйверы
├── desktop/        # Рабочий стол и gaming
└── services/       # Системные сервисы (организованы по типу)
    ├── network/    # Сетевые сервисы
    ├── database/   # Базы данных
    ├── containers/ # Контейнеризация
    ├── web/        # Веб-сервисы
    └── system/     # Системные сервисы
```

### core/ - Ядро системы
**Что:** Базовые компоненты которые нужны ВСЕГДА
```
boot.nix        # Загрузчик, kernel overlay, sysctl
system.nix      # nix настройки, substituters, gc
users.nix       # Пользователи, группы
locale.nix      # Язык, timezone, консоль
fonts.nix       # Системные шрифты
packages.nix    # ТОЛЬКО базовые утилиты (vim, git, wget, htop)
network.nix     # Базовая сеть (firewall, networkmanager, базовые порты 22/80/443)
security.nix    # Базовая безопасность (sudo, PAM)
fail2ban.nix    # Защита от брутфорса
```

**Правило:** Сюда НЕ добавляем ничего кроме базовых вещей!

### hardware/ - Железо
**Что:** Драйверы и настройки железа
```
nvidia.nix      # GPU драйвер + environment переменные + пакеты
amd.nix         # GPU драйвер + environment переменные + пакеты
intel.nix       # GPU драйвер + environment переменные + пакеты
sound.nix       # Pipewire
bluetooth.nix   # Bluetooth
power.nix       # TLP и управление питанием
peripherals.nix # Клавиатура, мышь
print.nix       # Принтеры
```

**Правило:** Всё про железо В ОДНОМ файле (драйвер + переменные + пакеты)
**ВАЖНО:** Каждый модуль объявляет свои environment переменные!

### desktop/ - Рабочий стол
**Что:** Window managers, display managers, gaming
```
window-managers.nix  # Hyprland, Sway + их environment переменные
display-manager.nix  # GDM, SDDM
gaming.nix          # Steam, gamemode
appimage.nix        # AppImage поддержка
```

**Правило:** Всё что связано с desktop окружением
**ВАЖНО:** window-managers.nix объявляет Wayland/Hyprland environment переменные!

### services/ - Системные сервисы (по категориям)
**Что:** Сервисы организованы по типу
```
network/
  sing-box/      # VPN/Proxy (большой - в папке)
  xray.nix       # VPN/Proxy
database/
  postgresql.nix # PostgreSQL + порты + пакеты
  mongodb.nix    # MongoDB
  ms-sql.nix     # MS-SQL + порты + пакеты
containers/
  podman.nix     # Podman + firewall правила + пакеты
  virtualization.nix # QEMU/KVM
web/
  traefik.nix    # Traefik reverse proxy
system/
  openssh.nix    # SSH сервер
  fstrim.nix     # SSD trim
  kanata.nix     # Keyboard remapping
  ...
```

**Правило АВТОНОМНЫХ МОДУЛЕЙ:**
- Каждый модуль содержит ВСЁ что ему нужно:
  - Конфигурацию сервиса
  - Пакеты (через environment.systemPackages)
  - Порты (через networking.firewall.allowedTCPPorts)
  - Environment переменные (через environment.sessionVariables)
- Один файл на сервис, папка только если >200 строк

**Примеры:**
```nix
# services/database/postgresql.nix
{
  services.postgresql.enable = true;
  environment.systemPackages = [ pkgs.postgresql pkgs.pgadmin4-desktopmode ];
  networking.firewall.allowedTCPPorts = [ 5432 ];
}

# hardware/nvidia.nix
{
  hardware.nvidia = { ... };
  environment.sessionVariables = {
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    ...
  };
}
```

---

## 🏠 Структура modules/home-manager/

```
modules/home-manager/
├── base/       # Базовые настройки пользователя
├── shell/      # Терминал и shell
├── desktop/    # Рабочий стол пользователя
├── programs/   # Программы пользователя
├── services/   # Сервисы пользователя
└── theme/      # Темы и внешний вид
```

### base/ - Базовые настройки
```
environment.nix  # Переменные окружения пользователя
packages.nix     # ТОЛЬКО базовые CLI (zoxide, fzf, bat, eza)
```

**Правило:** Сюда НЕ добавляем GUI приложения!

### shell/ - Терминал
```
bash.nix        # Bash конфигурация + aliases
foot.nix        # Терминал foot
starship.nix    # Prompt
tmux.nix        # Terminal multiplexer
```

**Правило:** Всё что связано с CLI окружением

### desktop/ - Рабочий стол пользователя
```
WMs/            # Window managers (hyprland/)
waybar/         # Статус бар (разделён на modules/style)
scripts/        # Desktop скрипты
wallpapers.nix  # Обои
dunst.nix       # Уведомления
tofi.nix        # Launcher
xdg.nix         # XDG настройки, MIME types
```

### programs/ - Программы
```
applications/   # GUI приложения (firefox, zen-browser, obs, rclone)
development/    # Dev tools (vscode/, git.nix, languages.nix)
packages.nix    # Остальные пакеты программ
```

**Правило:**
- Браузеры, IDE → `applications/`
- Dev tools → `development/`
- Пакеты добавляются В МОДУЛЕ который их использует!

### services/ - Сервисы пользователя
```
brightness.nix  # Яркость экрана
gammastep.nix   # Ночной режим
kanshi.nix      # Управление мониторами
```

### theme/ - Темы
```
colors/         # Цветовые схемы
gtk.nix         # GTK тема
qt.nix          # Qt тема
fonts.nix       # Шрифты пользователя
cursor.nix      # Курсор
icons.nix       # Иконки
```

---

## 📋 Правила добавления нового модуля

### 1. **Куда класть?**

| Что добавляем | Куда класть | Пример |
|--------------|-------------|--------|
| Базовая утилита | `nixos/core/packages.nix` | vim, git, wget |
| Драйвер GPU | `nixos/hardware/[gpu].nix` | nvidia.nix |
| Network сервис | `nixos/services/network/[name]` | sing-box/, xray.nix |
| База данных | `nixos/services/database/[name].nix` | postgresql.nix, mongodb.nix |
| Контейнеризация | `nixos/services/containers/[name].nix` | podman.nix |
| Веб-сервис | `nixos/services/web/[name].nix` | traefik.nix |
| Системный сервис | `nixos/services/system/[name].nix` | openssh.nix, fstrim.nix |
| Desktop компонент | `nixos/desktop/[name].nix` | gaming.nix |
| Терминал/Shell | `home-manager/shell/[name].nix` | foot.nix, bash.nix |
| GUI приложение | `home-manager/programs/applications/` | firefox.nix |
| Dev tool | `home-manager/programs/development/` | vscode/ |
| CLI утилита | `home-manager/base/packages.nix` | bat, lsd |
| Тема | `home-manager/theme/` | gtk.nix |

### 2. **Разделять на папку или нет?**

**Один файл если:**
- <200 строк
- Нет логичных подразделов

**Папка если:**
- >200 строк
- Есть чёткие подразделы (как sing-box: dns, routes, inbounds)

### 3. **Где объявлять пакеты?**

**ПРАВИЛО:** Пакеты там же где их конфигурация!

```nix
# ✅ ПРАВИЛЬНО
# services/postgresql.nix
{
  services.postgresql.enable = true;
  environment.systemPackages = [ pkgs.postgresql ];
  networking.firewall.allowedTCPPorts = [ 5432 ];
}

# ❌ НЕПРАВИЛЬНО
# core/packages.nix
environment.systemPackages = [ pkgs.postgresql ]; # Почему тут???
```

### 4. **Где объявлять network правила?**

**ПРАВИЛО:** Порты объявляются В МОДУЛЕ!

```nix
# ✅ ПРАВИЛЬНО
# services/podman.nix
{
  virtualisation.podman.enable = true;
  networking.firewall.trustedInterfaces = [ "podman0" ];
  networking.firewall.allowedTCPPorts = [ 8080 ];
}
```

NixOS автоматически объединит все `allowedTCPPorts` из разных модулей!

---

## 🎯 Примеры

### Пример 1: Добавляем новую базу данных (Redis)

```bash
# Создаём файл
touch modules/nixos/services/database/redis.nix
```

```nix
# modules/nixos/services/database/redis.nix
{
  services.redis = {
    enable = true;
    port = 6379;
  };

  networking.firewall.allowedTCPPorts = [ 6379 ];
  environment.systemPackages = [ pkgs.redis ];
}
```

```nix
# modules/nixos/services/database/default.nix
{
  imports = [
    ./postgresql.nix
    ./mongodb.nix
    ./ms-sql.nix
    ./redis.nix  # Добавили
  ];
}
```

### Пример 2: Добавляем новый GPU (Arc)

```bash
# Создаём файл
touch modules/nixos/hardware/arc.nix
```

```nix
# modules/nixos/hardware/arc.nix
{
  hardware.intel.arc.enable = true;

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  environment.systemPackages = with pkgs; [
    intel-gpu-tools
  ];
}
```

### Пример 3: Добавляем браузер

```bash
# Создаём файл
touch modules/home-manager/programs/applications/chromium.nix
```

```nix
# modules/home-manager/programs/applications/chromium.nix
{
  programs.chromium = {
    enable = true;
    extensions = [ ... ];
  };
}
```

```nix
# modules/home-manager/programs/applications/default.nix
{
  imports = [
    # ...
    ./chromium.nix  # Добавили
  ];
}
```

---

## ✅ Чеклист перед коммитом

- [ ] Файл в правильной директории (и подкатегории для services/)?
- [ ] Пакеты объявлены В МОДУЛЕ (не в core/packages.nix)?
- [ ] Порты объявлены В МОДУЛЕ (не в core/network.nix)?
- [ ] Environment переменные объявлены В МОДУЛЕ (не в отдельном environment.nix)?
- [ ] Добавлен import в соответствующий default.nix?
- [ ] Если файл >200 строк - можно ли разделить?

---

## 🔍 Поиск настроек

**Вопрос:** Где настройки [чего-то]?

| Что ищем | Где смотреть |
|----------|--------------|
| Порты для postgres | `services/database/postgresql.nix` (там всё!) |
| NVIDIA переменные | `hardware/nvidia.nix` (всё там!) |
| Wayland переменные | `desktop/window-managers.nix` (всё там!) |
| Firewall базовые | `core/network.nix` (только 22/80/443) |
| Конкретные порты | В модуле сервиса! |
| Sudo настройки | `core/security.nix` |
| Network сервисы | `services/network/` (sing-box, xray) |
| Базы данных | `services/database/` (postgresql, mongodb, ms-sql) |

**Принцип:** Всё про модуль - В ФАЙЛЕ модуля! (Автономные модули)

---

## 💡 Философия

1. **Простота** - один файл, если не огромный
2. **Логичность** - понятно куда класть новое
3. **Автономность** - модуль содержит всё что ему нужно
4. **Ищется легко** - всё про X в файле X

**Цель:** Открыл файл → увидел ВСЁ про этот компонент. 🎯
