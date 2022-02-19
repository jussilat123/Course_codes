#include "fmiservice.h"

FMIService::FMIService(QObject *parent):
    QObject(parent),
    manager(new QNetworkAccessManager(this))
{

}

QVariantList FMIService::getTimeseries(const QString &place,
                                       const QString &param,
                                       const QDateTime &starttime,
                                       const QDateTime &endtime) const
{
    const QUrl url = parseURL(place, param, starttime, endtime);
    QByteArray res = get(url);
    if (res.isEmpty()) {
        // Network error occured
        return QVariantList();
    }
    QVariantList result = toTimeSeries(res);
    if (result.isEmpty()){
        emit error("For some reason requested data is not available");
    }
    return result;
}

QVariantList FMIService::getParameters(QString option) const
{
    (void)option; //unused parameter currently.
    return QVariant(params.keys()).toList();
}

QUrl FMIService::parseURL(const QString &place, const QString &param,
                          const QDateTime &starttime,
                          const QDateTime &endtime) const
{
    QString parameter = params[param];

    //Build baseurl
    std::string param_str = parameter.toStdString();
    QString result = getBaseURL(param_str);

    //Convert starttime and endtime into string
    QString startdate_str = starttime.toString(Qt::ISODateWithMs);
    QString enddate_str = endtime.toString(Qt::ISODateWithMs);

    //combining parameters into url
    QStringList names = {"place", "starttime", "endtime", "parameters"};
    QStringList params = {place, startdate_str, enddate_str, parameter};

    for(int i = 0; i < names.length(); i++){
        result +='&'+names[i]+'='+params[i];
    }

    return result;
}

QString FMIService::getBaseURL(std::string param) const
{
    QString baseURL = "http://opendata.fmi.fi/wfs?service=WFS&version=2.0.0&"
                        "request=getFeature&storedquery_id=";

    QString observedStoredQueryId = "fmi::observations::weather::simple";
    QString predictionStrodedQueryID = "fmi::forecast::hirlam::surface::point::simple";
    QString observedStoredMonthlyQueryID = "fmi::observations::weather::monthly::simple";
    QString observedStoredDailyQueryID = "fmi::observations::weather::daily::simple";

    //Forecast params
    std::set<std::string> forecast_params = {"temperature", "windspeedms"};
    //Daily observation params
    std::set<std::string> daily_observation_params = {"tmin", "tmax", "tday"};

    //Checks which query is wanted and returns base url
    if(forecast_params.find(param) != forecast_params.end()){
        QString result = baseURL + predictionStrodedQueryID;
        return result;
    } else if(daily_observation_params.find(param) != daily_observation_params.end()){
        QString result = baseURL + observedStoredDailyQueryID;
        return result;
    } else if(param == "tmon"){ // Monthly parameter
        QString result = baseURL + observedStoredMonthlyQueryID;
        return result;
    } else {
        QString result = baseURL + observedStoredQueryId;
        return result;
    }
}

const QByteArray FMIService::get(const QUrl &url) const
{
    QNetworkRequest req(url);
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
            + result->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();
        emit error(errorMsg);
        return "";
    }
}

QVariantList FMIService::toTimeSeries(QByteArray &xml) const
{
    if (xml.isEmpty())
        return QVariantList();

    QBuffer buffer(&xml);
    buffer.open(QIODevice::ReadOnly);
    QXmlQuery query;
    query.bindVariable("xml", &buffer);
    query.setFocus(&buffer);

    query.setQuery("//*:BsWfsElement/*:Time/string()");
    QStringList times;
    query.evaluateTo(&times);

    query.setQuery("//*:BsWfsElement/*:ParameterValue/string()");
    QStringList values;
    query.evaluateTo(&values);

    QVariantList result;
    for (int i = 0; i < values.size(); i++){
        bool ok = false;
        double val = values[i].toDouble(&ok);
        QDateTime time = QDateTime::fromString(times[i], Qt::ISODate);
        if (ok && time.isValid() && (isnormal(val)||val == 0)){
            QVariantMap pair;
                pair.insert("time", time);
                pair.insert("value", val);
            result << pair;
        }
    }
    return result;
}
