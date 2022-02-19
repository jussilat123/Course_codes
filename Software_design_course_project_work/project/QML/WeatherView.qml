import QtQuick 2.0
import QtQuick.Layouts 1.15
import QtQuick.Controls 1.4
import QtQuick.Controls 2.15

import "../utils.js" as Utils

ColumnLayout {
    QtObject {
       id: internal
       readonly property var options: [
           {
               text: "Average temperature",
               param: "Daily average temperature (C°)",
               aggregatef: Utils.average
           },
           {
               text: "Minimum temperature",
               param: "Daily minimum temperature (C°)",
               aggregatef: Utils.min
           },
           {
               text: "Maximum temperature",
               param: "Daily maximum  temperature (C°)",
               aggregatef: Utils.max
           }
       ]
       property var current: options[0]
       readonly property int beginYear: 2000
    }

    ColumnLayout {
        Layout.leftMargin: 15
        Layout.topMargin: 15
        Layout.rightMargin: 15
        TextInputBox {
            id: placeScelector
            Layout.fillWidth: true
            label: "Place:"
            value: "Hervanta"
        }

        RowLayout {
            Text {
                text: "Month: "
            }
            ComboBox{
                id: month
                model: Utils.range(1, 13)
                Layout.fillWidth: true
            }
            ComboBox {
                id: year
                model: Utils.range(internal.beginYear, (new Date()).getFullYear()+2)
                Layout.fillWidth: true
                Component.onCompleted: {
                    currentIndex = (new Date()).getFullYear() - internal.beginYear;
                }
            }
        }

        RowLayout {
            ComboBox {
                Layout.fillWidth: true
                model: internal.options.map(pair=>pair.text)
                onCurrentTextChanged: {
                    internal.current = internal.options[currentIndex];
                }
            }
        }

        Button {
            text: "Search"
            onClicked: {
                var data = getMonthWeatherData(internal.current.param);
                view.model = data;
                valCol.title = internal.current.param;
                var val = internal.current.aggregatef(data.map(d => d.value));
                if (typeof val === 'number' && isFinite(val)){
                    // Val is valid number
                    result.visible = true;
                    val = val.toFixed(2);
                    var o = internal.current;
                    result.text = `${o.text} in ${placeScelector.value} during ${month.currentText}.${year.currentText} was ${val} C°`;
                }
            }
        }
    }

    Text {
        id: result
        visible: true
        font.pointSize: 12
    }

    TableView {
        id: view
        Layout.fillWidth: true
        Layout.fillHeight: true
        horizontalScrollBarPolicy: ScrollBar.AlwaysOff
        TableViewColumn {
            role: "time"
            title: "Date"
            width: parent.width/2
            delegate: Component {
                Text {
                    text: {
                        var date = styleData.value;
                        return `${date.getDate()}.${date.getMonth()+1}.${date.getFullYear()}`;
                    }
                }
            }
        }
        TableViewColumn {
            id: valCol
            role: "value"
            title: "Value"
            width: parent.width/2
        }
    }

    function getMonthWeatherData(param){
        // Get weather data using current gui options
        var y = parseInt(year.currentText);
        var m = parseInt(month.currentText)-1;
        var begin = new Date(y, m);
        var end = new Date(y, m+1, 0);
        return DataService.getTimeseries("fmi",param,begin,end,placeScelector.value);
    }
}
