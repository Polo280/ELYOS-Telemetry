#include <QApplication>
#include <QQmlApplicationEngine>
#include "Headers/radialbar.h"
#include "Headers/SerialHandler.h"
#include "Headers/CsvHandler.hpp"

static QObject *serialHandlerSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new SerialHandler();
}

static QObject *csvHandlerSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine) {
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new CsvHandler();
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/Telemetry2/Main.qml"_qs);

    // Radial bar widget
    qmlRegisterType<RadialBar>("CustomControls", 1, 0, "RadialBar");
    // Serial handler component (a single instance in all the project)
    qmlRegisterSingletonType<SerialHandler>("SerialHandler", 1, 0, "SerialHandler", serialHandlerSingletonProvider);
    qmlRegisterSingletonType<CsvHandler>("CsvHandler", 1, 0, "CsvHandler", csvHandlerSingletonProvider);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
