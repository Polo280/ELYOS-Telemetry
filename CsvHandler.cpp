#include "Headers/CsvHandler.hpp"

CsvHandler::CsvHandler(QObject *parent) : QObject(parent), file_manager(nullptr), writer(nullptr) {}

CsvHandler::~CsvHandler() {
    if (file_manager && file_manager->isOpen()) {
        file_manager->close();
        emit csvFileClosed();
    }
    delete writer;
    delete file_manager;
}

void CsvHandler::openCsv(QString path){
    // Create new file manager with the provided filesystem path
    this->file_manager = new QFile(path);
    // Validate file path
    if(!this->file_manager->open(QIODevice::WriteOnly | QIODevice::Text)){
        emit csvOpenFailure(this->file_manager->errorString());
        return;
    }
    // Success openning file
    emit csvOpenSuccess();

    // Associate writer with file manager
    this->writer = new QTextStream(this->file_manager);
    *this->writer << "Hello\n";
}

void CsvHandler::csvWrite(){
    return;
}

void CsvHandler::handleError(){
    return;
}
