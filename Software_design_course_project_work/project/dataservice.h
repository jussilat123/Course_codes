#ifndef DATASERVICE_H
#define DATASERVICE_H

#include "fingridservice.h"
#include "fmiservice.h"


class DataService : public QObject
{
    Q_OBJECT
public:
    explicit DataService(QObject *parent = nullptr);

    /*!
     * \brief getTimeseries Gets timeseries data from Fingrid or FMI api.
     * \param dataservice, Requested API data. Current options are fmi and fingrid.
     * \param place, Requested position where FMI data was collected
     * \param param Requested parameter. Must be in getParameters()
     * \param begin Begin time of the timeseries
     * \param end End time of the timeseries
     * \return QVariantList containing QVariantMaps. Each list element has two
     *  key-value pairs. "time" contains the time value for timeseries entry as
     *  QDateTime. "value" contains the value for timeseries entry as double.
     */
    Q_INVOKABLE QVariantList getTimeseries(const QString dataservice,
                                           const QString &param,
                                           const QDateTime &starttime,
                                           const QDateTime &endtime,
                                           const QString &place = "Hervanta") const;

    /*!
     * \brief getParameters Returns requestable parameters
     * \param dataservice, Requested API data. Current options are fmi and fingrid.
     * \param option, requested data. Default is all key values.
     * Current options are: production_parameters and production_words. Fmi data doesn't have currently options.
     * \return List of requestable parameters
     */
    Q_INVOKABLE QVariantList getParameters(QString dataservice,QString option = "default") const;

public slots:
    void error_msg(const QString &errorMsg) const;

signals:
    void error(const QString &errorMsg) const;

private:
    FMIService FMI;
    FingridService Fingrid;
};

#endif // DATASERVICE_H
