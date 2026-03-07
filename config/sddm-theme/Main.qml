import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    anchors.fill: parent
    width: Screen.width
    height: Screen.height

    // Dynamic scale factor based on screen height (1080p = 1.0, 4K = 2.0)
    property real scaleFactor: Screen.height / 1080

    property string accentColor: "#cdd6f4"
    property string backgroundColor: "#1e1e2e"
    property string foregroundColor: "#cdd6f4"
    property string errorColor: "#f38ba8"
    property string successColor: "#a6e3a1"

    // Background Image
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.Background || ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // Background blur overlay
    FastBlur {
        anchors.fill: backgroundImage
        source: backgroundImage
        radius: 50 * scaleFactor
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

        // Login container with background - centered on screen
        Rectangle {
            id: loginBox
            width: 380 * scaleFactor
            height: loginContent.height + 60 * scaleFactor
            radius: 16 * scaleFactor
            color: backgroundColor
            opacity: 0.85
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            // Subtle border
            border.color: Qt.darker(accentColor, 1.3)
            border.width: 2 * scaleFactor

            // Content column inside the container
            Column {
                id: loginContent
                anchors.centerIn: parent
                spacing: 20 * scaleFactor

                // User avatar
                Rectangle {
                    id: avatarContainer
                    width: 98 * scaleFactor
                    height: 98 * scaleFactor
                    radius: 60 * scaleFactor
                    color: backgroundColor
                    border.color: accentColor
                    border.width: 3 * scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: userAvatar
                        anchors.fill: parent
                        anchors.margins: 3 * scaleFactor
                        source: config.Avatar || ""
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
                    font.pixelSize: 24 * scaleFactor
                    font.family: "JetBrainsMono Nerd Font"
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Login input container
                Rectangle {
                    id: loginContainer
                    width: 320 * scaleFactor
                    height: 50 * scaleFactor
                    radius: 8 * scaleFactor
                    color: Qt.darker(backgroundColor, 1.2)
                    border.color: passwordField.focus ? accentColor : Qt.darker(accentColor, 1.5)
                    border.width: 2 * scaleFactor
                    anchors.horizontalCenter: parent.horizontalCenter

                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 5 * scaleFactor
                        placeholderText: "Password..."
                        placeholderTextColor: Qt.darker(foregroundColor, 1.5)
                        echoMode: TextInput.Password
                        color: foregroundColor
                        font.pixelSize: 14 * scaleFactor
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
                    width: 100 * scaleFactor
                    height: 40 * scaleFactor
                    radius: 8 * scaleFactor
                    color: mouseArea.containsMouse ? Qt.lighter(accentColor, 1.1) : accentColor
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "Login"
                        color: backgroundColor
                        font.pixelSize: 14 * scaleFactor
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
                    font.pixelSize: 12 * scaleFactor
                    font.family: "JetBrainsMono Nerd Font"
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: text !== ""
                }
            }
        }

        // Session selector (small, bottom left)
        ComboBox {
            id: sessionSelector
            width: 150 * scaleFactor
            height: 30 * scaleFactor
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.margins: 30 * scaleFactor
            model: sessionModel
            currentIndex: sessionModel.lastIndex
            textRole: "name"

            background: Rectangle {
                color: backgroundColor
                radius: 5 * scaleFactor
                opacity: 0.8
            }

            contentItem: Text {
                text: sessionSelector.displayText
                color: foregroundColor
                font.pixelSize: 11 * scaleFactor
                font.family: "JetBrainsMono Nerd Font"
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10 * scaleFactor
            }
        }

        // Linux logo at bottom center (styled like Ubuntu)
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40 * scaleFactor
            spacing: 8 * scaleFactor

            // Tux/Linux icon using Nerd Font
            Text {
                id: linuxLogo
                text: "\uf17c"  // Linux Tux icon from Nerd Fonts
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 48 * scaleFactor
                color: foregroundColor
                anchors.horizontalCenter: parent.horizontalCenter
                opacity: 0.9
            }

            // NixOS text
            Text {
                text: "NixOS"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16 * scaleFactor
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
            anchors.margins: 30 * scaleFactor
            spacing: 15 * scaleFactor

            // Reboot
            Rectangle {
                width: 40 * scaleFactor
                height: 40 * scaleFactor
                radius: 20 * scaleFactor
                color: rebootMouse.containsMouse ? Qt.lighter(backgroundColor, 1.3) : backgroundColor
                opacity: 0.8

                Text {
                    anchors.centerIn: parent
                    text: "\uf021"  // Reboot icon
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18 * scaleFactor
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
                width: 40 * scaleFactor
                height: 40 * scaleFactor
                radius: 20 * scaleFactor
                color: shutdownMouse.containsMouse ? Qt.lighter(backgroundColor, 1.3) : backgroundColor
                opacity: 0.8

                Text {
                    anchors.centerIn: parent
                    text: "\uf011"  // Power icon
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18 * scaleFactor
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
            anchors.margins: 30 * scaleFactor
            color: foregroundColor
            font.pixelSize: 14 * scaleFactor
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
