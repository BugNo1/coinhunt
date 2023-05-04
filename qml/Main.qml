import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.15
import QtMultimedia 5.15
import QtQml.StateMachine 1.15 as DSM

import "../common-qml"
import "../common-qml/CommonFunctions.js" as Functions

Window {
    id: mainWindow
    width: 1280
    height: 800
    visible: true
    title: qsTr("Coin Hunt")

    property var bugs: [bug1, bug2]
    property var collectibleItems: [itemSpeed]
    property var coins: []
    property var overlay

    Component.onCompleted: {
        setBackground()
        createCoins()
        BugModel1.itemTimerFinished.connect(onItemTimerFinished)
        BugModel2.itemTimerFinished.connect(onItemTimerFinished)
    }

    Image {
        id: background
        anchors.fill: parent
    }

    function setBackground() {
        background.source = bgPath + "bg" + (Math.round(Math.random() * 18) + 1).toString().padStart(2, "0") + ".jpg"
    }

    ItemSpeed {
        id: itemSpeed
        itemActive: false
        minimalSpeed: 150
        minimalWaitTime: 20000
        // stay on top of coins
        z: 1000
    }

    Bug {
        id: bug1
        bugModel: BugModel1
        Connections {
            target: QJoysticks
            function onAxisChanged() {
                bug1.xAxisValue = Functions.filterAxis(QJoysticks.getAxis(0, 0))
                bug1.yAxisValue = Functions.filterAxis(QJoysticks.getAxis(0, 1))
            }
        }
    }

    Bug {
        id: bug2
        bugModel: BugModel2
        sourceFiles: ["../coinhunt-media/robobug-up-red.png", "../coinhunt-media/robobug-middle-red.png", "../coinhunt-media/robobug-down-red.png" ]
        Connections {
            target: QJoysticks
            function onAxisChanged() {
                bug2.xAxisValue = Functions.filterAxis(QJoysticks.getAxis(1, 0))
                bug2.yAxisValue = Functions.filterAxis(QJoysticks.getAxis(1, 1))
            }
        }
    }

    RowLayout {
        id: layout
        width: mainWindow.width
        height: 70
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        // stay on top of everything
        z: 1000
        anchors.bottomMargin: 25
        TimeLevelIndicator {
            id: timeLevelIndicator
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
        }
        CoinIndicator {
            id: coinIndicator
            bugModel1: BugModel1
            bugModel2: BugModel2
            imageSource: "../coinhunt-media/coin.png"
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
        }
    }

    Audio {
        id: coinDropSound
        source: "../coinhunt-media/cash-register.wav"
    }

    Audio {
        id: allCoinsCollectedSound
        source: "../coinhunt-media/fanfare.wav"
    }

    Audio {
        id: itemTimerFinishedSound
        source: "../coinhunt-media/item-end.wav"
    }

    function onItemTimerFinished() {
        itemTimerFinishedSound.source = ""
        itemTimerFinishedSound.source = "../coinhunt-media/item-end.wav"
        itemTimerFinishedSound.play()
    }

    // game logic
    property double startTime: 0
    property double currentTime: 0
    property int currentLevel: 0
    property int levelDuration: 30 * 1000
    property int numberOfCoinsPerRound: 20
    property int roundCounter: 0
    property bool allCoinsCollectedForCurrentLevel: false

    GameStateMachine {
        id: gameStateMachine
        gameResetAction: mainWindow.gameResetAction
        gameCountdownAction: mainWindow.gameCountdownAction
        gameStartAction: mainWindow.gameStartAction
        gameStopAction: mainWindow.gameStopAction
    }

    function gameResetAction() {
        console.log("Resetting game...")

        setBackground()

        allCoinsCollectedForCurrentLevel = false
        currentLevel = 1
        roundCounter = 1
        currentTime = levelDuration
        timeLevelIndicator.setLevel(currentLevel)
        timeLevelIndicator.setTime(currentTime)

        // initialize models
        BugModel1.initialize()
        BugModel2.initialize()
        GameData.initialize()

        overlay = Qt.createQmlObject('import "../common-qml"; GameStartOverlay {}', mainWindow, "overlay")
        overlay.gameName = "Coin Hunt"
        overlay.player1ImageSource = "../coinhunt-media/robobug-middle.png"
        overlay.player2ImageSource = "../coinhunt-media/robobug-middle-red.png"
        overlay.signalStart = gameStateMachine.signalStartCountdown
    }

    function gameCountdownAction() {
        console.log("Starting countdown...")

        GameData.savePlayerNames()
        overlay = Qt.createQmlObject('import "../common-qml"; CountdownOverlay {}', mainWindow, "overlay")
        overlay.signalStart = gameStateMachine.signalStartGame
    }

    function gameStartAction() {
        console.log("Starting game...")

        dropCoins()

        startTime = new Date().getTime()
        gameTimer.start()
        collisionDetectionTimer.start()

        // activate collectible items
        for (var itemIndex = 0; itemIndex < collectibleItems.length; itemIndex++) {
            collectibleItems[itemIndex].itemActive = true
        }
    }

    function gameStopAction() {
        console.log("Stopping game...")

        gameTimer.stop()
        collisionDetectionTimer.stop()

        hideCoins()

        // disable collectible items
        for (var itemIndex = 0; itemIndex < collectibleItems.length; itemIndex++) {
            collectibleItems[itemIndex].itemActive = false
        }

        GameData.player1.pointsAchieved = BugModel1.coinsCollected
        GameData.player2.pointsAchieved = BugModel2.coinsCollected
        GameData.updateHighscores()
        GameData.saveHighscores()

        overlay = Qt.createQmlObject('import "../common-qml"; GameEndOverlay { highscoreType: GameEndOverlay.HighscoreType.Coop }', mainWindow, "overlay")
        overlay.signalStart = gameStateMachine.signalResetGame
    }

    Timer {
        id: gameTimer
        interval: 100
        running: false
        repeat: true
        onTriggered: {
            currentTime = levelDuration - (new Date().getTime() - startTime)
            if (currentTime <= 0) {
                checkGameEnd()
                startNextLevel()
            }
            if (gameTimer.running) {
                startNextCoinRound()
                timeLevelIndicator.setTime(currentTime)
            }
        }
    }

    function checkGameEnd() {
        var totalCoinsCollected = BugModel1.coinsCollected + BugModel2.coinsCollected
        var maxCoinsCollected = 0
        for (var i of Functions.range(1, currentLevel)) {
            maxCoinsCollected += i * numberOfCoinsPerRound
        }

        // not all coins were collected - game end :(
        if (totalCoinsCollected < maxCoinsCollected) {
            gameStateMachine.signalStopGame()
        }
    }

    function startNextCoinRound() {
        // all coins collected?
        var allCoinsCollected = true
        for (var coinIndex = 0; coinIndex < coins.length; coinIndex++) {
            if (coins[coinIndex].itemActive) {
                allCoinsCollected = false
                break
            }
        }
        if (allCoinsCollected && (roundCounter < currentLevel)) {
            roundCounter += 1
            dropCoins()
        } else if (allCoinsCollected && !allCoinsCollectedForCurrentLevel) {
            allCoinsCollectedForCurrentLevel = true
            allCoinsCollectedSound.source = ""
            allCoinsCollectedSound.source = "../coinhunt-media/fanfare.wav"
            allCoinsCollectedSound.play()
        }
    }

    function startNextLevel() {
        allCoinsCollectedForCurrentLevel = false
        currentTime = levelDuration
        roundCounter = 1
        currentLevel += 1
        timeLevelIndicator.setLevel(currentLevel)
        gameTimer.stop()
        gameStateMachine.signalStartCountdown()
    }

    function createCoins() {
        for (var i = 0; i < numberOfCoinsPerRound; i++) {
            var newCoin = Qt.createQmlObject('Coin {}', mainWindow, "coins")
            coins.push(newCoin)
        }
    }

    function dropCoins() {
        coinDropSound.source = ""
        coinDropSound.source = "../coinhunt-media/cash-register.wav"
        coinDropSound.play()
        for (var coinIndex = 0; coinIndex < coins.length; coinIndex++) {
            coins[coinIndex].itemActive = true
        }
    }

    function hideCoins() {
        for (var coinIndex = 0; coinIndex < coins.length; coinIndex++) {
            coins[coinIndex].itemActive = false
        }
    }

    // collision detection
    Timer {
        id: collisionDetectionTimer
        interval: 30
        running: false
        repeat: true
        onTriggered: {
            detectAllCollision()
        }
    }

    function detectAllCollision() {
        // bug vs. bug collision
        if (bugs[0].bugModel.enabled && bugs[1].bugModel.enabled) {
            var colliding = Functions.detectCollisionCircleCircle(bug1, bug2)
            bugs[0].bugModel.bugCollision(1, colliding)
            // only one bug needs to know that a collision happened (so only one bug collision sound is played)
            //bugs[1].bugModel.bugCollision(0, colliding)
        }

        // bug vs. coin collision
        for (var bugIndex = 0; bugIndex < bugs.length; bugIndex++) {
            for (var coinIndex = 0; coinIndex < coins.length; coinIndex++) {
                if (coins[coinIndex].itemActive) {
                    colliding = Functions.detectCollisionCircleCircle(bugs[bugIndex], coins[coinIndex])
                    if (colliding) {
                        bugs[bugIndex].bugModel.addCoin()
                        coins[coinIndex].itemActive = false
                    }
                }
            }
        }

        // bug vs. item collision
        // items: enlarge bug for 10s, stop clock for 10s, turbo speed for 10s, clear all coins

        for (bugIndex = 0; bugIndex < bugs.length; bugIndex++) {
            if (bugs[bugIndex].bugModel.enabled) {
                for (var itemIndex = 0; itemIndex < collectibleItems.length; itemIndex++) {
                    if (collectibleItems[itemIndex].visible) {
                        colliding = Functions.detectCollisionCircleCircle(bugs[bugIndex], collectibleItems[itemIndex])
                        if (colliding) {
                            var condition
                            var action
                            /*if (itemIndex === 0) {
                                // itemInvincibility
                                condition = ! bugs[bugIndex].bugModel.invincible
                                action = function func(duration) {bugs[bugIndex].bugModel.startInvincibility(duration * 1000)}
                            } else if (itemIndex === 1) {
                                // itemExtraLife
                                condition = bugs[bugIndex].bugModel.lives !== bugs[bugIndex].bugModel.maxLives
                                action = function func() {bugs[bugIndex].bugModel.updateLives(1)}*/
                            if (itemIndex === 0) {
                               // itemSpeed
                               condition = true
                               action = function func(speed) {bugs[bugIndex].bugModel.startSpeedRun(speed, 10000)}
                            }
                            collectibleItems[itemIndex].hit(condition, action)
                        }
                    }
                }
            }
        }
    }
}
