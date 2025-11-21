{ config, pkgs, ... }:

{
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    loadModels = [
      "deepseek-coder:33b"
    ];
  };
}
