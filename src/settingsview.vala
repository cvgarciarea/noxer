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

    public class ListBox: Gtk.Box {

        public Gtk.Box scrolled_box;
        public Gtk.ListBox listbox;

        public ListBox() {
            this.set_orientation(Gtk.Orientation.HORIZONTAL);

            Gtk.ScrolledWindow scroll = new Gtk.ScrolledWindow(null, null);
            scroll.set_size_request(400, 1);
            this.pack_start(scroll, true, true, 0);

            Gtk.Box hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            scroll.add(hbox);

            this.scrolled_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            this.scrolled_box.set_size_request(400, 1);
            hbox.set_center_widget(this.scrolled_box);
        }

        public void new_section(string name) {
            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            this.scrolled_box.pack_start(box, false, false, 5);

            Gtk.Label label = new Gtk.Label(null);
            label.set_markup(@"<b>$name</b>");
            label.set_margin_top(4);
            label.set_margin_start(6);
            box.pack_start(label, false, false, 2);

            this.listbox = new Gtk.ListBox();
            this.listbox.set_selection_mode(Gtk.SelectionMode.NONE);
            this.scrolled_box.pack_start(this.listbox, false, false, 0);
        }

        public void new_row(Gtk.Widget widget, string name, string? help=null) {
            Gtk.ListBoxRow row = new Gtk.ListBoxRow();
            row.set_size_request(1, 50);
            this.listbox.add(row);

            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.set_border_width(5);
            row.add(box);

            Gtk.Box vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.pack_start(vbox, false, true, 0);

            Gtk.Label label = new Gtk.Label(name);
            label.set_xalign(0);
            vbox.pack_start(label, false, false, 0);

            if (help != null) {
                label = new Gtk.Label(null);
                label.set_xalign(0);
                label.set_sensitive(false);
                label.set_markup(@"<small>$help</small>");
                vbox.pack_start(label, false, false, 0);
            }

            vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            vbox.set_center_widget(widget);
            box.pack_end(vbox, false, false, 0);
        }
    }

    public class SettingsView: Noxer.BaseView {

        public Gtk.Stack stack;
        public Gtk.StackSidebar sidebar;

        public Gtk.Box appearance_box;
        public Gtk.Box editor_box;
        public Gtk.Box extensions_box;

        public Noxer.Settings settings;

        public SettingsView() {
            this.type = Noxer.ViewType.SETTINGS;

            this.settings = Noxer.get_settings();
            // Connect signals

            this.remove(this.scroll);
            this.set_border_width(5);

            Gtk.Box canvas = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 2);
            this.pack_start(canvas, true, true, 0);

            this.stack = new Gtk.Stack();
            this.stack.set_transition_type(Gtk.StackTransitionType.OVER_UP_DOWN);
            canvas.pack_end(this.stack, true, true, 0);

            this.sidebar = new Gtk.StackSidebar();
            this.sidebar.set_stack(this.stack);
            this.sidebar.set_size_request(150, 1);
            canvas.pack_start(this.sidebar, false, false, 0);

            this.make_boxes();

            this.stack.add_titled(this.appearance_box, "appearance", "Apariencia");
            this.stack.add_titled(this.editor_box, "editor", "Editor");
            this.stack.add_titled(this.extensions_box, "extensions", "Extensiones");

            this.show_all();
        }

        public void make_boxes() {
            this.make_appearance_box();
            this.make_editor_box();
            this.make_extensions_box();
        }

        public void make_appearance_box() {
            this.appearance_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

            Noxer.ListBox listbox = new Noxer.ListBox();
            this.appearance_box.pack_start(listbox, true, true, 0);

            listbox.new_section("Temas");

            Gtk.Switch switch_dark = new Gtk.Switch();
            switch_dark.set_active(this.settings.use_dark_theme);
            listbox.new_row(switch_dark, "Tema oscuro", "Usar la versión oscura del tema");

            Gtk.Switch switch_grid = new Gtk.Switch();
            switch_grid.set_active(this.settings.show_grid);
            listbox.new_row(switch_grid, "Mostrar cuadrícula", "Patrón de cuadrícula ");
        }

        public void make_editor_box() {
            this.editor_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        }

        public void make_extensions_box() {
            this.extensions_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        }
    }
}