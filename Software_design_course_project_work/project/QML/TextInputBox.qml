import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    property string label: ""
    property alias value: input.text

    Text {
        id: textLabel
        text: label + " "
    }

    TextField {
        Layout.fillWidth: true
        id: input
    }
}
