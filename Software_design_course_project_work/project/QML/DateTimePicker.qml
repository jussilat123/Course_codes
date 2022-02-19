import QtQuick 2.0
import Qt.labs.calendar 1.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "../utils.js" as Utils

Item {
    property date date: new Date()

    height: childrenRect.height
    width: childrenRect.width
    onDateChanged: {
        let temp = date
        temp.setSeconds(0);
        temp.setMilliseconds(0);
        if (temp !== date){
            date = temp;
        }

        year.currentIndex = year.model.findIndex(val => val === date.getFullYear());
        month.currentIndex = date.getMonth();
        day.currentIndex = date.getDate()-1;
        hour.currentIndex = date.getHours();
        minute.currentIndex = date.getMinutes();
    }

    ColumnLayout {
        RowLayout {
            Text {
                text: "Date: "
            }
            ComboBox{
                id: day
                Layout.fillWidth: true
                function updateModel(){
                    let m = parseInt(month.currentText);
                    let y = parseInt(year.currentText);
                    let currD = parseInt(currentIndex);
                    if (!isNaN(m) && !isNaN(y)){
                        let days = daysInMonth(m, y);
                        day.model = Utils.range(1, days+1);
                        if (currD < days)
                            currentIndex = currD;
                    }
                }
                onCurrentTextChanged: {
                    date = new Date(date.setDate(parseInt(currentText)));
                }
            }
            ComboBox{
                id: month
                model: Utils.range(1, 13)
                Layout.fillWidth: true
                onCurrentTextChanged: {
                    date = new Date(date.setMonth(parseInt(currentText-1)));
                    day.updateModel();
                }

            }
            ComboBox {
                id: year
                model: Utils.range(2000, (new Date()).getFullYear()+2)
                Layout.fillWidth: true
                onCurrentTextChanged: {
                    date = new Date(date.setYear(parseInt(currentText)));
                    day.updateModel();
                }
            }
        }
        RowLayout {
            Text {
                text: "Time: "
            }

            ComboBox {
                id: hour
                model: Utils.range(0, 24)
                onCurrentTextChanged: {
                    date = new Date(date.setHours(parseInt(currentText)));
                }
            }
            ComboBox {
                id: minute
                model: Utils.range(0, 60)
                onCurrentTextChanged: {
                    date = new Date(date.setMinutes(parseInt(currentText)));
                }
            }
        }
    }

    function daysInMonth(month, year) {
        // Month is indexed from 1
        let d = new Date(year, month, 0, 12);
        return d.getDate();
    }
}
