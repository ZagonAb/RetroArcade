import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.8

FocusScope {
    focus: true
    id: root

    property bool allgamesVisible: false
    property bool recentgamesVisible: false
    property bool mainMenuVisible: true
    property bool favoritegamesVisible: false
    property bool allgamesFocused: false
    property bool recentgamesFocused: false
    property bool favoritegamesFocused: false
    property bool keyboardRetroVisible: false
    property bool keyboardRetroFocused: false
    property bool searchResulFocused: false
    property int currentBackgroundIndex: 0
    property int maxBackgroundIndex: 8
    property int currentOverlayIndex: 0
    property int maxOverlayIndex: 3

    Timer {
        id: launchTimer
        interval: 650 
        repeat: false
        onTriggered: {
            audioPlayer.muted = false;
            var game = api.allGames.get(gameListView.currentIndex);
            game.launch();
        }
    }

    Timer {
        id: launchTimer1
        interval: 650 
        repeat: false
        onTriggered: {
            audioPlayer.muted = false;
            var selectedGame = continuePlayingProxyModel.get(recentListView.currentIndex);
            var selectedTitle = selectedGame.title;
            var gamesArray = api.allGames.toVarArray();
            var gameFound = gamesArray.find(function(game) {
                return game.title === selectedTitle;
            });
            if (gameFound) {
                gameFound.launch();
            } else {
            }
        }
    }

    Timer {
        id: launchTimer2
        interval: 650 
        repeat: false
        onTriggered: {
            audioPlayer.muted = false;
            var selectedGame = favoritesProxyModel.get(favoriteListView.currentIndex);
            var selectedTitle = selectedGame.title;
            var gamesArray = api.allGames.toVarArray();
            var gameFound = gamesArray.find(function(game) {
                return game.title === selectedTitle;
            });
            if (gameFound) {
                gameFound.launch();
            } else {
            }
        }
    }

    Timer {
        id: launchTimer3
        interval: 650 
        repeat: false
        onTriggered: {
            audioPlayer.muted = false;
            var selectedGame = gamesFiltered.get(searchResulView.currentIndex);
            var selectedTitle = selectedGame.title;

            var gamesArray = api.allGames.toVarArray();
            var gameFound = gamesArray.find(function(game) {
                return game.title === selectedTitle;
            });

            if (gameFound) {
                gameFound.launch();
            } else {
            }
        }
    }

    Audio {
        id: audioPlayer
        source: "assets/sounds/sound.wav"
        loops: Audio.Infinite
        autoPlay: true
        volume: 0.30
    }

    SoundEffect {
        id: changeGifSound
        source: "assets/sounds/ChangeGif.wav"
        volume: 1.50
    }
      
    SoundEffect {
        id: shiftSound
        source: "assets/sounds/Shi.wav"
        volume: 0.20
    }

    SoundEffect {
        id: favSound
        source: "assets/sounds/Fav.wav"
        volume: 0.30
    }
      
    SoundEffect {
        id: selectSound
        source: "assets/sounds/Select.wav"
        volume: 0.20
    }

    SoundEffect {
        id: launchSound
        source: "assets/sounds/Launch.wav"
        volume: 1.50
    }

    FontLoader {
        id: fontLoader
        source: "assets/font/ARCADE.TTF"
    }

    FontLoader {
        id: fontLoader2
        source: "assets/font/ARCADE2.TTF"
    }

    function updateBackground() {
        gifBackground.source = "assets/background/background" + currentBackgroundIndex + ".gif"
    }

    function updateOverlay() {
        overlayImage.source = "assets/overlay/overlay" + currentOverlayIndex + ".png"
    }

    AnimatedImage {
        id: gifBackground
        source: "assets/background/background0.gif"
        width: parent.width * 0.90
        height: parent.height * 0.90
        anchors.centerIn: parent
        playing: true
        cache: false
    }

    LinearGradient {
        id: screenshotGrad
        width: root.width
        height: parent.height
        anchors.top: root.top
        anchors.bottom: root.bottom
        start: Qt.point(0, height)
        end: Qt.point(0, 0)
        gradient: Gradient {
            GradientStop { position: 1.0; color: "#FF000000" }
            GradientStop { position: 0.5; color: "#00000000" }
        }
    }

    Item{
        anchors.fill: parent

        Rectangle{
            id: rect0
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height * 0.10
            width: parent.width * 0.25
            color: "transparent"
        }

        Item {
            id: retroArcdeText
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height 
            width: parent.width
            anchors.top: rect0.bottom 
            anchors.topMargin: 5  
            visible: mainMenuVisible

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                sourceSize { width: 556; height: 115 }
                source: "assets/title/title.png"
            }
        }
    }

    SortFilterProxyModel {
        id: gamesFiltered
        sourceModel: api.allGames
        property string searchTerm: ""

        filters: [
            RegExpFilter {
                roleName: "title"; 
                pattern: "^" + gamesFiltered.searchTerm.trim().replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&') + ".+";
                caseSensitivity: Qt.CaseInsensitive; 
                enabled: gamesFiltered.searchTerm !== "";
            }
        ]
        
        property bool hasResults: count > 0
    }

    SortFilterProxyModel {
        id: filteredGames1
        sourceModel: api.allGames
        sorters: RoleSorter { roleName: "lastPlayed"; sortOrder: Qt.DescendingOrder }
    }

    SortFilterProxyModel {
        id: favoritesProxyModel
        sourceModel: api.allGames
        filters: ValueFilter { roleName: "favorite"; value: true }
    }

    ListModel {
        id: continuePlayingProxyModel
        Component.onCompleted: {
            var currentDate = new Date()
            var sevenDaysAgo = new Date(currentDate.getTime() - 7 * 24 * 60 * 60 * 1000)
            for (var i = 0; i < filteredGames1.count; ++i) {
                var game = filteredGames1.get(i)
                var lastPlayedDate = new Date(game.lastPlayed)
                var playTimeInMinutes = game.playTime / 60
                if (lastPlayedDate >= sevenDaysAgo && playTimeInMinutes > 1) {
                    continuePlayingProxyModel.append(game)
                }
            }
        }
    }

    Rectangle {
        id: mainMenuRectangle
        anchors.fill: parent
        color: "transparent"
                
        GridLayout {
            id: gridLayout
            columns: 2
            rowSpacing: 20
            columnSpacing: 20
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 55
            width: parent.width * 0.45
            height: parent.height * 0.45
            anchors.margins: 20

            visible: mainMenuVisible

            Rectangle {
                id: rect1
                Layout.preferredWidth: parent.width / 2 - gridLayout.columnSpacing / 2 
                Layout.preferredHeight: parent.height / 2 - gridLayout.rowSpacing / 2 

                color: "black"
                border.color: "blue"
                border.width: 5
                radius: 20
                clip: true

                onWidthChanged: text1.adjustFontSize()
                onHeightChanged: text1.adjustFontSize()

                Item {
                    anchors.fill: parent

                    Text {
                        id: text1
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "ALL\nGAMES"
                        font.family: fontLoader.name
                        font.bold: false
                        color: "#fff900"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        fontSizeMode: Text.Fit
                        property real minFontSize: 10
                        property real maxFontSize: 55

                        function adjustFontSize() {
                            var containerSize = Math.min(rect1.width, rect1.height);
                            var textLengthFactor = text.length / 9;
                            font.pixelSize = Math.max(minFontSize, Math.min(maxFontSize, containerSize / textLengthFactor));
                        }

                        Component.onCompleted: adjustFontSize()
                    }

                    DropShadow {
                        anchors.fill: text1
                        source: text1
                        radius: 5
                        samples: 40
                        color: "#f21f25"
                        horizontalOffset: -4
                        verticalOffset: 4
                    }
                }

                onFocusChanged: {
                    if (focus) {
                        borderAnimation1.running = true
                        textAnimation1.running = true
                    } else {
                        borderAnimation1.running = false
                        textAnimation1.running = false
                        border.color = "blue"
                        text1.color = "yellow"
                    }
                }

                SequentialAnimation {
                    id: borderAnimation1
                    loops: Animation.Infinite
                    running: false
                    ColorAnimation { target: rect1.border; property: "color"; to: "#fe26d8"; duration: 600 }
                    ColorAnimation { target: rect1.border; property: "color"; to: "blue"; duration: 600 }
                }

                SequentialAnimation {
                    id: textAnimation1
                    loops: Animation.Infinite
                    running: false
                    ColorAnimation { target: text1; property: "color"; to: "#fe26d8"; duration: 600 }
                    ColorAnimation { target: text1; property: "color"; to: "yellow"; duration: 600 }
                }
            }

            Rectangle {
                id: rect2
                Layout.preferredWidth: parent.width / 2 - gridLayout.columnSpacing / 2 
                Layout.preferredHeight: parent.height / 2 - gridLayout.rowSpacing / 2 
                color: "black"
                border.color: "blue"
                border.width: 5
                radius: 20
                clip: true

                onWidthChanged: text2.adjustFontSize()
                onHeightChanged: text2.adjustFontSize()

                Item {
                    anchors.fill: parent
                
                    Text {
                        id: text2
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "SEARCH\nGAMES"
                        font.family: fontLoader.name
                        font.bold: false
                        color: "#fff900"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        fontSizeMode: Text.Fit
                        property real minFontSize: 10
                        property real maxFontSize: 55

                        function adjustFontSize() {
                            var containerSize = Math.min(rect2.width, rect2.height);
                            var textLengthFactor = text.length / 16;
                            font.pixelSize = Math.max(minFontSize, Math.min(maxFontSize, containerSize / textLengthFactor));
                        }

                        Component.onCompleted: adjustFontSize()
                    }

                    DropShadow {
                        anchors.fill: text2
                        source: text2
                        radius: 5
                        samples: 40
                        color: "#f21f25"
                        horizontalOffset: -4
                        verticalOffset: 4
                    }
                }

                onFocusChanged: {
                    if (focus) {
                        borderAnimation2.running = true
                        textAnimation2.running = true
                    } else {
                        borderAnimation2.running = false
                        textAnimation2.running = false
                        border.color = "blue"
                        text2.color = "yellow"
                    }
                }

                SequentialAnimation {
                    id: borderAnimation2
                    loops: Animation.Infinite
                    running: false
                    ColorAnimation { target: rect2.border; property: "color"; to: "#fe26d8"; duration: 600 }
                    ColorAnimation { target: rect2.border; property: "color"; to: "blue"; duration: 600 }
                }

                SequentialAnimation {
                    id: textAnimation2
                    loops: Animation.Infinite
                    running: false
                    ColorAnimation { target: text2; property: "color"; to: "#fe26d8"; duration: 600 }
                    ColorAnimation { target: text2; property: "color"; to: "yellow"; duration: 600 }
                }
            }

            Rectangle {
                id: rect3
                Layout.preferredWidth: parent.width / 2 - gridLayout.columnSpacing / 2 
                Layout.preferredHeight: parent.height / 2 - gridLayout.rowSpacing / 2 
                color: "black"
                border.color: "blue"
                border.width: 5
                radius: 20
                clip: true

                onWidthChanged: text3.adjustFontSize()
                onHeightChanged: text3.adjustFontSize()

                Item {
                    anchors.fill: parent

                    Text {
                        id: text3
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "CONTINUE\nPLAYING"
                        font.family: fontLoader.name
                        font.bold: false
                        color: "#fff900"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        fontSizeMode: Text.Fit
                        property real minFontSize: 10
                        property real maxFontSize: 50

                        function adjustFontSize() {
                            var containerSize = Math.min(rect3.width, rect3.height);
                            var textLengthFactor = text.length / 16;
                            font.pixelSize = Math.max(minFontSize, Math.min(maxFontSize, containerSize / textLengthFactor));
                        }

                        Component.onCompleted: adjustFontSize()
                    }

                    DropShadow {
                        anchors.fill: text3
                        source: text3
                        radius: 5
                        samples: 40
                        color: "#f21f25"
                        horizontalOffset: -4
                        verticalOffset: 4
                    }
                }


                onFocusChanged: {
                    if (focus) {
                        borderAnimation3.running = true
                        textAnimation3.running = true
                    } else {
                        borderAnimation3.running = false
                        textAnimation3.running = false
                        border.color = "blue"
                        text3.color = "yellow"
                    }
                }

                SequentialAnimation {
                    id: borderAnimation3
                    loops: Animation.Infinite
                    running: false
                    ColorAnimation { target: rect3.border; property: "color"; to: "#fe26d8"; duration: 600 }
                    ColorAnimation { target: rect3.border; property: "color"; to: "blue"; duration: 600 }
                }

                SequentialAnimation {
                    id: textAnimation3
                    loops: Animation.Infinite
                    running: false
                    ColorAnimation { target: text3; property: "color"; to: "#fe26d8"; duration: 600 }
                    ColorAnimation { target: text3; property: "color"; to: "yellow"; duration: 600 }
                }
            }

            Rectangle {
                id: rect4
                Layout.preferredWidth: parent.width / 2 - gridLayout.columnSpacing / 2 
                Layout.preferredHeight: parent.height / 2 - gridLayout.rowSpacing / 2 
                color: "black"
                border.color: "blue"
                border.width: 5
                radius: 20
                clip: true

                onWidthChanged: text4.adjustFontSize()
                onHeightChanged: text4.adjustFontSize()

                Item {
                    anchors.fill: parent

                    Text {
                        id: text4
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "FAVORITE\nGAMES"
                        font.family: fontLoader.name
                        font.bold: false
                        color: "#fff900"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        wrapMode: Text.WordWrap
                        fontSizeMode: Text.Fit
                        property real minFontSize: 10
                        property real maxFontSize: 45

                        function adjustFontSize() {
                            var containerSize = Math.min(rect4.width, rect4.height);
                            var textLengthFactor = text.length / 14;
                            font.pixelSize = Math.max(minFontSize, Math.min(maxFontSize, containerSize / textLengthFactor));
                        }

                        Component.onCompleted: adjustFontSize()
                    }

                    DropShadow {
                        anchors.fill: text4
                        source: text4
                        radius: 5
                        samples: 40
                        color: "#f21f25"
                        horizontalOffset: -4
                        verticalOffset: 4
                    }
                }

                onFocusChanged: {
                    if (focus) {
                        borderAnimation4.running = true
                        textAnimation4.running = true
                    } else {
                        borderAnimation4.running = false
                        textAnimation4.running = false
                        border.color = "blue"
                        text4.color = "yellow"
                    }
                }

                SequentialAnimation {
                    id: borderAnimation4
                    loops: Animation.Infinite
                    running: false
                    ColorAnimation { target: rect4.border; property: "color"; to: "#fe26d8"; duration: 600 }
                    ColorAnimation { target: rect4.border; property: "color"; to: "blue"; duration: 600 }
                }

                SequentialAnimation {
                    id: textAnimation4
                    loops: Animation.Infinite
                    running: false
                    ColorAnimation { target: text4; property: "color"; to: "#fe26d8"; duration: 600 }
                    ColorAnimation { target: text4; property: "color"; to: "yellow"; duration: 600 }
                }
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Right) {
                    if (rect1.focus) {
                        shiftSound.play();
                        rect2.forceActiveFocus();
                    } else if (rect3.focus) {
                        shiftSound.play();
                        rect4.forceActiveFocus();
                    }
                } else if (event.key === Qt.Key_Left) {
                    if (rect2.focus) {
                        shiftSound.play();
                        rect1.forceActiveFocus();
                    } else if (rect4.focus) {
                        shiftSound.play();
                        rect3.forceActiveFocus();
                    }
                } else if (event.key === Qt.Key_Up) {
                    if (rect3.focus) {
                        shiftSound.play();
                        rect1.forceActiveFocus();
                    } else if (rect4.focus) {
                        shiftSound.play();
                        rect2.forceActiveFocus();
                    }
                } else if (event.key === Qt.Key_Down) {
                    if (rect1.focus) {
                        shiftSound.play();
                        rect3.forceActiveFocus();
                    } else if (rect2.focus) {
                        shiftSound.play();
                        rect4.forceActiveFocus();
                    }
                } else if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                    if (rect1.focus) {
                        selectSound.play();
                        mainMenuVisible = false;
                        allgamesFocused = true;
                        gridLayout.focus = false;
                        allgamesVisible = true;
                    } else if (rect2.focus) {
                        selectSound.play();
                        mainMenuVisible = false;
                        keyboardRetroFocused = true;
                        gridLayout.focus = false;
                        keyboardRetroVisible = true;
                    }else if (rect3.focus) {
                        selectSound.play();
                        mainMenuVisible = false;
                        recentgamesFocused = true;
                        gridLayout.focus = false;
                        recentgamesVisible = true;
                    } else if (rect4.focus) {
                        selectSound.play();
                        mainMenuVisible = false;
                        gridLayout.focus = false;
                        favoritegamesFocused = true;
                        favoritegamesVisible = true;
                    } else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                        event.accepted = true;
                    }
                }
            }
        }
    }

    function updateGameInfo() {
        var game = api.allGames.get(gameListView.currentIndex);
        if (game) {

            var collections = game.collections.toVarArray().map(function(collection) {
                return collection.name;
            }).join(", ");

            var releaseDate = game.release ? game.release.toLocaleDateString(Qt.locale("en_US"), "yyyy") : "N/A";
            
            var players = game.players || "1";
            var developer = game.developer || "Unknown";

            gameInfoText1.text = "Collection: " + collections;
            gameInfoText2.text = "Developer: " + developer + " | Release: " + releaseDate + " | Players: " + players;
        } else {
            gameInfoText1.text = "";
            gameInfoText2.text = "";
        }

        var gamesCount = api.allGames.count;
        gameInfoText22.text = "" + gamesCount;
    }

    Rectangle {
        id: allGamesConteiner
        anchors.centerIn: parent
        width: parent.width * 0.86
        height: parent.height * 0.86
        radius: 160
        color: "transparent"
        clip: true
        visible: allgamesVisible

        Row {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10 
            spacing: 20

            Text {
                id: allGamesTitle
                text: "ALL GAMES"
                font.family: fontLoader.name
                font.pixelSize: 32
                color: "#fe31f9"
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 20
                    samples: 20
                    color: "#f21f25"
                    horizontalOffset: -2
                    verticalOffset: 5
                    spread: 0.35
                }
            }

            Text {
                id: gameInfoText22
                font.family: fontLoader.name
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 18
                color: "yellow"
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 20
                    samples: 20
                    color: "yellow"
                    horizontalOffset: -2
                    verticalOffset: 5
                    spread: 0.35
                }
            }
        }

        Rectangle {
            id: allGameslistview
            anchors.centerIn: parent
            width: parent.width
            height: parent.height * 0.80
            color: "transparent"
            clip: true


            ListView {
                id: gameListView
                width: parent.width
                height: parent.height * 0.95
                model: api.allGames
                clip: true

                delegate: Item {
                    width: gameListView.width
                    height: gameListView.height * 0.09
                    property string shortenedTitle: {
                        var maxLength = 26;
                        if (modelData.title.length > maxLength) {
                            return modelData.title.substring(0, maxLength - 5) + "...";
                        } else {
                            return modelData.title;
                        }
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"
                        
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10
                            
                            Image {
                                id: icon
                                width: titleText.height
                                height: titleText.height
                                source: {
                                    if (modelData.favorite && gameListView.currentIndex === index) {
                                        return "assets/icons/favorite.ico";
                                    } else if (gameListView.currentIndex === index) {
                                        return "assets/icons/games.ico";
                                    } else {
                                        return "";
                                    }
                                }
                                visible: source !== ""
                            }

                            Text {
                                id: titleText
                                text: shortenedTitle
                                font.family: fontLoader.name
                                font.pixelSize: Math.min(allGameslistview.height / 20, allGameslistview.width / 20)
                                color: "yellow"
                                elide: Text.ElideMiddle
                                verticalAlignment: Text.AlignVCenter
                                layer.enabled: true
                                layer.effect: DropShadow {
                                    radius: 5
                                    samples: 40
                                    color: "#f21f25"
                                    horizontalOffset: -4
                                    verticalOffset: 4
                                }
                            }
                        }
                    }
                }

                focus: allgamesFocused

                onFocusChanged: {
                    if (gameListView.focus) {
                        gameListView.currentIndex = 0;
                        updateGameInfo();
                    }
                }


                Keys.onUpPressed: {
                    if (currentIndex > 0) {
                        currentIndex--
                        shiftSound.play();
                        updateGameInfo();
                    }
                }

                Keys.onDownPressed: {
                    if (currentIndex < count - 1) {
                        currentIndex++
                        shiftSound.play();
                        updateGameInfo();
                    }
                }

                Keys.onPressed: {
                    if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                        audioPlayer.muted = true;
                        launchSound.play();
                        launchTimer.start();
                    } else if (api.keys.isDetails(event)) {
                        event.accepted = true;
                        favSound.play()
                        var game = api.allGames.get(currentIndex);
                        game.favorite = !game.favorite;
                    } else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                        event.accepted = true;
                        selectSound.play();
                        allgamesVisible = false;
                        allgamesFocused = false;
                        mainMenuVisible = true;
                        rect1.forceActiveFocus();
                    }
                }

                Component.onCompleted: {
                    updateGameInfo();
                }

                onCurrentIndexChanged: {
                    updateGameInfo();
                }
            }
        }

        Rectangle {
            id: infoGames
            height: parent.height * 0.10
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: allGamesConteiner.bottom 
            anchors.topMargin: 5 
            color: "transparent"

            Column {
                anchors.centerIn: parent

                Text {
                    id: gameInfoText1
                    color: "white"
                    font.pixelSize: infoGames.height * 0.35
                    font.family: fontLoader2.name
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    minimumPixelSize: 15
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 20
                        samples: 20
                        color: "#fe31f9"
                        horizontalOffset: -2
                        verticalOffset: 5
                        spread: 0.35
                    }
                }

                Text {
                    id: gameInfoText2
                    color: "white"
                    font.pixelSize: infoGames.height * 0.35
                    font.family: fontLoader2.name
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    minimumPixelSize: 15
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 20
                        samples: 20
                        color: "#fe31f9"
                        horizontalOffset: -2
                        verticalOffset: 5
                        spread: 0.35
                    }
                }
            }
        }
    }

    function updateGameInfo2() {
        var game = continuePlayingProxyModel.get(recentListView.currentIndex);
        if (game) {

            var collections = game.collections.toVarArray().map(function(collection) {
                return collection.name;
            }).join(", ");
            
            gameInfoText3.text = "Collection: " + collections;
            
            var totalSeconds = game.playTime || 0;
            var hours = Math.floor(totalSeconds / 3600);
            var minutes = Math.floor((totalSeconds % 3600) / 60);
            var seconds = totalSeconds % 60;
            var playTimeFormatted = hours + "h " + minutes + "m " + seconds + "s";

            gameInfoText33.text = "Time played: " + playTimeFormatted;
        } else {
            gameInfoText3.text = "";
            gameInfoText33.text = "";
        }
    }

    Rectangle {
        id: recentGamesConteiner
        anchors.centerIn: parent
        width: parent.width * 0.86
        height: parent.height * 0.90
        radius: 160
        color: "transparent"
        clip: true
        visible: recentgamesVisible

        Text{
            id:continueGamesTitle
            text: "CONTINUE PLAYING"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10 
            font.family: fontLoader.name
            //font.pixelSize: 32;
            font.pixelSize: Math.min(recentGamesConteiner.height / 25, recentGamesConteiner.width / 2)

            color: "#fe31f9"
            layer.enabled: true
            layer.effect: DropShadow {
                radius: 20
                samples: 20
                color: "#f21f25"
                horizontalOffset: -2
                verticalOffset: 5
                spread: 0.35
            }
        }

        Rectangle {
            id: recentGameslistview
            anchors.centerIn: parent
            width: parent.width
            height: parent.height * 0.80
            color: "transparent"
            clip: true

            ListView {
                id: recentListView
                width: parent.width
                height: parent.height * 0.95
                model: continuePlayingProxyModel
                clip: true

                delegate: Item {
                    width: recentListView.width
                    height: recentListView.height * 0.08
                    property string shortenedTitle: {
                        var maxLength = 26;
                        if (modelData.title.length > maxLength) {
                            return modelData.title.substring(0, maxLength - 5) + "...";
                        } else {
                            return modelData.title;
                        }
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"
                        
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10
                            
                            Image {
                                id: icon
                                width: titleText1.height
                                height: titleText1.height
                                source: {
                                    if (modelData.favorite && recentListView.currentIndex === index) {
                                        return "assets/icons/favorite.ico";
                                    } else if (recentListView.currentIndex === index) {
                                        return "assets/icons/continue.ico";
                                    } else {
                                        return "";
                                    }
                                }
                                visible: source !== ""
                            }

                            Text {
                                id: titleText1
                                text: shortenedTitle
                                font.family: fontLoader.name
                                font.pixelSize: Math.min(recentListView.height / 20, recentListView.width / 20)
                                color: "yellow"
                                elide: Text.ElideMiddle
                                verticalAlignment: Text.AlignVCenter
                                layer.enabled: true
                                layer.effect: DropShadow {
                                    radius: 5
                                    samples: 40
                                    color: "#f21f25"
                                    horizontalOffset: -4
                                    verticalOffset: 4
                                }
                            }
                        }
                    }
                }

                focus: recentgamesFocused

                onFocusChanged: {
                    if (recentListView.focus) {
                        recentListView.currentIndex = 0;
                        updateGameInfo2();
                    }
                }

                Keys.onUpPressed: {
                    if (currentIndex > 0) {
                        currentIndex--
                        shiftSound.play();
                        updateGameInfo2();
                    }
                }
                Keys.onDownPressed: {
                    if (currentIndex < count - 1) {
                        currentIndex++
                        shiftSound.play();
                        updateGameInfo2();
                    }
                }

                Keys.onPressed: {
                    if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                        audioPlayer.muted = true;
                        launchSound.play();
                        launchTimer1.start();
                    } else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                        event.accepted = true;
                        selectSound.play();
                        recentgamesVisible = false
                        recentgamesFocused = false
                        mainMenuVisible = true;
                        rect3.forceActiveFocus();
                    } else if (api.keys.isDetails(event)) {
                        event.accepted = true;
                        favSound.play()
                        var selectedGame = continuePlayingProxyModel.get(recentListView.currentIndex);
                        var selectedTitle = selectedGame.title;
                        var gamesArray = api.allGames.toVarArray();
                        var gameFound = gamesArray.find(function(game) {
                            return game.title === selectedTitle;
                        });
                        if (gameFound) {
                            gameFound.favorite = !gameFound.favorite;
                        } else {
                        }     
                    }
                }

                Component.onCompleted: {
                    updateGameInfo2();
                }

                onCurrentIndexChanged: {
                    updateGameInfo2();
                }   
            }

            Text {
                id: noRecentGames
                anchors.centerIn: parent
                text: "No  last Played games available"
                font.family: fontLoader.name
                font.pixelSize: 24
                color: "white"
                visible: continuePlayingProxyModel.count === 0
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 20
                    samples: 20
                    color: "white"
                    horizontalOffset: -2
                    verticalOffset: 5
                    spread: 0.35
                }
            }
        }

        Rectangle {
            id: infoGames2
            height: parent.height * 0.10
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: recentGamesConteiner.bottom 
            anchors.topMargin: 5 
            color: "transparent"

            Column {
                anchors.centerIn: parent

                Text {
                    id: gameInfoText3
                    color: "white"
                    font.pixelSize: infoGames.height * 0.40
                    font.family: fontLoader2.name
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    minimumPixelSize: 15
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 20
                        samples: 20
                        color: "#fe31f9"
                        horizontalOffset: -2
                        verticalOffset: 5
                        spread: 0.35
                    }
                }

                Text {
                    id: gameInfoText33
                    color: "white"
                    font.pixelSize: infoGames.height * 0.35
                    font.family: fontLoader2.name
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    minimumPixelSize: 15
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 20
                        samples: 20
                        color: "#fe31f9"
                        horizontalOffset: -2
                        verticalOffset: 5
                        spread: 0.35
                    }
                }
            }
        }
    }

    function updateGameInfo3() {
        var game = favoritesProxyModel.get(favoriteListView.currentIndex);
        if (game && game.collections) {
            var collections = game.collections.toVarArray().map(function(collection) {
                return collection.name;
            }).join(", ");
            gameInfoText4.text = "Collection: " + collections;
        } else {
            gameInfoText4.text = "";
        }
    }

    Rectangle {
        id: favoriteGamesConteiner
        anchors.centerIn: parent
        width: parent.width * 0.86
        height: parent.height * 0.86
        radius: 160
        color: "transparent"
        clip: true
        visible: favoritegamesVisible

        Text{
            id: favoriteTitle
            text: "FAVORITE GAMES"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10 
            font.family: fontLoader.name
            font.pixelSize: 32;
            color: "#fe31f9"
            layer.enabled: true
            layer.effect: DropShadow {
                radius: 20
                samples: 20
                color: "#f21f25"
                horizontalOffset: -2
                verticalOffset: 5
                spread: 0.35
            }
        }

        Rectangle {
            id: favoriteGameslistview
            anchors.centerIn: parent
            width: parent.width
            height: parent.height * 0.80
            color: "transparent"
            clip: true
            
            ListView {
                id: favoriteListView
                width: parent.width
                height: parent.height * 0.90
                model: favoritesProxyModel

                delegate: Item {
                    width: favoriteListView.width
                    height: favoriteListView.height * 0.1
                    property string shortenedTitle: {
                        var maxLength = 28;
                        if (modelData.title.length > maxLength) {
                            return modelData.title.substring(0, maxLength - 5) + "...";
                        } else {
                            return modelData.title;
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"
                        
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 10
                            
                            Image {
                                id: favoriteIcon
                                width: titleText1.height
                                height: titleText1.height
                                source: favoriteListView.currentIndex === index ? "assets/icons/favorite.ico" : ""
                                visible: source !== ""
                            }

                            Text {
                                id: titleText1
                                text: shortenedTitle
                                font.family: fontLoader.name
                                font.pixelSize: Math.min(favoriteGameslistview.height / 25, favoriteGameslistview.width / 2)
                                color: "yellow"
                                elide: Text.ElideMiddle
                                verticalAlignment: Text.AlignVCenter
                                layer.enabled: true
                                layer.effect: DropShadow {
                                    radius: 5
                                    samples: 40
                                    color: "#f21f25"
                                    horizontalOffset: -4
                                    verticalOffset: 4
                                }
                            }
                        }
                    }
                }
            
                focus: favoritegamesFocused

                onFocusChanged: {
                    if (favoriteListView.focus) {
                        favoriteListView.currentIndex = 0;
                        updateGameInfo3();
                    }
                }

                Keys.onUpPressed: {
                    if (currentIndex > 0) {
                        currentIndex--
                        shiftSound.play();
                        updateGameInfo3();
                    }
                }

                Keys.onDownPressed: {
                    if (currentIndex < count - 1) {
                        currentIndex++
                        shiftSound.play();
                        updateGameInfo3();
                    }
                }

                Keys.onPressed: {
                    if (api.keys.isAccept(event)) {
                        audioPlayer.muted = true;
                        launchSound.play();
                        launchTimer2.start();
                    } else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                        event.accepted = true;
                        selectSound.play();
                        favoritegamesVisible = false
                        favoritegamesFocused = false
                        mainMenuVisible = true;
                        rect4.forceActiveFocus();
                    } else if (api.keys.isDetails(event)) {
                        event.accepted = true;
                        favSound.play()
                        var selectedGame = favoritesProxyModel.get(favoriteListView.currentIndex);
                        var selectedTitle = selectedGame.title;
                        var gamesArray = api.allGames.toVarArray();
                        var gameFound = gamesArray.find(function(game) {
                            return game.title === selectedTitle;
                        });
                        if (gameFound) {
                            gameFound.favorite = !gameFound.favorite;
                        } else {
                        }
                    }
                }

                Component.onCompleted: {
                    updateGameInfo3();
                }

                onCurrentIndexChanged: {
                    updateGameInfo3();
                }    
            }

            Text {
                id: noFavorireGames
                anchors.centerIn: parent
                text: "No favorite games available"
                font.family: fontLoader.name
                font.pixelSize: 24
                color: "white"
                visible: favoritesProxyModel.count === 0
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 20
                    samples: 20
                    color: "white"
                    horizontalOffset: -2
                    verticalOffset: 5
                    spread: 0.35
                }
            }
        }

        Rectangle {
            id: infoGames3
            height: parent.height * 0.10
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: favoriteGamesConteiner.bottom 
            anchors.topMargin: 5
            color: "transparent"

            Column {
                anchors.centerIn: parent

                Text {
                    id: gameInfoText4
                    color: "white"
                    visible: favoritesProxyModel.count > 0 
                    font.pixelSize: infoGames3.height * 0.40
                    font.family: fontLoader2.name
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    minimumPixelSize: 15
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 20
                        samples: 20
                        color: "#fe31f9"
                        horizontalOffset: -2
                        verticalOffset: 5
                        spread: 0.35
                    }
                }
            }
        }
    }

    function updateGameInfo4() {
        var game = gamesFiltered.get(searchResulView.currentIndex);
        if (game && game.collections) {
            var collections = game.collections.toVarArray().map(function(collection) {
                return collection.name;
            }).join(", ");
            gameInfoText5.text = "Collection: " + collections;
        } else {
            gameInfoText5.text = "";
        }
    }

    Rectangle {
        id: searchGamesConteiner
        anchors.centerIn: parent
        width: parent.width * 0.80
        height: parent.height * 0.85
        visible: keyboardRetroVisible
        color: "transparent" 
        clip: true
        
        Column {
        
            anchors.fill: parent
            spacing: 20 

            Rectangle {
                id: searchInputbar
                height: parent.height * 0.07
                width: parent.width * 0.45
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                border.color: "blue"
                border.width: 5
                radius: 40
                clip: true

                Row {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 2

                    Item {
                        width: 24
                        height: 24

                        Image {
                            id: searchSymbol
                            source: "assets/icons/search.svg"
                            anchors.centerIn: parent
                            width: 24
                            height: 24

                            layer.enabled: true
                            layer.effect: DropShadow {
                                radius: 20
                                samples: 20
                                color: "#f21f25"
                                horizontalOffset: -2
                                verticalOffset: 5
                                spread: 0.35
                            }
                        }
                    }

                    TextInput {
                        id: searchInput
                        visible: keyboardRetroVisible
                        color: "#fff900"
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: fontLoader.name
                        font.pixelSize: 18
                        leftPadding: 10
                        layer.enabled: true
                        layer.effect: DropShadow {
                            radius: 20
                            samples: 20
                            color: "#f21f25"
                            horizontalOffset: -2
                            verticalOffset: 5
                            spread: 0.30
                        }

                        onTextChanged: {
                            gamesFiltered.searchTerm = searchInput.text.trim();
                        }
                    }

                    Text {
                        id: searchGameHere
                        text: "Search for games..."
                        color: "#fff900"
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: fontLoader.name
                        font.pixelSize: 12
                        visible: searchInput.length === 0
                        wrapMode: Text.Wrap
                        layer.enabled: true
                        layer.effect: DropShadow {
                            radius: 20
                            samples: 20
                            color: "#f21f25"
                            horizontalOffset: -2
                            verticalOffset: 5
                            spread: 0.30
                        }
                    }
                }
            }

            Rectangle {
                id: searchResul
                height: parent.height * 0.50
                width: parent.width * 0.98
                anchors.horizontalCenter: parent.horizontalCenter
                color: "transparent"
                radius: 40
                clip: true

                ListView {
                    id: searchResulView
                    width: parent.width
                    height: parent.height * 0.95
                    model: gamesFiltered
                    spacing: 6

                    delegate: Item {
                        width: searchResulView.width
                        height: searchResulView.height * 0.13
                        property string shortenedTitle: {
                            var maxLength = 24;
                            if (modelData.title.length > maxLength) {
                                return modelData.title.substring(0, maxLength - 5) + "...";
                            } else {
                                return modelData.title;
                            }
                        }
                        
                        Rectangle {
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            color: "transparent"
                            
                            Row {
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 15
                                
                                Image {
                                    id: icon2
                                    width: titleText2.height +7
                                    height: titleText2.height +7
                                    source: {
                                        if (modelData.favorite && searchResulFocused && searchResulView.currentIndex === index) {
                                            return "assets/icons/favorite.ico";
                                        } else if (searchResulFocused && searchResulView.currentIndex === index) {
                                            return "assets/icons/game.ico";
                                        } else {
                                            return "";
                                        }
                                    }
                                    visible: source !== ""
                                }

                                Text {
                                    id: titleText2
                                    text: shortenedTitle
                                    font.family: fontLoader.name
                                    font.pixelSize: Math.min(searchResulView.height / 20, searchResulView.width / 20)
                                    color: "yellow"
                                    elide: Text.ElideMiddle
                                    verticalAlignment: Text.AlignVCenter
                                    layer.enabled: true
                                    layer.effect: DropShadow {
                                        radius: 5
                                        samples: 40
                                        color: "#f21f25"
                                        horizontalOffset: -4
                                        verticalOffset: 4
                                    }
                                }
                            }
                        }
                    }

                    focus: searchResulFocused
                    onFocusChanged: {
                        if (searchResulView.focus) {
                            searchResulView.currentIndex = 0;
                            updateGameInfo4();
                        }
                    }

                    Keys.onUpPressed: {
                        if (currentIndex > 0) {
                            currentIndex--
                            shiftSound.play();
                            updateGameInfo4();
                        }
                    }

                    Keys.onDownPressed: {
                        if (currentIndex < count - 1) {
                            currentIndex++
                            shiftSound.play();
                            updateGameInfo4();
                        }
                    }

                    Keys.onPressed: {
                        if (api.keys.isAccept(event)) {
                            event.accepted = true;
                            audioPlayer.muted = true;
                            launchSound.play();
                            launchTimer3.start();
                        } else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                            event.accepted = true;
                            selectSound.play();
                            searchResulFocused = false
                            keyboardRetroFocused = true
                        } else if (api.keys.isDetails(event)) {
                            event.accepted = true;
                            favSound.play()
                            var selectedGame = gamesFiltered.get(searchResulView.currentIndex);
                            var selectedTitle = selectedGame.title;
                            var gamesArray = api.allGames.toVarArray();
                            var gameFound = gamesArray.find(function(game) {
                                return game.title === selectedTitle;
                            });
                            if (gameFound) {
                                gameFound.favorite = !gameFound.favorite;
                            } else {
                            }     
                        }
                    }

                    Component.onCompleted: {
                        updateGameInfo4();
                    }

                    onCurrentIndexChanged: {
                        updateGameInfo4();
                    }
                }

                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "transparent"
                    visible: !gamesFiltered.hasResults  
                    
                    Text {
                        text: "No results found of " + searchInput.text
                        color: "white"
                        font.family: fontLoader.name
                        font.pixelSize: 24
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        layer.enabled: true
                        layer.effect: DropShadow {
                            radius: 20
                            samples: 20
                            color: "white"
                            horizontalOffset: -2
                            verticalOffset: 5
                            spread: 0.35
                        }
                    }
                }
            }
            
            Rectangle {
                id: keyboardRetro
                height: parent.height * 0.30 
                width: parent.width * 0.70
                anchors.horizontalCenter: parent.horizontalCenter
                color: "black"
                border.color: "blue"
                border.width: 5
                radius: 40
                
                property int currentIndex: 0

                focus: keyboardRetroFocused

                onFocusChanged: {
                    if (keyboardRetro.focus) {
                        keyboardRetro.currentIndex = 0;
                        updateGameInfo4();
                    }
                }

                Keys.onPressed: {
                    if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                        if (currentIndex < 26) {
                            searchInput.text += String.fromCharCode(97 + currentIndex);
                            selectSound.play();
                        } else if (currentIndex < 36) {
                            searchInput.text += currentIndex - 26;
                            selectSound.play();
                        } else if (currentIndex === 36) {
                            searchInput.text += " ";
                            selectSound.play();
                        } else if (currentIndex === 37) {
                            searchInput.text = searchInput.text.slice(0, -1);
                            selectSound.play();
                        }
                    } else if (event.key === Qt.Key_Right) {
                        currentIndex = (currentIndex + 1) % 38;
                        shiftSound.play();
                    } else if (event.key === Qt.Key_Left) {
                        currentIndex = (currentIndex - 1 + 38) % 38;
                        shiftSound.play();
                    } else if (event.key === Qt.Key_Up) {
                        if (currentIndex >= 0 && currentIndex <= 12) {
                            shiftSound.play();
                            keyboardRetroFocused = false;
                            searchResulFocused = true;
                        } else {
                            currentIndex = (currentIndex - 13 + 38) % 38;
                            shiftSound.play();
                        }
                    } else if (event.key === Qt.Key_Down) {
                        currentIndex = (currentIndex + 13) % 38;
                        shiftSound.play();
                    } else if (!event.isAutoRepeat && api.keys.isCancel(event)) {
                        event.accepted = true;
                        selectSound.play();
                        searchInput.text = "";
                        searchResulView.currentIndex = -1;

                        keyboardRetroVisible = false;
                        keyboardRetroFocused = false;
                        mainMenuVisible = true;
                        rect2.forceActiveFocus();
                    }
                }

                Grid {
                    anchors.centerIn: parent
                    columns: 13
                    rows: 3
                    spacing: 5

                    Repeater {
                        model: ["A","B","C","D","E","F","G","H","I","J","K","L","M",
                                "N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
                                "0", "1", "2", "3", "4", "5", "6", "7", "8", "9","spacing","delete"]

                        delegate: Item {
                            width: keyboardRetro.width / 18
                            height: keyboardRetro.height / 4

                            Component.onCompleted: {
                                if (modelData === "delete" || modelData === "spacing") {
                                    lettersNumbers.visible = false;
                                    icon.visible = true;
                                }
                            }

                            Text {
                                id: lettersNumbers
                                anchors.fill: parent
                                text: modelData
                                font.family: fontLoader.name
                                font.pixelSize: Math.min(keyboardRetro.height / 5, keyboardRetro.width / 2)
                                color: (index === keyboardRetro.currentIndex && keyboardRetroFocused) ? "#fe26d8" : "#fff900"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            Image {
                                id: icon
                                width: lettersNumbers.height -12
                                height: lettersNumbers.height -12
                                source: modelData === "delete" ? 
                                    (index === keyboardRetro.currentIndex && keyboardRetroFocused ? "assets/icons/del_inactive.svg" : "assets/icons/del.svg") :
                                    modelData === "spacing" ?
                                    (index === keyboardRetro.currentIndex && keyboardRetroFocused ? "assets/icons/spacebar_inactive.svg" : "assets/icons/spacebar.svg") : ""
                                visible: false
                            }

                            layer.enabled: true
                            layer.effect: DropShadow {
                                radius: 5
                                samples: 40
                                color: "#f21f25"
                                horizontalOffset: -4
                                verticalOffset: 4
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: infoGames4
            height: parent.height * 0.05
            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: searchGamesConteiner.bottom 
            anchors.topMargin: 5 
            visible: searchResulFocused
            color: "transparent"

            Text {
                id: gameInfoText5
                color: "white"
                font.pixelSize: infoGames4.height * 0.60
                font.family: fontLoader2.name
                horizontalAlignment: Text.AlignHCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 1
                minimumPixelSize: 35
                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 20
                    samples: 20
                    color: "#fe31f9"
                    horizontalOffset: -2
                    verticalOffset: 5
                    spread: 0.35
                }
            }
        }
    }

    Image {
        id: overlayImage
        source: "assets/overlay/overlay0.png"
        anchors.fill: parent
    }

    Keys.onReleased: (event) => {
        if (api.keys.isNextPage(event)) {
            if (currentBackgroundIndex < maxBackgroundIndex) {
                currentBackgroundIndex++;
            } else {
                currentBackgroundIndex = 0;
            }
            updateBackground();
            api.memory.set('lastBackgroundIndex', currentBackgroundIndex);
            changeGifSound.play();
        } else if (api.keys.isPrevPage(event)) {
            if (currentOverlayIndex < maxOverlayIndex) {
                currentOverlayIndex++;
            } else {
                currentOverlayIndex = 0;
            }
            updateOverlay();
            api.memory.set('lastOverlayIndex', currentOverlayIndex);
            changeGifSound.play();
        }
    }

    Rectangle {
        id: rect5
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 27
        height: parent.height * 0.20
        width: parent.width * 0.14
        color: "transparent"

        Item {
            anchors.fill: parent

            Column {
                anchors.bottom: parent.bottom
                spacing: 5

                Row {
                    spacing: 10
                    Image {
                        source: "assets/icons/A.svg"
                        width: okText.font.pixelSize +5
                        height: okText.font.pixelSize +5
                    }
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 5
                        samples: 40
                        color: "#f21f25"
                        horizontalOffset: -4
                        verticalOffset: 4
                    }
                    Text {
                        id: okText
                        text: "SELECT"
                        color: "#fff900"
                        font.family: fontLoader.name
                        font.bold: true
                        font.pixelSize: Math.min(rect5.width * 0.1, rect5.height * 0.2)
                    }
                }

                Row {
                    spacing: 10
                    Image {
                        id: iconB
                        source: "assets/icons/B.svg"
                        width: backText.font.pixelSize +5
                        height: backText.font.pixelSize +5
                        visible: !mainMenuVisible
                    }
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 5
                        samples: 40
                        color: "#f21f25"
                        horizontalOffset: -4
                        verticalOffset: 4
                    }
                    Text {
                        id: backText
                        text: "BACK"
                        color: "#fff900"
                        font.family: fontLoader.name
                        font.bold: true
                        font.pixelSize: Math.min(rect5.width * 0.1, rect5.height * 0.2)
                        visible: !mainMenuVisible
                    }
                }

                Row {
                    spacing: 10
                    Image {
                        source: "assets/icons/X.svg"
                        width: favText.font.pixelSize +5
                        height: favText.font.pixelSize +5
                        visible: !mainMenuVisible
                    }
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 5
                        samples: 40
                        color: "#f21f25"
                        horizontalOffset: -4
                        verticalOffset: 4
                    }
                    Text {
                        id: favText
                        text: "FAVORITE"
                        color: "#fff900"
                        font.family: fontLoader.name
                        font.bold: true
                        font.pixelSize: Math.min(rect5.width * 0.1, rect5.height * 0.2)
                        visible: !mainMenuVisible
                    }
                }
            }
        }

    }

    Rectangle {
        id: rect6
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 27
        anchors.leftMargin: 7
        height: parent.height * 0.20
        width: parent.width * 0.14
        color: "transparent"

        Item {
            anchors.fill: parent

            Column {
                anchors.bottom: parent.bottom
                spacing: 10

                Row {
                    spacing: 5

                    Image {
                        id: icon1
                        source: "assets/LB&RB/left.png"
                        width: okText1.font.pixelSize * 2.00
                        height: okText1.font.pixelSize * 1.0
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10
                    }

                    Text {
                        id: okText1
                        text: " OVERLAY"
                        color: "#fff900"
                        font.family: fontLoader.name
                        font.bold: true
                        font.pixelSize: Math.min(rect6.width * 0.07, rect6.height * 0.2)
                        layer.enabled: true
                        layer.effect: DropShadow {
                            radius: 5
                            samples: 40
                            color: "#f21f25"
                            horizontalOffset: -4
                            verticalOffset: 4
                        }
                    }
                }

                Row {
                    spacing: 5

                    Image {
                        id: icon2
                        source: "assets/LB&RB/right.png"
                        width: okText1.font.pixelSize * 2.00
                        height: okText1.font.pixelSize * 1.0
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 10 
                    }

                    Text {
                        id: backText1
                        text: " BACKGROUND"
                        color: "#fff900"
                        font.family: fontLoader.name
                        font.bold: true
                        font.pixelSize: Math.min(rect6.width * 0.07, rect6.height * 0.2)
                        layer.enabled: true
                        layer.effect: DropShadow {
                            radius: 5
                            samples: 40
                            color: "#f21f25"
                            horizontalOffset: -4
                            verticalOffset: 4
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        currentBackgroundIndex = api.memory.get('lastBackgroundIndex') || 0;
        currentOverlayIndex = api.memory.get('lastOverlayIndex') || 0;
        updateBackground();
        updateOverlay();
        rect1.forceActiveFocus();
    }
}
