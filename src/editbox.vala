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

    public class NotebookTab: Gtk.Box {

        public signal void modified_changed(bool modified);
        public signal void title_changed(string title);
        public signal void close();

        public Gtk.Label label;
        public Gtk.Button button;
        public Gtk.Menu menu;
        public Gtk.Label modified_label;

        public Noxer.BaseView view;

        private bool modified = false;

        public NotebookTab() {
            this.set_orientation(Gtk.Orientation.HORIZONTAL);
            this.set_size_request(150, 1);

            this.label = new Gtk.Label("Sin guardar");
            this.label.set_ellipsize(Pango.EllipsizeMode.END);
            this.pack_start(this.label, false, false, 0);

            this.button = new Gtk.Button.from_icon_name("window-close", Gtk.IconSize.MENU);
            this.button.set_relief(Gtk.ReliefStyle.NONE);
            this.button.clicked.connect(() => { this.close(); });
            this.pack_end(this.button, false, false, 0);

            this.modified_label = new Gtk.Label("•");
            this.modified_label.set_use_markup(true);

            this.show_all();
        }

        public void set_title(string title) {
            this.label.set_text(title);
            this.set_tooltip_text(title);  // For when the title is very large
            this.title_changed(title);
        }

        public string get_title() {
            return this.label.get_text();
        }

        public void set_view(Noxer.BaseView view) {
            this.view = view;

            if (this.view.type == Noxer.ViewType.SETTINGS) {
                this.set_title("Configuraciones");
            }
        }

        public Noxer.BaseView get_view() {
            return this.view;
        }

        public bool get_modified() {
            return this.modified;
        }

        public void set_modified(bool modified) {
            if (modified) {
                this.pack_end(this.modified_label, false, false, 0);
                this.show_all();
            } else {
                this.remove(this.modified_label);
            }

            this.modified = modified;
            this.modified_changed(modified);
        }

        public void disappear() {
            this.view.forall((element) => this.view.remove(element));
            this.view.destroy();

            this.forall((element) => this.remove(element));
            this.destroy();
        }
    }

    public class NotebookActionBox: Gtk.Box {

        public signal void new_tab();

        public NotebookActionBox() {
            this.set_orientation(Gtk.Orientation.HORIZONTAL);

            Gtk.Button button = new Gtk.Button.from_icon_name("list-add", Gtk.IconSize.MENU);
            button.set_relief(Gtk.ReliefStyle.NONE);
            button.clicked.connect(() => { this.new_tab(); });
            this.pack_start(button, false, false, 0);
        }
    }

    public class EditBox: Gtk.Box {

        public signal void update_headerbar(Noxer.NotebookTab? tab);

        public Gtk.Notebook notebook;
        public Noxer.InfoBar infobar;
        public Noxer.HeaderBar headerbar;

        Noxer.BaseView[] views;

        public EditBox() {
            this.set_orientation(Gtk.Orientation.VERTICAL);

            this.views = { };

            this.infobar = new Noxer.InfoBar();
            this.infobar.save.connect(this.save_and_close);
            this.infobar.dont_save.connect(this.force_close);
            this.pack_start(this.infobar, false, false, 0);

            this.notebook = new Gtk.Notebook();
            this.notebook.set_scrollable(true);
            this.notebook.switch_page.connect(this.switch_page_cb);
            this.notebook.page_removed.connect(this.page_removed_cb);
            this.pack_start(this.notebook, true, true, 0);

            Noxer.NotebookActionBox abox = new Noxer.NotebookActionBox();
            abox.new_tab.connect(() => { this.new_file(); });
            this.notebook.set_action_widget(abox, Gtk.PackType.END);
            abox.show_all();

            this.show_all();
        }

        private void add_view(Noxer.BaseView view) {
            Noxer.NotebookTab tab = new Noxer.NotebookTab();
            tab.modified_changed.connect(this.modified_tab_cb);
            tab.title_changed.connect(this.title_tab_changed_cb);
            tab.close.connect(this.close_tab_cb);

            view.set_tab(tab);

            this.notebook.append_page(view, tab);
            this.notebook.set_tab_reorderable(view, true);
            this.show_all();

            this.notebook.set_current_page(this.notebook.get_n_pages() - 1);

            this.views += view;
        }

        private void switch_page_cb(Gtk.Widget widget, uint page) {
            Noxer.BaseView view = (widget as Noxer.BaseView);
            this.update_headerbar(view.tab);
        }

        private void page_removed_cb(Gtk.Widget widget, uint page) {
            if (this.notebook.get_n_pages() == 0) {
                this.update_headerbar(null);
            }
        }

        private void modified_tab_cb(Noxer.NotebookTab tab, bool modified) {
            Noxer.BaseView view = tab.view;

            if (view == this.get_current_view()) {
                this.update_headerbar(tab);
            }
        }

        private void title_tab_changed_cb(Noxer.NotebookTab tab, string title) {
            Noxer.BaseView view = tab.view;

            if (view == this.get_current_view()) {
                this.update_headerbar(tab);
            }
        }

        private void close_tab_cb(Noxer.NotebookTab tab) {
            this.try_close_tab(tab);
        }

        private void save_and_close(Noxer.InfoBar infobar, Noxer.NotebookTab tab) {
            // TODO
        }

        private void force_close(Noxer.InfoBar infobar, Noxer.NotebookTab tab) {
            this.try_close_tab(tab, true);
        }

        public Noxer.BaseView? get_current_view() {
            return this.get_view_at_index(this.notebook.get_current_page());
        }

        public Noxer.BaseView? get_view_at_index(int index) {
            if (this.notebook.get_n_pages() > 0) {
                Gtk.Widget widget = this.notebook.get_nth_page(index);
                return (widget as Noxer.BaseView);
            }

            return null;
        }

        public int? get_view_index(Noxer.BaseView view) {
            int i = 0;
            foreach (Noxer.BaseView bview in this.views) {
                if (bview == view) {
                    return i;
                }

                i ++;
            }

            return null;
        }

        public void new_file(string? file = null) {
            if (file != null) {
                Noxer.BaseView? bview = this.get_current_view();
                if (bview != null && bview.type == Noxer.ViewType.NORMAL) {
                    Noxer.EditView editview = (bview as Noxer.EditView);

                    if (editview.file == null && !editview.get_modified()) {
                        editview.open(file);
                        return;
                    }
                }

                foreach (Noxer.BaseView baseview in this.views) {
                    if (baseview.type == Noxer.ViewType.NORMAL) {
                        Noxer.EditView editview = (baseview as Noxer.EditView);

                        if (editview.file == file) {
                            this.notebook.set_current_page(this.get_view_index(baseview));
                            return;
                        }
                    }
                }
            }

            // If all else fails
            Noxer.EditView view = new Noxer.EditView();
            this.add_view(view);

            if (file != null) {
                view.open(file);  // Need define tab first
            }
        }

        public void show_settings() {
            foreach (Noxer.BaseView view in this.views) {
                if (view.type == Noxer.ViewType.SETTINGS) {
                    this.notebook.set_current_page(this.get_view_index(view));
                    return;
                }
            }

            Noxer.SettingsView view = new Noxer.SettingsView();
            this.add_view(view);
        }

        public void try_close_tab(Noxer.NotebookTab tab, bool force = false) {
            if (!force && tab.view.type == Noxer.ViewType.NORMAL) {
                Noxer.EditView eview = (tab.view as Noxer.EditView);
                if (eview.get_modified()) {
                    this.infobar.show_for_tab(tab);
                    this.notebook.set_current_page(this.get_view_index(tab.view));
                    return;
                }
            }

            this.notebook.remove(tab.view);

            Noxer.BaseView[] views = { };
            foreach (Noxer.BaseView view in this.views) {
                if (view != tab.view) {
                    views += view;
                }
            }

            this.views = views;
            tab.disappear();
        }

        public void try_close_current_tab() {
            Noxer.BaseView? view = this.get_current_view();
            if (view != null) {
                this.try_close_tab(view.get_tab());
            }
        }
    }
}