import QtQuick 2.0
import QtCharts 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15
import QtQml.WorkerScript 2.15
import "../../utils.js" as Utils

Item {
    implicitHeight: childrenRect.height
    implicitWidth: childrenRect.width
    ChartView {
        property alias xAxis: x
        property alias yAxis: y

        id: chart
        height: 400
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        DateTimeAxis {
            id: x
        }
        ValueAxis {
            id: y
            min: 0
            max: 1
        }

        function scaleAxis(){
            var bbox = seriesList.getBbox()
            if (bbox.y){
                y.min = bbox.y.min;
                y.max = bbox.y.max;
                y.applyNiceNumbers();
            }
            if (bbox.x){
                x.min = bbox.x.min;
                x.max = bbox.x.max;
            }
        }
    }

    ListModel {
        /*
        Contais series objects and their bboxes. Bbox contains objects named
        after axes as properties. Each object has min and max properties
        */
        id: seriesList
        Component.onCompleted: newSeries();

        function getBbox() {
            // Return bbox containing all series
            var result = {};
            for (var i = 0; i < count; i++){
                var seriesbbox = get(i).bbox;
                for (var axis in seriesbbox){
                    if (result[axis] === undefined){
                        if (seriesbbox[axis].max !== undefined)
                            result[axis] = seriesbbox[axis];
                    } else {
                        result[axis].min = result[axis].min < seriesbbox[axis].min ?
                                           result[axis].min : seriesbbox[axis].min;
                        result[axis].max = result[axis].max > seriesbbox[axis].max ?
                                           result[axis].max : seriesbbox[axis].max;
                    }
                }
            }
            return result
        }
    }

    RowLayout {
        id: buttons
        anchors.top: chart.bottom
        Button {
            text: "Add dataseries"
            onClicked: {
                newSeries();
            }
        }
        Button {
            text: "Remove last dataseries"
            onClicked: {
                removeLastSeries();
            }
        }
    }

    ListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: buttons.bottom
        anchors.bottom: parent.bottom
        model: seriesList
        delegate: delegate
        spacing: 4

        orientation: ListView.Horizontal
        ScrollBar.horizontal: ScrollBar {
            wheelEnabled: true
            parent: listView.parent
            anchors.top: listView.top
            anchors.left: listView.left
            anchors.right: listView.right
        }
    }

    Component {
        id: delegate
        Rectangle {
            color: "#AAAAAA"
            width: selector.width + 30
            height: selector.height + 30
            anchors.leftMargin: 15
            radius: 4

            DataSeriesSettings {
                id: selector
                anchors.centerIn: parent
                seriesName: series.name
                onSeriesNameChanged: series.name = seriesName
                Button {
                    text: "Plot series"
                    onClicked: {
                        visible = false;
                        var data = parent.getData();
                        series.removePoints(0, series.count);
                        if (data.length){
                            var resolution = 200;
                            // Add data to series. If number of data samples is larger than
                            // resolution, adds only resolution samples evenly based on index
                            var indexes = Utils.unique(Utils.linspace(0, data.length-1,
                                                            resolution).map(Math.round));
                            for (var i of indexes){
                                var d = data[i];
                                series.append(d.time, d.value);
                            }
                            // calculates bbox for the series
                            var values = data.map(d => d.value);
                            var times = data.map(d => d.time);
                            var bbox = {};
                            bbox.x = {min: Utils.min(times), max: Utils.max(times)};
                            bbox.y = {min: Utils.min(values), max: Utils.max(values)};

                            seriesList.get(index).bbox = bbox;
                            chart.scaleAxis();
                            visible = true;
                        } else {
                            visible = true;
                        }
                    }
                }
            }
        }
    }

    function newSeries() {
        // Append new series to seriesList
        var series = chart.createSeries(ChartView.SeriesTypeLine, "", chart.xAxis, chart.yAxis);
        series.name = seriesList.count + 1;
        series.axisX = chart.xAxis;
        series.axisY = chart.yAxis;
        seriesList.append({
            series,
            bbox: {}
        });
    }

    function removeLastSeries() {
        // Pop series from seriesList. Removes series from chart
        if (seriesList.count > 1) {
            var i = seriesList.count-1;
            var series = seriesList.get(i).series;
            seriesList.remove(i, 1);
            chart.removeSeries(series);
            chart.scaleAxis();
        }
    }
}
