import QtQuick 2.15

Item {
    id: coin
    width: 30
    height: 30

    property bool itemActive: false
    visible: false

    // used for collision detection (hitbox is a circle)
    property int hitboxRadius: 15
    property int hitboxX: 0
    property int hitboxY: 0

    onItemActiveChanged: {
        if (itemActive) {
            setRandomPosition()
            coin.visible = true
        } else {
            coin.visible = false
        }
    }

    function setRandomPosition() {
        x = Math.round(Math.random() * (mainWindow.width - 30))
        y = Math.round(Math.random() * (mainWindow.height - 100))
        hitboxX = x + width / 2
        hitboxY = y + height / 2
    }

    Image {
        id: coinImage
        anchors.fill: parent
        source: "../coinhunt-media/coin.png"
    }
}
