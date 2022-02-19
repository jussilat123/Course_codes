import QtQuick 2.0

Rectangle {
    color: "red"
    radius: 10
    height: text.height + 40
    visible: false

    Text {
        id: text
        color: "white"
        anchors.centerIn: parent
        font.family: "Helvetica"
        font.pointSize: 12
        function setText(str){
            text.text = str;
            parent.visible = true;
            timer.reset();
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            timer.stop()
            parent.visible = false
        }
    }

    Timer {
        id: timer
        onTriggered: parent.visible = false
        function reset() {
            interval = 4000;
            running = true;
            repeat = false;
        }
    }

    Connections {
            target: DataService
            function onError(errorMsg){
                text.setText("FMI API error: " + errorMsg);
            }
    }
}
