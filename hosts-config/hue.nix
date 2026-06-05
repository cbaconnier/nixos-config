{ lib, ... }:
{
  age.secrets = lib.optionalAttrs (builtins.pathExists ../secrets/hue-api-key.age) {
    hue-api-key = {
      file = ../secrets/hue-api-key.age;
      owner = "clement";
    };
  };
}
