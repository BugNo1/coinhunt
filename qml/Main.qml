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
    property var collectibleItems: []
    property var overlay

    Component.onCompleted: {
        setBackground()
        BugModel1.enabledChanged.connect(onBug1EnabledChanged)
        BugModel2.enabledChanged.connect(onBug2EnabledChanged)
    }

    Image {
        id: background
        anchors.fill: parent
    }

    function setBackground() {
        background.source = bgPath + "bg" + (Math.round(Math.random() * 11) + 1).toString().padStart(2, "0") + ".jpg"
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
        sourceFiles: ["../media/ladybug-up-blue.png", "../media/ladybug-middle-blue.png", "../media/ladybug-down-blue.png" ]
        Connections {
            target: QJoysticks
            function onAxisChanged() {
                bug2.xAxisValue = Functions.filterAxis(QJoysticks.getAxis(1, 0))
                bug2.yAxisValue = Functions.filterAxis(QJoysticks.getAxis(1, 1))
            }
        }
    }

    // TODO: remove life indicators
    // TODO: new indicator needed: coins collected and level (maybe)
    RowLayout {
        id: layout
        width: mainWindow.width
        height: 70
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        // stay on top of everything
        z: 1000
        anchors.bottomMargin: 25
        /*LifeIndicator {
            id: bug1LifeIndicator
            model: BugModel1
            player: GameData.player1
            imageSource: "../media/ladybug-middle.png"
            lifeLostAudioSource: "../media/bird-eating.wav"
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
        }*/
        TimeLevelIndicator {
            id: timeLevelIndicator
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
        }
        /*LifeIndicator {
            id: bug2LifeIndicator
            model: BugModel2
            player: GameData.player2
            imageSource: "../media/ladybug-middle-blue.png"
            lifeLostAudioSource: "../media/bird-eating.wav"
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
        }*/
    }

    // game logic
    property double startTime: 0
    property double currentTime: 0
    property int currentLevel: 0
    property int timeForHuntingAllCoins: 30

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

        currentLevel = 1
        // TODO reset timeForHuntingAllCoins

        //timeLevelIndicator.setLevel(currentLevel)
        //timeLevelIndicator.setTime(currentTime)

        // initialize models
        BugModel1.initialize()
        BugModel2.initialize()
        GameData.initialize()

        overlay = Qt.createQmlObject('import "../common-qml"; GameStartOverlay {}', mainWindow, "overlay")
        overlay.gameName = "Coin Hunt"
        overlay.player1ImageSource = "../media/ladybug-middle.png"
        overlay.player2ImageSource = "../media/ladybug-middle-blue.png"
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

        startTime = new Date().getTime()
        gameTimer.start()
        collisionDetectionTimer.start()

        // activate collectible items
        //for (var itemIndex = 0; itemIndex < collectibleItems.length; itemIndex++) {
        //    collectibleItems[itemIndex].itemActive = true
        //}
    }

    function gameStopAction() {
        console.log("Stopping game...")

        gameTimer.stop()
        collisionDetectionTimer.stop()

        // disable collectible items
        //for (var itemIndex = 0; itemIndex < collectibleItems.length; itemIndex++) {
        //    collectibleItems[itemIndex].itemActive = false
        //}

        GameData.updateHighscores()
        GameData.saveHighscores()

        overlay = Qt.createQmlObject('import "../common-qml"; GameEndOverlay {}', mainWindow, "overlay")
        overlay.signalStart = gameStateMachine.signalResetGame
    }

    Timer {
        id: gameTimer
        interval: 100
        running: false
        repeat: true
        onTriggered: {
            currentTime = new Date().getTime() - startTime
            //updateClock()
            //updateLevel()
            // TODO: update level - means every level a new coin is added - maybe each 10 level addidional time for collecting the coins is added
        }
    }

    function updateLevel() {
        // a level ends when all coins ar collected

        /*var newLevel = 1 + Math.floor(currentTime / 1000 / levelDuration)
        if (newLevel != currentLevel) {
            timeLevelIndicator.setLevel(newLevel)
            createBird()
            currentLevel = newLevel
        }*/
    }

    function onBug1EnabledChanged() {
        /*if (! BugModel1.enabled) {
            GameData.player1.levelAchieved = currentLevel
            GameData.player1.timeAchieved = currentTime
        }
        checkGameEnd()*/
    }

    function onBug2EnabledChanged() {
        /*if (! BugModel2.enabled) {
            GameData.player2.levelAchieved = currentLevel
            GameData.player2.timeAchieved = currentTime
        }
        checkGameEnd()*/
    }

    function checkGameEnd() {
        // game end when time is up and not all coins are collected

        /*if (! BugModel1.enabled && ! BugModel2.enabled) {
            gameStateMachine.signalStopGame()
        }*/
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

        // TODO: bug vs. coin collision

        /*for (var bugIndex = 0; bugIndex < bugs.length; bugIndex++) {
            for (var birdIndex = 0; birdIndex < birds.length; birdIndex++) {
                colliding = Functions.detectCollisionCircleCircle(bugs[bugIndex], birds[birdIndex])
                bugs[bugIndex].bugModel.birdCollision(birdIndex, colliding)
            }
        }*/

        // bug vs. item collision
        /*for (bugIndex = 0; bugIndex < bugs.length; bugIndex++) {
            if (bugs[bugIndex].bugModel.enabled) {
                for (var itemIndex = 0; itemIndex < collectibleItems.length; itemIndex++) {
                    if (collectibleItems[itemIndex].visible) {
                        colliding = Functions.detectCollisionCircleCircle(bugs[bugIndex], collectibleItems[itemIndex])
                        if (colliding) {
                            var condition
                            var action
                            if (itemIndex === 0) {
                                // itemInvincibility
                                condition = ! bugs[bugIndex].bugModel.invincible
                                action = function func(duration) {bugs[bugIndex].bugModel.startInvincibility(duration * 1000)}
                            } else if (itemIndex === 1) {
                                // itemExtraLife
                                condition = bugs[bugIndex].bugModel.lives !== bugs[bugIndex].bugModel.maxLives
                                action = function func() {bugs[bugIndex].bugModel.updateLives(1)}
                            } else if (itemIndex === 2) {
                               // itemSpeed
                               condition = true
                               action = function func(speed) {bugs[bugIndex].bugModel.setSpeed(speed)}
                            }
                            collectibleItems[itemIndex].hit(condition, action)
                        }
                    }
                }
            }
        }*/
    }
}
