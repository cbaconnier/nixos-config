export function Menu() {
   
    const menuButton = (label: string, onClick: () => void) => Widget.Button({
        child: Widget.Label({ label: label }),
        onClicked: onClick,
        className: 'menu-button',
    });

    const self = Widget.Window({
       name: 'menu',
       anchor: ['top', 'right'],
       visible: false,
       focusable: true,
       child: Widget.Box({
           vertical: true,
          className: 'menu-box',
           children: [
                menuButton('Menu Item 1', () => {
                    console.log('Menu Item 1 clicked');
                }),
                menuButton('Menu Item 2', () => {
                    console.log('Menu Item 2 clicked');
                }),
                menuButton('Menu Item 3', () => {
                    console.log('Menu Item 3 clicked');
                }),
           ],
       }),
    });
   
    // Seems to be not working at the moment
    // self.keybind("Escape", () => App.closeWindow("menu"));
    
    return self;
}
