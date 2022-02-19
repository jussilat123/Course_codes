#ifndef FMISERVICE_H
#define FMISERVICE_H

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

#include <QEventLoop>
#include <QDateTime>
#include <QVariant>
#include <QMap>
#include <QXmlQuery>
#include <QBuffer>
#include <set>
#include <math.h>

class FMIService : public QObject
{
    Q_OBJECT
public:
    explicit FMIService(QObject *parent = nullptr);

    /*!
     * \brief getTimeseries Gets requested timeseries from FMI api.
     * \param place, Requested position where FMI data was collected
     * \param param Requested parameter. Must be in getParameters()
     * \param starttime Begin time of the timeseries
     * \param endtime End time of the timeseries
     * \return QVariantList containing QVariantMaps. Each list element has two
     *  key-value pairs. "time" contains the time value for timeseries entry as
     *  QDateTime. "value" contains the value for timeseries entry as double.
     */
     Q_INVOKABLE QVariantList getTimeseries(const QString &place,
                                           const QString &param,
                                           const QDateTime &starttime,
                                           const QDateTime &endtime) const;

    /*!
     * \brief getParameters Returns requestable parameters
     * \return List of requestable parameters
     */
    QVariantList getParameters(QString option = "default") const;

private:
    /*!
     * \brief parseURL Returns url for a request to FMI API
     * \param place
     * \param param
     * \param starttime
     * \param endtime
     * \return
     */
    QUrl parseURL(const QString &place, const QString &param,
                  const QDateTime &starttime, const QDateTime& endtime) const;

    /*!
     * \brief getBaseURL returns baseurl for FMI API query
     * \param param
     * \return baseurl
     */
    QString getBaseURL(std::string param) const;

    /*!
     * \brief get Makes get request to given url.
     * \param url
     * \return Result of the request. If request failed, returns empty
     */
    const QByteArray get(const QUrl &url) const;

    QNetworkAccessManager *manager;

    // Conversion table for request parameters between FMI API and this class'
    // interface
    const QMap<QString, QString> params = {
        {"Observed monthly average temperature (C°)","tmon"},
        {"Observed temperature with 10 min timestep (C°)", "t2m"},
        {"Observed wind with 10 min timestep (m/s)", "ws_10min"},
        {"Observed cloudiness with 10 min timestep (okta)", "n_man"},
        {"Predicted temperature (C°)", "temperature"},
        {"Predicted wind (m/s)", "windspeedms"},
        {"Hourly average temperature (C°)","TA_PT1M_AVG"},
        {"Hourly maximum temperature (C°)","TA_PT1H_MAX"},
        {"Hourly minimum temperature (C°)","TA_PT1H_MIN"},
        {"Daily average temperature (C°)", "tday"},
        {"Daily minimum temperature (C°)", "tmin"},
        {"Daily maximum  temperature (C°)", "tmax"},
    };

    /*!
     * \brief toTimeSeries Converts XML returned by FMI api to timeseries.
     * \param xml
     * \return \return QVariantList containing QVariantMaps. Each list element has two
     *  key-value pairs. "time" contains the time value for timeseries entry as
     *  QDateTime. "value" contains the value for timeseries entry as double.
     */
    QVariantList toTimeSeries(QByteArray &xml) const;

signals:
    void error(const QString &errorMsg) const;

};

#endif // FMISERVICE_H
