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

    public class InfoBar: Gtk.Revealer {

        public signal void save(Noxer.NotebookTab tab);
        public signal void dont_save(Noxer.NotebookTab tab);

        public Gtk.InfoBar bar;
        public Gtk.Label message_label;

        public Noxer.NotebookTab? tab = null;

        public InfoBar() {
            this.set_transition_type(Gtk.RevealerTransitionType.SLIDE_DOWN);

            this.bar = new Gtk.InfoBar();
            this.bar.add_button("Guardar", Gtk.ResponseType.YES);
            this.bar.add_button("No guardar", Gtk.ResponseType.NO);
            this.bar.add_button("Cancelar", Gtk.ResponseType.CANCEL);
            this.bar.set_message_type(Gtk.MessageType.QUESTION);
            this.bar.set_show_close_button(false);
            this.bar.response.connect(this.response_cb);
            this.add(this.bar);

            Gtk.Container content = this.bar.get_content_area();
            this.message_label = new Gtk.Label(null);
            content.add(this.message_label);
        }

        private void response_cb(Gtk.InfoBar bar, int response) {
            switch (response) {
                case Gtk.ResponseType.YES:
                    this.save(this.tab);
                    break;

                case Gtk.ResponseType.NO:
                    this.dont_save(this.tab);
                    break;

                case Gtk.ResponseType.CANCEL:
                    break;
            }

            this.set_reveal_child(false);
            this.tab = null;
        }

        public void show_for_tab(Noxer.NotebookTab tab) {
            this.tab = tab;
            this.message_label.set_text(@"¿Desea guardar los cambios de '$(tab.get_title())' antes de cerrarlo?");
            this.set_reveal_child(true);
        }
    }
}