{ lib, helpers, ... }:
{
  config = lib.mkIf (helpers.isDesktop || helpers.isLaptop) {
    services.fstrim = {
      enable = true;
      interval = "daily";
    };
  };
}
