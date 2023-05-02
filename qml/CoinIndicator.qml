import QtQuick 2.15
import QtMultimedia 5.15
import QtQuick.Shapes 1.15
import QtQuick.Layouts 1.15

import Theme 1.0

Item {
    id: coinIndicator
    height: 40
    width: 300

    property var bugModel1
    property var bugModel2
    property string imageSource: ""

    Component.onCompleted: {
        bugModel1.coinsCollectedChanged.connect(coinsCollectedChanged)
        bugModel2.coinsCollectedChanged.connect(coinsCollectedChanged)
    }

    function coinsCollectedChanged() {
        coinText.text = (bugModel1.coinsCollected + bugModel2.coinsCollected).toString().padStart(4, "0")
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Theme.overlayBackgroundColor
        radius: 10
        border.width: Theme.overlayBorderWidth
        border.color: Theme.overlayBorderColor
    }

    Image {
        id: coinImage
        x: 75
        y: 5
        width: 30
        height: 30
        source: imageSource
    }

    Text {
        id: coinText
        x: 160
        y: 3
        font.pointSize: 18
        font.family: "Courier"
        text: "0000"
        color: Theme.darkTextColor
    }
}
