{ specialisation, ... }: {

  specialisation.dark.configuration = { imports = [ ./dark.nix ]; };

  specialisation.light.configuration = { imports = [ ./light.nix ]; };

}
