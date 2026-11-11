{ lib, ... }:
{
  age.secrets = lib.optionalAttrs (builtins.pathExists ../../secrets/rbw-email.age) {
    rbw-email = {
      file = ../../secrets/rbw-email.age;
      owner = "clement";
      mode = "0400";
    };
  };
}
