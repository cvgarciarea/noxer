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

    public NoxerApp get_app_instance() {
        GLib.Application app = GLib.Application.get_default();
        Gtk.Application gapp = (app as Gtk.Application);
        NoxerApp noxer = (gapp as NoxerApp);

        return noxer;
    }

    public Noxer.Settings get_settings() {
        NoxerApp noxer = Noxer.get_app_instance();
        return noxer.settings;
    }

    public string[] get_scheme_themes() {
        string[] themes = { };
        return themes;
    }
}