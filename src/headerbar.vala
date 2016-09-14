/*
Copyright (C) 2016, Cristian García <cristian99garcia@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

namespace Noxer {

    public class HeaderBar: Gtk.Box {

        public signal void save();
        public signal void open_filechooser();
        public signal void open_file(string path);

        public Gtk.HeaderBar left_bar;
        public Gtk.HeaderBar right_bar;

        public Gtk.Button open_button;
        public Gtk.Button recents_button;
        public Gtk.Button save_button;

        public Noxer.NotebookTab? tab = null;

        public HeaderBar() {
            this.left_bar = new Gtk.HeaderBar();
            this.left_bar.set_title("Proyecto");
            this.left_bar.set_show_close_button(false);
            this.pack_start(this.left_bar, false, false, 0);

            Gtk.Separator separator = new Gtk.Separator(Gtk.Orientation.VERTICAL);
            this.pack_start(separator, false, false, 0);

            this.right_bar = new Gtk.HeaderBar();
            this.right_bar.set_title("Noxer");
            this.right_bar.set_show_close_button(true);
            this.pack_end(this.right_bar, true, true, 0);

            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            Gtk.StyleContext context = box.get_style_context();
            context.add_class("linked");
            this.right_bar.pack_start(box);

            this.open_button = new Gtk.Button.with_label("Abrir");
            this.open_button.clicked.connect(() => { this.open_filechooser(); });
            box.pack_start(this.open_button, false, false, 0);

            this.recents_button = new Gtk.Button.from_icon_name("pan-down-symbolic", Gtk.IconSize.BUTTON);
            box.pack_start(this.recents_button, false, false, 0);

            this.save_button = new Gtk.Button.from_icon_name("document-save-symbolic", Gtk.IconSize.BUTTON);
            this.save_button.set_sensitive(false);
            this.save_button.clicked.connect(() => { this.save(); });
            this.right_bar.pack_start(this.save_button);
        }

        public void update() {
            if (this.tab != null) {
                if (this.tab.view.type == Noxer.ViewType.NORMAL) {
                    Noxer.EditView view = (this.tab.view as Noxer.EditView);
                    bool subtitle = view.file != null;
                    this.right_bar.set_has_subtitle(subtitle);
                    this.save_button.set_sensitive(view.get_modified());

                    if (subtitle) {
                        this.right_bar.set_subtitle(view.file);
                    } else {
                        this.right_bar.set_subtitle("");
                    }
                } else if (this.tab.view.type == Noxer.ViewType.SETTINGS) {
                    this.right_bar.set_has_subtitle(true);
                    this.right_bar.set_subtitle("Configuraciones");
                    this.save_button.set_sensitive(false);
                }
            } else {
                this.right_bar.set_has_subtitle(false);
                this.right_bar.set_subtitle("");
                this.save_button.set_sensitive(false);
            }
        }

        public void update_from_tab(Noxer.NotebookTab? tab) {
            this.tab = tab;
            this.update();
        }
    }
}