#ifndef CSVHANDLER_HPP
#define CSVHANDLER_HPP

#include <QObject>
#include <QFile>
#include <QTextStream>

class CsvHandler : public QObject {
Q_OBJECT

public:
    explicit CsvHandler(QObject *parent = nullptr);
    ~CsvHandler(void);

    Q_INVOKABLE void openCsv(QString path);
    Q_INVOKABLE void csvWrite(QString message);

signals:
    void csvOpenSuccess(void);
    void csvDataWritten(void);
    void csvFileClosed(void);
    void csvOpenFailure(QString error_msg);
    void csvError(QString error_msg);

public slots:
    void handleError(void);

private:
    QFile *file_manager;
    QTextStream *writer;
};

#endif // CSVHANDLER_HPP
