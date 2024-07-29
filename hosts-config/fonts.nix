{ pkgs, ...}:
{
 fonts = {
  packages = with pkgs; [
   twitter-color-emoji
   font-awesome
   powerline-fonts
   nerdfonts

   noto-fonts
   noto-fonts-cjk
   noto-fonts-emoji
   source-code-pro
   source-han-mono
   source-han-sans
   source-han-serif
   wqy_zenhei
  ];
 };
}
