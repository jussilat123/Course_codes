#include "fingridservice.h"

FingridService::FingridService(QObject *parent):
    QObject(parent),
    manager(new QNetworkAccessManager(this))
{
}

QVariantList FingridService::getTimeseries(const QString &param, const QDateTime &begin, const QDateTime &end) const
{
    const QUrl url = parseURL(param, begin, end);
    QByteArray response = get(url);
    QJsonArray json = QJsonDocument::fromJson(response).array();
    return toTimeSeries(json);
}

QVariantList FingridService::getParameters(QString option) const
{
    if (option == "production_parameters"){
        return QVariant(production_params.keys()).toList();
    } else if (option == "production_words"){
        return QVariant(production_params.values()).toList();
    } else {
        return QVariant(params.keys()).toList();
    }
}

const QByteArray FingridService::get(const QUrl& url) const
{
    QNetworkRequest req(url);
    req.setRawHeader(QByteArray("x-api-key"), QByteArray(apikey));
    auto result = manager->get(req);

    // Wait for the request to finish
    QEventLoop loop;
    connect(result, SIGNAL(finished()), &loop, SLOT(quit()));
    loop.exec();

    qint32 httpStatusCode = result->attribute(
                QNetworkRequest::HttpStatusCodeAttribute).toInt();

    if (httpStatusCode >= 200 && httpStatusCode < 300) // OK
    {
        return result->readAll();
    } else {
        QString errorMsg;
        errorMsg += QString::number(httpStatusCode) + ", "
            + result->attribute(
                    QNetworkRequest::HttpReasonPhraseAttribute).toString();
        emit error(errorMsg);
        return "";
    }
}

QVariantList FingridService::toTimeSeries(const QJsonArray &json) const
{
    QVariantList result;
    for (const QJsonValue &value : json){
        QJsonObject object = value.toObject();
        double val = object.value("value").toDouble();
        QDateTime time = QDateTime::fromString(object.value("end_time").toString(),
                                               Qt::ISODate);
        QVariantMap pair;
            pair.insert("time", time);
            pair.insert("value", val);
        result << pair;
    }
    return result;
}

QUrl FingridService::parseURL(const QString &param, const QDateTime &begin,
                              const QDateTime &end) const
{
    QString parameter = params[param];
    QString baseURL = "https://api.fingrid.fi/v1/variable/"
                      + parameter + "/events/json?";
    QString begin_str = begin.toString(Qt::ISODate) + "Z";
    QString end_str = end.toString(Qt::ISODate) + "Z";

    QStringList names = {"start_time", "end_time"};
    QStringList params = {begin_str, end_str};
    //combining parameters into url
    for(int i = 0; i < names.length(); i++){
        baseURL += names[i] + '=' + params[i];
        if (names.length() - i > 1){
            baseURL += "&";
        }
    }
    return baseURL;
}
