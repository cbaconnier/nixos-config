{ pkgs, ...}:
{
 fonts = {
  packages = with pkgs; [
   twitter-color-emoji
   font-awesome
   powerline-fonts
   nerdfonts
  ];
 };
}
