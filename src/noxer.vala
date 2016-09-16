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

public class NoxerApp: Gtk.Application {

    public GLib.List<Noxer.Window> windows;
    public GLib.File file;

    public Noxer.Settings settings;

    public NoxerApp(string path) {
        GLib.Object(application_id: "org.desktop.noxer");
        this.file = GLib.File.new_for_commandline_arg(path);
    }

    protected override void activate() {
        this.windows = new GLib.List<Noxer.Window>();
        this.make_actions();

        this.settings = new Noxer.Settings();

        Gtk.Settings.get_default().set("gtk-application-prefer-dark-theme", true);
        this.new_window();
    }

    private void make_actions() {
        GLib.SimpleAction action = new GLib.SimpleAction("new-tab", null);
        action.activate.connect(this.new_tab);
        this.set_accels_for_action("app.new-tab", { "<Primary>T" });
        this.add_action(action);

        action = new GLib.SimpleAction("new-window", null);
        action.activate.connect(this.new_window);
        this.set_accels_for_action("app.new-window", { "<Primary>N" });
        this.add_action(action);

        action = new GLib.SimpleAction("toggle-searchbar", null);
        action.activate.connect(this.toggle_searchbar);
        this.set_accels_for_action("app.toggle-searchbar", { "<Primary>F" });
        this.add_action(action);

        action = new GLib.SimpleAction("close-tab", null);
        action.activate.connect(this.close_tab);
        this.set_accels_for_action("app.close-tab", { "<Primary>W" });
        this.add_action(action);

        action = new GLib.SimpleAction("save", null);
        action.activate.connect(this.save);
        this.set_accels_for_action("app.save", { "<Primary>S" });
        this.add_action(action);

        action = new GLib.SimpleAction("save-as", null);
        action.activate.connect(this.save_as);
        this.set_accels_for_action("app.save-as", { "<Primary><Shift>S" });
        this.add_action(action);

        action = new GLib.SimpleAction("open", null);
        action.activate.connect(this.open);
        this.set_accels_for_action("app.open", { "<Primary>O" });
        this.add_action(action);
    }

    public Noxer.Window get_current_window() {
        Gtk.Window win = this.get_active_window();
        return (win as Noxer.Window);
    }

    public Noxer.BaseView? get_current_view() {
        Noxer.Window win = this.get_current_window();
        return win.get_current_view();
    }

    public void new_tab(GLib.Variant? variant=null) {
        Noxer.Window win = this.get_current_window();
        win.new_file();
    }

    public void new_window(GLib.Variant? variant=null) {
        Noxer.Window win = new Noxer.Window();
        win.set_application(this);
        this.windows.append(win);

        win.show_all();
    }

    public void toggle_searchbar(GLib.Variant? variant=null) {
        Noxer.BaseView view = this.get_current_view();

        if (view != null && view.type == Noxer.ViewType.NORMAL) {
            Noxer.EditView editview = (view as Noxer.EditView);
            editview.toggle_searchbar();
        }
    }

    public void close_tab(GLib.Variant? variant=null) {
        Noxer.Window win = this.get_current_window();
        win.close_current_tab();
    }

    public void save(GLib.Variant? variant=null) {
        Noxer.Window win = this.get_current_window();
        win.save();
    }

    public void save_as(GLib.Variant? variant=null) {
        Noxer.Window win = this.get_current_window();
        win.save(true);
    }

    public new void open(GLib.Variant? variant=null) {
        Noxer.Window win = this.get_current_window();
        win.open_filechooser_open();
    }
}

void main(string[] args) {
    var noxer = new NoxerApp(args[0]);
    noxer.run();
}
