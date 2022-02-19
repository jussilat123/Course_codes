#ifndef FINGRIDSERVICE_H
#define FINGRIDSERVICE_H

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

#include <QEventLoop>
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariant>

class FingridService :  public QObject
{
    Q_OBJECT

public:
    explicit FingridService(QObject *parent = nullptr);

    /*!
     * \brief getTimeseries Gets timeseries data from Fingrid api.
     * \param param Requested parameter. Must be in getParameters()
     * \param begin Begin time of the timeseries
     * \param end End time of the timeseries
     * \return QVariantList containing QVariantMaps. Each list element has two
     *  key-value pairs. "time" contains the time value for timeseries entry as
     *  QDateTime. "value" contains the value for timeseries entry as double.
     */
    QVariantList getTimeseries(const QString &param,
                                           const QDateTime &begin,
                                           const QDateTime &end) const;

    /*!
     * \brief getParameters Returns requestable parameters
     * \param option, requested data. Default is all key values.
     * Current options are: production_parameters and production_words
     * \return List of requestable parameters
     */
    QVariantList getParameters(QString option = "default") const;

private:
    /*!
     * \brief get Makes get request to given url. Header contains apikey for
     *  Fingrid api
     * \param url
     * \return Result of the request. If request failed, returns empty
     */
    const QByteArray get(const QUrl &url) const;

    /*!
     * \brief toTimeSeries Converts json returned by Fingrid api to timeseries.
     * \param json
     * \return \return QVariantList containing QVariantMaps. Each list element has two
     *  key-value pairs. "time" contains the time value for timeseries entry as
     *  QDateTime. "value" contains the value for timeseries entry as double.
     *  Uses megawatts as units for all values
     */
    QVariantList toTimeSeries(const QJsonArray &json) const;

    /*!
     * \brief parseURL Returns url for a request to Fingrid API based on parameters
     * \param param
     * \param starttime
     * \param endtime
     * \return
     */
     QUrl parseURL(const QString &param, const QDateTime &begin,
                  const QDateTime& end) const;

    QNetworkAccessManager *manager;
    const QByteArray apikey = "UxFOfGxRr48aQJxwdVZb17O88WoTlCIj1UzwkGQN";
    const QMap<QString, QString> params = {
        {"Electricity consumption - real time", "193"},
        {"Electricity consumption forecast - hourly", "166"},
        {"Nuclear power production - real time", "188"},
        {"Wind power production - real time", "181"},
        {"Wind power generation forecast - hourly", "245"},
        {"Hydro power production - real time", "191"},
        {"Solar power production - hourly","75"},
        {"Solar power generation forecast - hourly", "248"},
        {"Electricity production - real time", "192"},
        {"Electricity production forecast - hourly", "242"},
    };
    const QMap<QString, QString> production_params = {
        {"Nuclear power production - real time", "Nuclear"},
        {"Wind power production - real time", "Wind"},
        {"Hydro power production - real time", "Hydro"},
        {"Solar power production - hourly","Solar"},
        {"Electricity production - real time", "Total"},
    };
signals:
    void error(const QString &errorMsg) const;
};


#endif // FINGRIDSERVICE_H
