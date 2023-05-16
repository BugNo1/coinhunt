import QtQuick 2.15

import "../common-qml/CommonFunctions.js" as Functions

Item {
    id: movingCoin
    width: 50
    height: 50

    property int minimalWaitTime: 30000
    property bool itemActive: false
    visible: false

    // used for collision detection (hitbox is a circle)
    property int hitboxRadius: 25
    property int hitboxX: 0
    property int hitboxY: 0

    property int animationDuration: 1500
    property int nextAnimationInterval: 0
    property int targetX: 0
    property int targetY: 0

    onItemActiveChanged: {
        if (itemActive) {
            // hide
            x = -100
            y = -100
            startTimer()
            movingCoin.visible = true
        } else {
            movingCoin.visible = false
            timer.stop()
        }
    }

    function startTimer() {
        timer.interval = Math.round(Math.random() * minimalWaitTime) + minimalWaitTime
        timer.start()
    }

    Timer {
        id: timer
        interval: 0
        running: false
        repeat: true
        onTriggered: {
            moveCoin()
        }
    }

    function moveCoin() {
        var startQuadrant = Functions.getStartQuadrant()
        var targetQuadrant = Functions.getTargetQuadrant(startQuadrant)

        // set start position
        var result = Functions.getRandomPosition(movingCoin, mainWindow, startQuadrant)
        x = result.x
        y = result.y
        hitboxX = x + width / 2
        hitboxY = y + height / 2

        // set target position
        result = Functions.getRandomPosition(movingCoin, mainWindow, targetQuadrant)
        targetX = result.x
        targetY = result.y

        // start animation
        coinMovement.running = true
    }

    ParallelAnimation {
        id: coinMovement
        NumberAnimation { target: movingCoin; property: "x"; to: targetX; duration: animationDuration }
        NumberAnimation { target: movingCoin; property: "y"; to: targetY; duration: animationDuration }
    }

    onXChanged: {
        hitboxX = x + width / 2
    }

    onYChanged: {
        hitboxY = y + height / 2
    }

    Image {
        id: coinImage
        anchors.fill: parent
        source: "../coinhunt-media/coin.png"
    }
}
