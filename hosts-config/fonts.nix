{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      twitter-color-emoji
      font-awesome
      powerline-fonts

      # https://www.reddit.com/r/NixOS/comments/1h1nc2a/nerdfonts_has_been_separated_into_individual_font/
      nerd-fonts.dejavu-sans-mono
      nerd-fonts.jetbrains-mono

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      source-code-pro
      source-han-mono
      source-han-sans
      source-han-serif
      wqy_zenhei
    ];
  };
}
