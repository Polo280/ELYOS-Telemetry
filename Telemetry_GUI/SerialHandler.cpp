#include "Headers/SerialHandler.h"

// Constructor
SerialHandler::SerialHandler(QObject *parent)
    : QObject{parent}
{
    connect(serialPort, &QSerialPort::errorOccurred, this, &SerialHandler::handleError);
    connect(serialPort, &QSerialPort::readyRead, this, &SerialHandler::readLine);

    // Initialize buffer
    data = new QByteArray();
}

// Destructor
SerialHandler::~SerialHandler(void)
{
    delete(serialPort);
    delete(data);
}

// SLOTS
// Whenever QserialPort::errorOccurred event is raised, get the error and emit as a signal which contains the message
void SerialHandler::handleError(void){
    QString errorMessage = serialPort->errorString();
    emit errorOccurred(errorMessage);
}

// Handles incoming data and emits a signal containing it in QString format
void SerialHandler::readLine(){
    if(this->checkReadLine()){
        QString message = QString::fromUtf8(*data);
        if(message.length() > 10){
           emit newDataReceived(message);
        }
        data->clear();
    }
}

void SerialHandler::setBaudRate(int baud_rate){
    serialPort->setBaudRate(baud_rate);
}

void SerialHandler::setPort(QString port_name){
    serialPort->setPortName(port_name);
}

// Configuring function
void SerialHandler::configurePort(QString baudRate, const QString portName){
    serialPort->setBaudRate(baudRates[baudRate]);
    serialPort->setPortName(portName);
}

// Open port
void SerialHandler::openPort(int mode){
    if(serialPort->open(serialMode[mode])){
        emit connected();
    }else{
        emit errorOccurred(serialPort->errorString());
    }
}

// Check if a new message could be retrieved
bool SerialHandler::checkReadLine(void){
    data->append(serialPort->readAll());
    return (data->contains("\n"))? true : false;
}

// View if serial communication is currently active
bool SerialHandler::isConnected(void){
    return serialPort->isOpen();
}

// Close port and emit onDisconnected signal
void SerialHandler::closePort(void){
    if(serialPort->isOpen()){
        serialPort->close();
        emit disconnected();
    }
}

// Get available COM ports
QVariantList SerialHandler::getAvailablePorts(void){
    QVariantList ports;
    const auto infos = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : infos) {
        QVariantMap port;
        port["name"] = info.portName();
        port["description"] = info.description();
        port["manufacturer"] = info.manufacturer();
        ports.append(port);
    }
    return ports;
}
