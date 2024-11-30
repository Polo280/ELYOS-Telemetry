#ifndef SERIALHANDLER_H
#define SERIALHANDLER_H

#include <QObject>
#include <QtSerialPort/QSerialPort>
#include <unordered_map>

#include <QSerialPortInfo>
#include <QVariantMap>

class SerialHandler : public QObject
{
    Q_OBJECT

public:
    // Constructor & destructor
    explicit SerialHandler(QObject *parent = nullptr);
    ~SerialHandler(void);

    // Serial configuration
    Q_INVOKABLE void setBaudRate(int);
    Q_INVOKABLE void setPort(QString);
    Q_INVOKABLE void configurePort(QString baudRate, const QString portName);

    // Serial open & close
    Q_INVOKABLE void openPort(int mode);
    Q_INVOKABLE void closePort();

    // Serial functionalities
    Q_INVOKABLE bool checkReadLine(void);

    // Modes
    enum SerialMode{
        READ_ONLY = 0,
        WRITE_ONLY  = 1,
        READ_WRITE = 2
    };

    // View info
    Q_INVOKABLE bool isConnected(void);
    // Get available COM ports
    Q_INVOKABLE QVariantList getAvailablePorts(void);

signals:
    void connected(void);
    void disconnected(void);
    void newDataReceived(QString message);
    void errorOccurred(QString errorMessage);

public slots:
    void handleError(void);
    void readLine(void);

private:
    // Auxiliar objects
    QSerialPort *serialPort = new QSerialPort;
    QSerialPortInfo *serialInfo;

    // Map to convert combobox string item to qint32 value
    std::unordered_map <QString, qint32> baudRates{
        {"1200", QSerialPort::Baud1200},
        {"2400", QSerialPort::Baud2400},
        {"4800", QSerialPort::Baud4800},
        {"9600", QSerialPort::Baud9600},
        {"19200", QSerialPort::Baud19200},
        {"38400", QSerialPort::Baud38400},
        {"57600", QSerialPort::Baud57600},
        {"115200", QSerialPort::Baud115200}
    };

    // Serial Modes  (0 = Read only, 1 = Write only, 2 = Read/Write
    std::unordered_map<int, QIODevice::OpenMode> serialMode{
        {0, QIODeviceBase::ReadOnly},
        {1, QIODeviceBase::WriteOnly},
        {2, QIODeviceBase::ReadWrite}
    };

    // Data read from serial
    QByteArray *data;

};

#endif // SERIALHANDLER_H
