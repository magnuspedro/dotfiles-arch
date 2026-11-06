/*
    Splash Gruvbox Dark: fundo #282828, logo do Arch em amarelo e barra de progresso.
    Baseado na estrutura do splash do Breeze (property int stage, de 1 a 6).
*/

import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    id: root
    color: "#282828"

    property int stage

    onStageChanged: {
        if (stage == 2) {
            introAnimation.running = true;
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        Image {
            id: logo
            readonly property real size: Kirigami.Units.gridUnit * 8

            anchors.centerIn: parent
            asynchronous: true
            source: "images/arch.svg"
            sourceSize.width: size
            sourceSize.height: size
        }

        // trilho e progresso: avança a cada estágio da inicialização
        Rectangle {
            id: track
            width: Kirigami.Units.gridUnit * 12
            height: Math.max(2, Kirigami.Units.gridUnit * 0.25)
            radius: height / 2
            color: "#3c3836"
            anchors.horizontalCenter: parent.horizontalCenter
            y: logo.y + logo.height + Kirigami.Units.gridUnit * 3

            Rectangle {
                height: parent.height
                radius: parent.radius
                color: "#fabd2f"
                width: parent.width * Math.min(root.stage, 6) / 6

                Behavior on width {
                    NumberAnimation {
                        duration: Kirigami.Units.veryLongDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: Kirigami.Units.veryLongDuration * 2
        easing.type: Easing.InOutQuad
    }
}
