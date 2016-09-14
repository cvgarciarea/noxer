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

    public class Settings: GLib.Object {

        private bool _use_dark_theme = true;
        private bool _show_grid = false;
        private bool _show_line_numbers = true;
        private bool _show_right_marging = false;
        private bool _show_map = true;
        private bool _use_spaces = true;
        private bool _smart_backspace = true;
        private bool _auto_indent = true;
        private bool _indent_on_tab = true;

        private int _right_margin_position = 80;
        private int _tab_width = 4;

        private string _font_family = "Monospace 11";

        public Settings() {
        }

        public void load_settings() {
        }

        public bool use_dark_theme {
            set {
                this._use_dark_theme = value;
            } get {
                return this._use_dark_theme;
            }
        }

        public bool show_grid {
            set {
                this._show_grid = value;
            } get {
                return this._show_grid;
            }
        }

        public bool show_line_numbers {
            set {
                this._show_line_numbers = value;
            } get {
                return this._show_line_numbers;
            }
        }

        public bool show_right_marging {
            set {
                this._show_right_marging = value;
            } get {
                return this._show_right_marging;
            }
        }

        public bool show_map {
            set {
                this._show_map = value;
            } get {
                return this._show_map;
            }
        }

        public bool use_spaces {
            set {
                this._use_spaces = value;
            } get {
                return this._use_spaces;
            }
        }

        public bool smart_backspace {
            set {
                this._smart_backspace = value;
            } get {
                return this._smart_backspace;
            }
        }

        public bool auto_indent {
            set {
                this._auto_indent = value;
            } get {
                return this._smart_backspace;
            }
        }

        public bool indent_on_tab {
            set {
                this._indent_on_tab = value;
            } get {
                return this._indent_on_tab;
            }
        }

        public int right_margin_position {
            set {
                this._right_margin_position = value;
            } get {
                return this._right_margin_position;
            }
        }

        public int tab_width {
            set {
                this._tab_width = value;
            } get {
                return this._tab_width;
            }
        }

        public string font_family {
            set {
                this._font_family = value;
            } get {
                return this._font_family;
            }
        }
    }
}