import GObject from 'gi://GObject';
import Gtk from 'gi://Gtk';
import { Bar } from './modules/bar';
import { Menu } from './modules/menu';

const monitors: Monitor[] = JSON.parse(Utils.exec('hyprctl -j monitors'));

App.config({
    style: "./style.css",
    windows: [
      ...monitors.map(monitor => Bar(monitor)),
      Menu(),
    ]
});

export {};
