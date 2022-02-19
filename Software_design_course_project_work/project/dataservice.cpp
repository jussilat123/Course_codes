#include "dataservice.h"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
/*DataService::DataService()
{

}*/


DataService::DataService(QObject *parent):
    QObject(parent)
{
    connect(&FMI,SIGNAL(error(const QString)),this,SLOT(error_msg(const QString)));
    connect(&Fingrid,SIGNAL(error(const QString)),this,SLOT(error_msg(const QString)));
}

QVariantList DataService::getTimeseries(const QString dataservice, const QString &param, const QDateTime &starttime, const QDateTime &endtime, const QString &place) const
{
    if (dataservice == "fmi"){
        return FMI.getTimeseries(place,param,starttime,endtime);
    } else if (dataservice == "fingrid") {
        return Fingrid.getTimeseries(param,starttime,endtime);
    } else {
        emit error("Requested dataservice doesn't exist");
        return {};
    }
}

QVariantList DataService::getParameters(QString dataservice, QString option) const
{
    if (dataservice == "fmi"){
        return FMI.getParameters(option);
    } else if (dataservice == "fingrid"){
        return Fingrid.getParameters(option);
    } else {
        emit error("Requested dataservice doesn't exist");
        return {};
    }
}

void DataService::error_msg(const QString &errorMsg) const
{
    emit error(errorMsg);
}


