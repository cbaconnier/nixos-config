export function OpenMenuButton() {
    
  const button = (): Widget.Button => Widget.Button({
    child: Widget.Label({label: 'Menu'}),
    onClicked: () => App.toggleWindow('menu'),
  });

  return Widget.Box({
      children: [
          button(),
      ],
  });
}
