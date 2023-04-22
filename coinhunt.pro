QT += quick

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    bugmodel.cpp \
    common-library/gamedata.cpp \
    common-library/mouse_event_filter.cpp \
    common-library/player.cpp \
    common-library/player_tablemodel.cpp \
    main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH += $$PWD

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES +=

include ($$PWD/QJoysticks/QJoysticks.pri)

HEADERS += \
    bugmodel.h \
    common-library/gamedata.h \
    common-library/mouse_event_filter.h \
    common-library/player.h \
    common-library/player_tablemodel.h

QMAKE_POST_LINK += $$QMAKE_COPY_DIR $$shell_path($$PWD/common-media/gif) $$shell_path($$OUT_PWD/);
QMAKE_POST_LINK += $$QMAKE_COPY_DIR $$shell_path($$PWD/media/bg) $$shell_path($$OUT_PWD/);
