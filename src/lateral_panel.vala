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

    public class FilesTab: Gtk.ScrolledWindow {

        public FilesTab() {
        }
    }

    public class InstropectionTab: Gtk.Box {

        public InstropectionTab() {
        }
    }

    public class LateralPanel: Gtk.Box {

        public Gtk.Notebook notebook;
        public Noxer.FilesTab ftab;
        public Noxer.InstropectionTab itab;

        public LateralPanel() {
            this.set_orientation(Gtk.Orientation.VERTICAL);
            this.set_size_request(200, 1);

            this.notebook = new Gtk.Notebook();
            this.pack_start(this.notebook, true, true, 0);

            this.ftab = new Noxer.FilesTab();
            this.notebook.append_page(this.ftab, new Gtk.Label("Proyecto"));

            this.itab = new Noxer.InstropectionTab();
            this.notebook.append_page(this.itab, new Gtk.Label("Instropección"));
        }
    }
}