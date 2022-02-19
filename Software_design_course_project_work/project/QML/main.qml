import QtQuick 2.15
import QtQuick.Window 2.12
import QtQuick.Controls 2.15

import "./visualisationView"

ApplicationWindow {
    id: root
    width: 900
    height: 920
    visible: true

    TabBar {
        property var childWidth: parent.width/3
        id:nav
        width: parent.width
        z: 2

        TabButton {
            text: "Visualisation view"
            width: parent.childWidth
            onToggled: loader.sourceComponent = visView
        }
        TabButton {
            text: "Weather view"
            width: parent.childWidth
            onToggled: loader.sourceComponent = weatherView
        }
        TabButton {
            text: "Electricity view"
            width: parent.childWidth
            onToggled: loader.sourceComponent = elecView
        }
    }

    Notification {
        anchors.top: nav.bottom
        width: parent.width
        z: 9000
    }

    Loader {
        id: loader

        anchors.top: nav.bottom
        width: parent.width
        height: parent.height
        sourceComponent: visView
    }

    Component {
        id: visView
        VisualisationView {}
    }

    Component {
        id: elecView
        ElectricityView {}
    }

    Component {
        id: weatherView
        WeatherView {}
    }
}
