VALAC = valac

PKG = --pkg gtk+-3.0 \
      --pkg gtksourceview-3.0

SRC = src/noxer.vala \
      src/window.vala \
      src/headerbar.vala \
      src/editbox.vala \
      src/baseview.vala \
      src/editview.vala \
      src/settingsview.vala \
      src/lateral_panel.vala \
      src/globals.vala \
      src/utils.vala \
      src/settings.vala \
      src/filechooser.vala \
      src/infobar.vala

OPTIONS = -X -w

BIN = noxer

all:
	$(VALAC) $(PKG) $(SRC) $(OPTIONS) -o $(BIN)
