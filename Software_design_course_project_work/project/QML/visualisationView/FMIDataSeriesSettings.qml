import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../"
import "../../utils.js" as Utils

ColumnLayout {
    readonly property var getData:()=>DataService.getTimeseries("fmi",
                                                               parameterSelector.currentText,
                                                                begin.date, end.date,placeScelector.value)
    TextInputBox {
        id: placeScelector
        label: "Place:"
        value: "Hervanta"
    }

    RowLayout {
        Text {
            id: label
            text: "Value: "
        }
        ComboBox {
            Layout.fillWidth: true
            id: parameterSelector
            model: {
                if (DataService)
                    DataService.getParameters("fmi");
            }
        }
    }

    RowLayout {
        Text {
            Layout.fillWidth: true
            text: "Begin: "
        }
        DateTimePicker {
            id: begin
            date: Utils.yesterday()
        }
    }

    RowLayout {
        Text {
            Layout.fillWidth: true
            text: "End: "
        }
        DateTimePicker {
            id: end
            date: new Date
        }
    }
}
