# 🔴 КРИТИЧЕСКАЯ ПРОБЛЕМА: Зависание при сборке NixOS

## Найденные проблемы:

### 1. ❌ ОТСУТСТВУЮТ substituters в nix.settings
**Файл**: `modules/nixos/0-base/system.nix`

**Проблема**: Nix не знает откуда качать бинарные пакеты!
- Нет `substituters` (откуда качать пакеты)
- Нет `trusted-public-keys` (для проверки подписей)
- Нет timeout настроек

**Результат**:
- Nix пытается подключиться к cache.nixos.org по умолчанию
- Если sing-box блокирует или DNS медленный → зависание
- Если нет сети → зависание навсегда

### 2. ⚠️ Sing-box может блокировать cache.nixos.org
**Файл**: `modules/nixos/4-services/sing-box.nix`

**Проблема**:
- TUN интерфейс перехватывает ВСЕ соединения
- DNS запросы идут через sing-box DNS (1.1.1.1 через proxy)
- `cache.nixos.org` и `*.nixos.org` НЕ в исключениях

### 3. ⚠️ Нет оптимизации для параллельной загрузки
- Нет `http-connections` (количество параллельных соединений)
- Нет `download-attempts` (количество попыток)
- Нет `connect-timeout` (timeout для подключения)

### 4. ⚠️ NetworkManager может конфликтовать
- При поднятии TUN интерфейса NetworkManager может менять маршруты
- Это может разорвать соединения к cache.nixos.org

## Решение:

1. Добавить substituters в nix.settings
2. Добавить cache.nixos.org в исключения sing-box
3. Добавить timeout настройки
4. Добавить fallback на компиляцию
