{ lib, helpers, ... }:
{
  config = lib.mkIf helpers.isWM {
    services = {
      tumbler.enable = true;
      gvfs.enable = true;
      udisks2.enable = true;
    };
  };
}
