lessThan(QT_VERSION, 4.6) {
	error("FocusWriter requires Qt 4.6 or greater")
}

TEMPLATE = app
QT += network
greaterThan(QT_MAJOR_VERSION, 4) {
	QT += widgets printsupport
}
CONFIG += warn_on
macx {
	QMAKE_INFO_PLIST = resources/mac/Info.plist
}

!win32 {
	LIBS += -lz
}

VERSION = $$system(git rev-parse --short HEAD)
isEmpty(VERSION) {
	VERSION = 0
}
DEFINES += VERSIONSTR=\\\"git.$${VERSION}\\\"

unix: !macx {
	TARGET = focuswriter
} else {
	TARGET = FocusWriter
}

macx {
	INCLUDEPATH += /Library/Frameworks/libzip.framework/Headers
	LIBS += -framework libzip -framework AppKit

	HEADERS += src/spelling/dictionary_provider_nsspellchecker.h

	OBJECTIVE_SOURCES += src/spelling/dictionary_provider_nsspellchecker.mm \
		src/nssound/sound.mm

	lessThan(QT_MAJOR_VERSION, 5) {
		HEADERS += src/rtf/clipboard_mac.h
		SOURCES += src/rtf/clipboard_mac.cpp
	}
} else:win32 {
	INCLUDEPATH += hunspell libzip
	LIBS += ./hunspell/hunspell1.dll ./libzip/libzip0.dll -lOle32

	HEADERS += src/spelling/dictionary_provider_hunspell.h \
		src/spelling/dictionary_provider_voikko.h

	SOURCES += src/spelling/dictionary_provider_hunspell.cpp \
		src/spelling/dictionary_provider_voikko.cpp \
		src/qsound/sound.cpp

	lessThan(QT_MAJOR_VERSION, 5) {
		HEADERS += src/rtf/clipboard_windows.h
		SOURCES += src/rtf/clipboard_windows.cpp
	}
} else {
	CONFIG += link_pkgconfig
	PKGCONFIG += hunspell libzip

	HEADERS += src/spelling/dictionary_provider_hunspell.h \
		src/spelling/dictionary_provider_voikko.h

	SOURCES += src/spelling/dictionary_provider_hunspell.cpp \
		src/spelling/dictionary_provider_voikko.cpp \
		src/sdl/sound.cpp
}

INCLUDEPATH += src src/qtsingleapplication src/spelling

HEADERS += src/action_manager.h \
	src/alert.h \
	src/alert_layer.h \
	src/application.h \
	src/block_stats.h \
	src/color_button.h \
	src/deltas.h \
	src/document.h \
	src/document_cache.h \
	src/document_watcher.h \
	src/document_writer.h \
	src/find_dialog.h \
	src/gzip.h \
	src/image_button.h \
	src/load_screen.h \
	src/locale_dialog.h \
	src/odt_reader.h \
	src/paths.h \
	src/preferences.h \
	src/preferences_dialog.h \
	src/scene_list.h \
	src/scene_model.h \
	src/session.h \
	src/session_manager.h \
	src/settings_file.h \
	src/shortcut_edit.h \
	src/smart_quotes.h \
	src/sound.h \
	src/stack.h \
	src/stats.h \
	src/symbols_dialog.h \
	src/symbols_model.h \
	src/theme.h \
	src/theme_dialog.h \
	src/theme_manager.h \
	src/timer.h \
	src/timer_display.h \
	src/timer_manager.h \
	src/window.h \
	src/qtsingleapplication/qtsingleapplication.h \
	src/qtsingleapplication/qtlocalpeer.h \
	src/rtf/reader.h \
	src/rtf/tokenizer.h \
	src/rtf/writer.h \
	src/spelling/abstract_dictionary.h \
	src/spelling/abstract_dictionary_provider.h \
	src/spelling/dictionary_manager.h \
	src/spelling/dictionary_ref.h \
	src/spelling/highlighter.h \
	src/spelling/spell_checker.h

SOURCES += src/action_manager.cpp \
	src/alert.cpp \
	src/alert_layer.cpp \
	src/application.cpp \
	src/block_stats.cpp \
	src/color_button.cpp \
	src/deltas.cpp \
	src/document.cpp \
	src/document_cache.cpp \
	src/document_watcher.cpp \
	src/document_writer.cpp \
	src/find_dialog.cpp \
	src/gzip.cpp \
	src/image_button.cpp \
	src/load_screen.cpp \
	src/locale_dialog.cpp \
	src/main.cpp \
	src/odt_reader.cpp \
	src/paths.cpp \
	src/preferences.cpp \
	src/preferences_dialog.cpp \
	src/scene_list.cpp \
	src/scene_model.cpp \
	src/session.cpp \
	src/session_manager.cpp \
	src/shortcut_edit.cpp \
	src/smart_quotes.cpp \
	src/stack.cpp \
	src/stats.cpp \
	src/symbols_dialog.cpp \
	src/symbols_model.cpp \
	src/theme.cpp \
	src/theme_dialog.cpp \
	src/theme_manager.cpp \
	src/timer.cpp \
	src/timer_display.cpp \
	src/timer_manager.cpp \
	src/window.cpp \
	src/qtsingleapplication/qtsingleapplication.cpp \
	src/qtsingleapplication/qtlocalpeer.cpp \
	src/rtf/reader.cpp \
	src/rtf/tokenizer.cpp \
	src/rtf/writer.cpp \
	src/spelling/dictionary_manager.cpp \
	src/spelling/dictionary_ref.cpp \
	src/spelling/highlighter.cpp \
	src/spelling/spell_checker.cpp

TRANSLATIONS = $$files(translations/focuswriter_*.ts)

RESOURCES = resources/images/images.qrc resources/images/icons/icons.qrc
macx {
	ICON = resources/mac/focuswriter.icns
}
win32 {
	RC_FILE = resources/windows/icon.rc
}

macx {
	ICONS.files = resources/images/icons/oxygen/hicolor
	ICONS.path = Contents/Resources/icons

	SOUNDS.files = resources/sounds
	SOUNDS.path = Contents/Resources

	SYMBOLS.files = resources/symbols/symbols510.dat
	SYMBOLS.path = Contents/Resources

	QMAKE_BUNDLE_DATA += ICONS SOUNDS SYMBOLS
}

unix: !macx {
	isEmpty(PREFIX) {
		PREFIX = /usr/local
	}
	isEmpty(BINDIR) {
		BINDIR = $$PREFIX/bin
	}
	isEmpty(DATADIR) {
		DATADIR = $$PREFIX/share
	}
	DEFINES += DATADIR=\\\"$${DATADIR}/focuswriter\\\"

	target.path = $$BINDIR

	icon.files = resources/images/icons/hicolor/*
	icon.path = $$DATADIR/icons/hicolor

	pixmap.files = resources/unix/focuswriter.xpm
	pixmap.path = $$DATADIR/pixmaps

	icons.files = resources/images/icons/oxygen/hicolor/*
	icons.path = $$DATADIR/focuswriter/icons/hicolor

	desktop.files = resources/unix/focuswriter.desktop
	desktop.path = $$DATADIR/applications/

	qm.files = translations/*.qm
	qm.path = $$DATADIR/focuswriter/translations

	sounds.files = resources/sounds/*
	sounds.path = $$DATADIR/focuswriter/sounds

	greaterThan(QT_MAJOR_VERSION, 4) {
		symbols.files = resources/symbols/symbols620.dat
	} else {
		symbols.files = resources/symbols/symbols510.dat
	}
	symbols.path = $$DATADIR/focuswriter

	INSTALLS += target icon pixmap desktop icons qm sounds symbols
}
