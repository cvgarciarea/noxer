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
    
    public class BaseView: Gtk.Box {

        public Gtk.ScrolledWindow scroll;
        public Noxer.View view;
        public Noxer.NotebookTab tab;

        public Noxer.ViewType type = Noxer.ViewType.BASE;

        public BaseView() {
            this.set_orientation(Gtk.Orientation.VERTICAL);

            this.scroll = new Gtk.ScrolledWindow(null, null);
            this.pack_start(this.scroll, true, true, 0);

            this.show_all();
        }

        public void set_tab(Noxer.NotebookTab tab) {
            this.tab = tab;
            this.tab.set_view(this);
        }

        public Noxer.NotebookTab get_tab() {
            return this.tab;
        }
    }
}