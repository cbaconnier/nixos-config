{ ... }:
{
  services.flatpak.enable = true;

  # GeForce NOW
  #
  #   ```
  #   flatpak remote-add --user --if-not-exists nvidia-geforcenow https://international.download.nvidia.com/GFNLinux/flatpak/geforcenow.flatpakrepo
  #   flatpak install --user nvidia-geforcenow com.nvidia.geforcenow
  #   ```
  #
  # OpenDeck (Stream Deck software)
  #
  #   ```
  #   flatpak install --user flathub me.amankhanna.opendeck
  #   ```
}
