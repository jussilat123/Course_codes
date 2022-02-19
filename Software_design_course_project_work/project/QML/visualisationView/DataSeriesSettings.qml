import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../."

ColumnLayout {
    readonly property var getData: loader.item.getData
    property alias seriesName: seriesName.value
    QtObject {
       id: internal
       property var sources: [
           {
               text: "Finnish Meteorological Institute",
               component: "FMIDataSeriesSettings.qml"
           },
           {
               text: "Fingrid",
               component: "FingridDataSeriesSettings.qml"
           },
           {
               text: "Local files (Not implimented)",
               component: "LocalDataSeriesSettings.qml"
           }
        ]
    }

    RowLayout {
        TextInputBox {
            id: seriesName
            label: "Series name: "
        }
    }

    RowLayout {
        id: row
        Text {
            id: label
            text: "Source: "
        }
        ComboBox {
            Layout.fillWidth: true
            model: internal.sources.map(src=>src.text);
            onCurrentTextChanged: {
                var source = internal.sources.find(src => src.text === currentText);
                loader.source = source.component;
            }
        }
    }

    Loader {
        id: loader
    }
}
