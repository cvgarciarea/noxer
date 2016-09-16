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

    public class Window: Gtk.ApplicationWindow {

        public Noxer.HeaderBar headerbar;
        public Gtk.Box canvas;
        public Gtk.Box hbox;
        public Noxer.LateralPanel panel;
        public Noxer.EditBox editbox;

        public Gtk.SizeGroup hsize_group;

        public Window() {
            this.set_default_size(620, 400);

            this.headerbar = new Noxer.HeaderBar();
            this.headerbar.open_filechooser.connect(this.open_filechooser_open);
            this.headerbar.save.connect(this.save);
            this.set_titlebar(this.headerbar);

            this.canvas = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            this.add(this.canvas);

            this.hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            this.canvas.pack_start(this.hbox, true, true);

            this.panel = new Noxer.LateralPanel();
            this.hbox.pack_start(this.panel, false, false, 0);

            this.editbox = new Noxer.EditBox();
            this.editbox.update_headerbar.connect(this.update_headerbar_cb);
            this.hbox.pack_start(this.editbox, true, true, 0);

            this.hsize_group = new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL);
            this.hsize_group.add_widget(this.panel);
            this.hsize_group.add_widget(this.headerbar.left_bar);

            this.new_file();
            this.show_all();
        }

        private void update_headerbar_cb(Noxer.EditBox editbox, Noxer.NotebookTab? tab) {
            this.headerbar.update_from_tab(tab);
        }

        public void new_file(string? file = null) {
            this.editbox.new_file(file);
        }

        public Noxer.BaseView? get_current_view() {
            return this.editbox.get_current_view();
        }

        public void close_current_tab() {
            this.editbox.try_close_current_tab();
        }

        public string? get_folder_for_filechooser() {
            Noxer.BaseView? bview = this.editbox.get_current_view();
            string? path = null;
            if (bview != null && bview.type == Noxer.ViewType.NORMAL) {
                Noxer.EditView view = (bview as Noxer.EditView);
                if (view.file != null) {
                    GLib.File file = GLib.File.new_for_path(view.file);
                    path = file.get_parent().get_path();
                }
            }

            return path;
        }

        public void open_filechooser_open(Gtk.Widget? widget=null) {
            Noxer.FileChooserOpen filechooser = new Noxer.FileChooserOpen(this.get_folder_for_filechooser());
            filechooser.open_files.connect((files) => { this.open_multiple_files(files); });
            filechooser.show_all();
        }

        public void save(Gtk.Widget? widget=null) {
            Noxer.BaseView? bview = this.editbox.get_current_view();
            if (bview == null || bview.type == Noxer.ViewType.SETTINGS) {
                return;
            }

            Noxer.EditView view = (bview as Noxer.EditView);
            bool saved = view.save();

            if (!saved) {
                Noxer.FileChooserSave filechooser = new Noxer.FileChooserSave(this.get_folder_for_filechooser());
                filechooser.save.connect((file) => { view.save(file); });
                filechooser.show_all();
            }
        }

        public void open_multiple_files(string[] files) {
            foreach (string file in files) {
                this.new_file(file);
            }
        }
    }
}