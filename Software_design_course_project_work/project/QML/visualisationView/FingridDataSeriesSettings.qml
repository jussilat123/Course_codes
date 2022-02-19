import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import "../"
import "../../utils.js" as Utils

ColumnLayout {
    readonly property var getData: get

    QtObject {
       id: internal
       property var coef: 0
       property var units: [
           {
               text: "10^9 W",
               coef: 0.001
           },
           {
               text: "10^8 W",
               coef: 0.01
           },
           {
               text: "10^7 W",
               coef: 0.1
           },
           {
               text: "10^6 W",
               coef: 1
           },
        ]
    }

    RowLayout {
        Text {
            text: "Unit: "
        }
        ComboBox {
            id: unitSelector
             model: internal.units.map(pair=>pair.text);
             onCurrentTextChanged: {
                 var coef = internal.units.find(u => u.text === currentText).coef;
                 internal.coef = coef;
             }
        }
    }

    RowLayout {
        Text {
            id: label
            text: "Value: "
        }
        ComboBox {
            Layout.fillWidth: true
            id: parameterSelectorFingrid
            model: {
                if (DataService)
                    DataService.getParameters("fingrid")
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

    function get(){
        var data = DataService.getTimeseries("fingrid",parameterSelectorFingrid.currentText,
                                             begin.date, end.date)
        return data.map(d=>{return {time: d.time, value: d.value*internal.coef}})
    }
}
