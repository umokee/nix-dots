{
  lib,
  helpers,
  ...
}:
let
  enable = helpers.hasIn "base" "locale";

  timezone = "Asia/Vladivostok";
  locale = "en_US.UTF-8";
in
{
  config = lib.mkIf enable {
    time.timeZone = timezone;
    i18n.defaultLocale = locale;
    i18n.supportedLocales = [
      "ru_RU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
    i18n.extraLocaleSettings = {
      LC_ADDRESS = locale;
      LC_IDENTIFICATION = locale;
      LC_MEASUREMENT = locale;
      LC_MONETARY = locale;
      LC_NAME = locale;
      LC_NUMERIC = locale;
      LC_PAPER = locale;
      LC_TELEPHONE = locale;
      LC_TIME = locale;
    };
  };
}
