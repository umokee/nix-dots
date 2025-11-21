{ config, pkgs, ... }:

{
  # MongoDB service
  services.mongodb = {
    enable = true;
    # Опционально: указать версию
    # package = pkgs.mongodb-6_0;
  };
}

