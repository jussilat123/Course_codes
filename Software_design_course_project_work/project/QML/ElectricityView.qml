import QtQuick 2.0
import QtCharts 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "../utils.js" as Utils
import "../"

ColumnLayout {
    id: window
    height: parent.height
    anchors.centerIn: parent
    width: parent.width
    Layout.preferredHeight:  parent.height

    ColumnLayout {
        Layout.leftMargin: 15
        Layout.topMargin: 20
        RowLayout {
            id: begin_date
            Text {
                Layout.fillWidth: false
                text: "Begin: "
            }
            DateTimePicker {
                id: begin
                date: Utils.yesterday()
            }
        }
        RowLayout {
            id: end_date
            Text {
                Layout.fillWidth: false
                text: "  End: "
            }
            DateTimePicker {
                id: end
                date: new Date
            }
        }
        RowLayout {
            id: button
            Button {
                text: "Update Pie Chart"
                onClicked: {
                    update_pie();
                }
            }
        }
    }

    RowLayout {
        ChartView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            id: chart
            title: "Power production in Finland"
            legend.alignment: Qt.AlignBottom
            antialiasing: true

            PieSeries {
                id: pieSeries
            }
        }
    }

    function update_pie(){
        //Removes old slices
        pieSeries.clear()

        //Slices and production type names
        var parameters = DataService.getParameters("fingrid","production_parameters")
        var production_type = DataService.getParameters("fingrid","production_words")

        var totalProduction = get(parameters[0])
        var Other_value = totalProduction

        //Compute fraction of total production and update it to pieSeries
        for (var i = 1; i< production_type.length; i++){
            var current_production_value = get(parameters[i])
            var value = current_production_value/totalProduction
            Other_value -= current_production_value
            pieSeries.append(production_type[i], value);
            }
        Other_value = Other_value/totalProduction
        //Adds remaining fraction of total productions
        pieSeries.append("Other", Other_value);
    }

    //Requests data from FingridService and computes average value of array
    function get(param){
        var data = DataService.getTimeseries("fingrid",param,
                                             begin.date, end.date)
        var y_values = data.map(d=>{return d.value})
        var avg = Utils.average(y_values)

        return avg
    }
}
