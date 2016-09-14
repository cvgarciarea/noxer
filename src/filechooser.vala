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

    public class FileChooser: Gtk.FileChooserDialog {

        public FileChooser() {
            NoxerApp app = Noxer.get_app_instance();
            Noxer.Window win = app.get_current_window();
            this.set_transient_for(win);
            this.set_modal(true);

            this.add_button("Cancelar", Gtk.ResponseType.CANCEL);
        }
    }

    public class FileChooserOpen: Noxer.FileChooser {

        public signal void open_files(string[] files);

        public FileChooserOpen() {
            this.set_action(Gtk.FileChooserAction.OPEN);
            this.set_select_multiple(true);
            this.set_title("Abrir");
            this.add_button("Abrir", Gtk.ResponseType.OK);
            this.set_default_response(Gtk.ResponseType.OK);

            this.response.connect(this.response_cb);
        }

        private void response_cb(Gtk.Dialog dialog, int response_id) {
            if (response_id == Gtk.ResponseType.OK) {
                string[] files = { };
                foreach (string file in this.get_filenames()) {
                    files += file;
                }

                this.open_files(files);
            }

            this.destroy();
        }
    }

    public class FileChooserSave: Noxer.FileChooser {

        public signal void save(string path);

        public FileChooserSave() {
            this.set_action(Gtk.FileChooserAction.SAVE);
            this.set_title("Guardar");
            this.add_button("Guardar", Gtk.ResponseType.OK);
            this.set_default_response(Gtk.ResponseType.OK);
            this.set_do_overwrite_confirmation(true);

            this.response.connect(this.response_cb);
        }

        private void response_cb(Gtk.Dialog dialog, int response_id) {
            if (response_id == Gtk.ResponseType.OK) {
                this.save(this.get_filename());
            }
            
            this.destroy();
        }
    }
}