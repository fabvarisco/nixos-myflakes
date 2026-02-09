import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height

    property string accentColor: "#cdd6f4"
    property string backgroundColor: "#1e1e2e"
    property string foregroundColor: "#cdd6f4"
    property string errorColor: "#f38ba8"
    property string successColor: "#a6e3a1"

    // Background Image
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.Background || "/home/fabvarisco/.config/walls/lock.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // Background blur overlay
    FastBlur {
        anchors.fill: backgroundImage
        source: backgroundImage
        radius: 50
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.4
    }

    // Main content
    Item {
        anchors.fill: parent

        // User avatar
        Rectangle {
            id: avatarContainer
            width: 120
            height: 120
            radius: 60
            color: backgroundColor
            border.color: accentColor
            border.width: 3
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: parent.height * 0.25

            Image {
                id: userAvatar
                anchors.fill: parent
                anchors.margins: 3
                source: "/home/fabvarisco/.config/walls/profile.png"
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: userAvatar.width
                        height: userAvatar.height
                        radius: width / 2
                    }
                }
            }
        }

        // Username label
        Text {
            id: usernameLabel
            text: userModel.lastUser || "User"
            color: foregroundColor
            font.pixelSize: 24
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: avatarContainer.bottom
            anchors.topMargin: 20
        }

        // Login container
        Rectangle {
            id: loginContainer
            width: 320
            height: 50
            radius: 8
            color: backgroundColor
            border.color: passwordField.focus ? accentColor : Qt.darker(accentColor, 1.5)
            border.width: 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: usernameLabel.bottom
            anchors.topMargin: 30

            TextField {
                id: passwordField
                anchors.fill: parent
                anchors.margins: 5
                placeholderText: "Password..."
                placeholderTextColor: Qt.darker(foregroundColor, 1.5)
                echoMode: TextInput.Password
                color: foregroundColor
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                background: Rectangle {
                    color: "transparent"
                }

                Keys.onReturnPressed: {
                    sddm.login(userModel.lastUser, passwordField.text, sessionModel.lastIndex)
                }
            }
        }

        // Login button
        Rectangle {
            id: loginButton
            width: 100
            height: 40
            radius: 8
            color: mouseArea.containsMouse ? Qt.lighter(accentColor, 1.1) : accentColor
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: loginContainer.bottom
            anchors.topMargin: 20

            Text {
                anchors.centerIn: parent
                text: "Login"
                color: backgroundColor
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                font.bold: true
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    sddm.login(userModel.lastUser, passwordField.text, sessionModel.lastIndex)
                }
            }
        }

        // Error message
        Text {
            id: errorMessage
            text: ""
            color: errorColor
            font.pixelSize: 12
            font.family: "JetBrainsMono Nerd Font"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: loginButton.bottom
            anchors.topMargin: 15
            visible: text !== ""
        }

        // Session selector (small, bottom left)
        ComboBox {
            id: sessionSelector
            width: 150
            height: 30
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 30
            model: sessionModel
            currentIndex: sessionModel.lastIndex
            textRole: "name"

            background: Rectangle {
                color: backgroundColor
                radius: 5
                opacity: 0.8
            }

            contentItem: Text {
                text: sessionSelector.displayText
                color: foregroundColor
                font.pixelSize: 11
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
        }

        // Linux logo at bottom center (styled like Ubuntu)
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            spacing: 8

            // Tux/Linux icon using Nerd Font
            Text {
                id: linuxLogo
                text: "\uf17c"  // Linux Tux icon from Nerd Fonts
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 48
                color: foregroundColor
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.9
            }

            // NixOS text
            Text {
                text: "NixOS"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                font.bold: true
                color: foregroundColor
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.8
            }
        }

        // Power buttons (right side)
        Row {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 30
            spacing: 15

            // Reboot
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: rebootMouse.containsMouse ? Qt.lighter(backgroundColor, 1.3) : backgroundColor
                opacity: 0.8

                Text {
                    anchors.centerIn: parent
                    text: "\uf021"  // Reboot icon
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: foregroundColor
                }

                MouseArea {
                    id: rebootMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.reboot()
                }
            }

            // Shutdown
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: shutdownMouse.containsMouse ? Qt.lighter(backgroundColor, 1.3) : backgroundColor
                opacity: 0.8

                Text {
                    anchors.centerIn: parent
                    text: "\uf011"  // Power icon
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: foregroundColor
                }

                MouseArea {
                    id: shutdownMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.powerOff()
                }
            }
        }

        // Clock (top right)
        Text {
            id: clock
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 30
            color: foregroundColor
            font.pixelSize: 14
            font.family: "JetBrainsMono Nerd Font"
            opacity: 0.8

            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var date = new Date()
                    clock.text = Qt.formatDateTime(date, "ddd, dd MMM yyyy  HH:mm")
                }
            }
        }
    }

    // Handle login result
    Connections {
        target: sddm
        function onLoginSucceeded() {
            errorMessage.text = ""
        }
        function onLoginFailed() {
            errorMessage.text = "Login failed. Please try again."
            passwordField.text = ""
            passwordField.focus = true
        }
    }

    // Focus password field on load
    Component.onCompleted: {
        passwordField.forceActiveFocus()
    }
}
