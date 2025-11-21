{ config, pkgs, ... }:

{
  # Ollama как сервис
  services.ollama = {
    enable = true;
    
    # GPU ускорение (выбери своё)
    acceleration = "cuda";  # Для NVIDIA
    # acceleration = "rocm";  # Для AMD
    # acceleration = false;   # Только CPU
    
    # Автозагрузка моделей при старте (опционально)
    loadModels = [ 
      "deepseek-coder:33b"  # Лучшая для кодинга
      # "qwen2.5-coder:32b"  # Альтернатива
    ];
    
    # Открыть порт для доступа (если нужен WebUI)
    # openFirewall = true;
  };
  
  # Если нужен WebUI (Open WebUI)
  # services.open-webui = {
  #   enable = true;
  #   port = 8080;
  # };
}
