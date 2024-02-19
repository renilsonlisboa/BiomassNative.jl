import QtQuick
import QtQuick.Controls
import QtQuick.Layouts 
import QtQuick.Dialogs 
import org.julialang

ApplicationWindow {
    width: 640
    height: 480
    title: "Biomass Native"
    x: (Screen.width - width) / 2 // Centralizar horizontalmente
    y: (Screen.height - height) / 2 // Centralizar verticalmente
    minimumWidth: 640
    maximumWidth: 640
    minimumHeight: 480
    maximumHeight: 480
    visible: true

    // Define as váriveis globais para uso no APP
    property string conclusionText: "" // Nova propriedade para armazenar o texto do resultado
    property var bfixo: [1.0, 2.0] // Nova propriedade para armazenar o texto do resultado
    property var best: [1.0, 2.0] // Nova propriedade para armazenar o texto do resultado
    property var columnVectorsVals: []
    
    Rectangle {
        id: retangulo
        width: parent.width
        height: parent.height
        visible: true

        Image {
            id: backgroundImage
            source: "images/wallpaper.jpg"
            width: retangulo.width
            height: retangulo.height // Substitua pelo caminho real da sua imagem
            fillMode: Image.Stretch
        }

        ComboBox {
            id: comboBox
            anchors.centerIn: parent
            width: 500
            height: 30
            currentIndex: 0

            // Adicionar 10 opções ao ComboBox
            model: ListModel {
                id: model
                ListElement {
                    text: "Tipologia Florestal"
                }
                ListElement {
                    text: "Floresta"
                }
            }

            contentItem: Text {
                text: "Nível: " + comboBox.currentText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 14
                font.family: "Arial"
            }

            delegate: ItemDelegate {
                width: comboBox.width
                height: comboBox.height

                contentItem: Text {
                    text: model.text
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 14
                    font.family: "Arial"
                    padding: 10
                }
            }
        }

        Button {
            id: processInvent
            text: qsTr("Selecionar Nível de Ajuste")
            width: 275
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 100

            Connections {
                target: processInvent
                onClicked: {
                    if (comboBox.currentIndex === 0) {
                        tipologiaFlorestal.visible = true
                    } else if (comboBox.currentIndex === 1) {
                        floresta.visible = true
                    } else {
                        Qt.quit()
                    }
                }
            }

            contentItem: Text {
                text: processInvent.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pointSize: 14
                font.family: "Arial"
            }
        }

        Window {
            id: tipologiaFlorestal
            title: "Ajuste de Equação a Nível de Tipologia Florestal"
            width: 640
            height: 480
            x: (Screen.width - width) / 2 // Centralizar horizontalmente
            y: (Screen.height - height) / 2 // Centralizar verticalmente
            minimumWidth: 640
            maximumWidth: 640
            minimumHeight: 480
            maximumHeight: 480
            visible: false

            Rectangle {
                id: rectanglebase
                width: parent.width
                height: parent.height
                visible: true

                Image {
                    id: backgroundImagetipologia
                    source: "images/wallpaper.jpg"
                    width: rectanglebase.width
                    height: rectanglebase.height // Substitua pelo caminho real da sua imagem
                    fillMode: Image.Stretch
                }

                ComboBox {
                    id: comboBox2
                    anchors.centerIn: rectanglebase
                    width: 500
                    height: 30
                    anchors.verticalCenterOffset: -150
                    currentIndex: 0

                    // Adicionar as opções de Tipos de Amostragem
                    model: ListModel {
                        id: model2
                        ListElement {
                            text: "A2"
                        }
                        ListElement {
                            text: "A3"
                        }
                        ListElement {
                            text: "A5"
                        }
                    }

                    contentItem: Text {
                        text: "Nível: " + comboBox2.currentText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 14
                        font.family: "Arial"
                    }

                    delegate: ItemDelegate {
                        width: comboBox2.width
                        height: comboBox2.height

                        contentItem: Text {
                            text: model.text
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: 14
                            font.family: "Arial"
                            padding: 10
                        }
                    }
                }

                Grid {
                    id: inputDataTipologia
                    columns: 2
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -20
                    spacing: 15

                    // Adicione 18 campos de entrada (TextField)
                    Repeater {
                        model: (comboBox2.currentIndex % 2 === 0) ? 2 : 6
                        TextField {
                            placeholderText: (index % 2 === 0) ? "Dap (cm)" : (index % 2 === 1) ? "Biomassa (Kg)" : ""
                            horizontalAlignment: Text.AlignHCenter
                            width: 180
                            height: 30
                            font.pointSize: 14
                            validator: RegularExpressionValidator{
                                regularExpression: /^\d*\.?\d+(,\d+)?$/
                            }

                            Connections {
                                onTextChanged: {
                                    if (text.includes(",")) {
                                        text = text.replace(/,/g, ".")
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    id: processtipoFlorestal
                    text: qsTr("Ajustar Equação")
                    width: 300
                    font.family: "Arial"
                    font.pointSize: 14
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 120

                    Connections {
                        target: processtipoFlorestal
                        onClicked: {
                            busyIndicatorTipologia.running = true

                            var columnVectors = []

                            // Inicializa vetores para cada coluna
                            for (var i = 0; i < inputDataTipologia.columns; i++) {
                                columnVectors.push([])
                            }

                            // Itera pelos filhos do GridLayout
                            for (var j = 0; j < inputDataTipologia.children.length; j++) {
                                // Adiciona os valores dos TextField aos vetores correspondentes
                                if (inputDataTipologia.children[j] instanceof TextField) {
                                    var columnIndex = j % inputDataTipologia.columns
                                    var textValue = inputDataTipologia.children[j].text.trim(
                                                )
                                    // Remove espaços em branco

                                    // Verifica se o valor é vazio ou nulo
                                    if (textValue === "") {
                                        emptyDialogTipoFlorestal.open()
                                        busyIndicatorTipologia.running = false
                                        return
                                        // Aborta o processamento se dados estiverem faltando
                                    }

                                    columnVectors[columnIndex].push(textValue)
                                }
                            }
                            columnVectorsVals = columnVectors
                            saveDialogTipoFlorestal.open()
                        }
                    }
                }
            }

            BusyIndicator {
                id: busyIndicatorTipologia
                width: 90
                height: 90
                running: false
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 190
            }

            // Dialogo para seleção do local de salvamento dos arquivos de resultado
            FileDialog {
                id: saveDialogTipoFlorestal
                title: "Selecione o local para salvar o arquivo..."
                fileMode: FileDialog.SaveFile

                Connections {
                    target: saveDialogTipoFlorestal
                    onAccepted: {
                        var resultado = Julia.ajustarEq(columnVectorsVals, saveDialogTipoFlorestal.selectedFile, comboBox.currentIndex)

                        bfixo = resultado[0]
                        best = resultado[1]

                        conclusionDialogTipoFlorestal.open()

                        busyIndicatorTipologia.running = false
                    }
                    onRejected: {
                        busyIndicatorTipologia.running = false
                    }
                }

                Component.onCompleted: visible = false
            }

            // Dialogo de conclusão do processamento
            MessageDialog {
                id: conclusionDialogTipoFlorestal
                title: "Calibração Concluída com Sucesso"
                buttons: MessageDialog.Ok
                text: "Coeficientes estimados, parte aleatória \nb0 = " + bfixo[0] + "\nb1 = "
                + bfixo[1] + "\n\nCoeficientes calibrados \nβ0 = " + best[0] + "\nβ1 = " + best[1]
            }

            // Dialogo de FALTA DE DADOS
            MessageDialog {
                id: emptyDialogTipoFlorestal
                title: "Dados insuficientes para Calibração"
                text: "Os dados informados são insuficientes para a calibração.\nPreencha todos os campos e tente novamente."
                buttons: MessageDialog.Ok
            }

            Connections {
                target: tipologiaFlorestal
                onClosing: {
                    for (var i = 0; i < inputDataTipologia.columns; i++) {
                        for (var j = 0; j < inputDataTipologia.children.length; j++) {
                            if (inputDataTipologia.children[j] instanceof TextField) {
                                inputDataTipologia.children[j].text = ""
                            }
                        }
                    }
                    comboBox2.currentIndex = 0
                }
            }
        }

        Window {
            id: floresta
            title: "Ajuste de Equação a Nível de Floresta"
            width: 640
            height: 480
            x: (Screen.width - width) / 2 // Centralizar horizontalmente
            y: (Screen.height - height) / 2 // Centralizar verticalmente
            minimumWidth: 640
            maximumWidth: 640
            minimumHeight: 480
            maximumHeight: 480
            visible: false

            Rectangle {
                id: rectanglebaseFloresta
                width: parent.width
                height: parent.height
                visible: true

                Image {
                    id: backgroundImageFloresta
                    source: "images/wallpaper.jpg"
                    width: rectanglebaseFloresta.width
                    height: rectanglebaseFloresta.height // Substitua pelo caminho real da sua imagem
                    fillMode: Image.Stretch
                }

                ComboBox {
                    id: comboBoxFloresta
                    anchors.centerIn: rectanglebaseFloresta
                    width: 500
                    height: 30
                    anchors.verticalCenterOffset: -150
                    currentIndex: 0

                    // Adicionar as opções de Tipos de Amostragem
                    model: ListModel {
                        id: model3
                        ListElement {
                            text: "A2"
                        }
                        ListElement {
                            text: "A3"
                        }
                        ListElement {
                            text: "A5"
                        }
                    }

                    contentItem: Text {
                        text: "Nível: " + comboBoxFloresta.currentText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 14
                        font.family: "Arial"
                    }

                    delegate: ItemDelegate {
                        width: comboBoxFloresta.width
                        height: comboBoxFloresta.height

                        contentItem: Text {
                            text: model.text
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pointSize: 14
                            font.family: "Arial"
                            padding: 10
                        }
                    }
                }

                Grid {
                    id: inputDataFloresta
                    columns: 2
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -20
                    spacing: 15

                    // Adicione 18 campos de entrada (TextField)
                    Repeater {
                        model: (comboBoxFloresta.currentIndex % 2 === 0) ? 2 : 6
                        TextField {
                            placeholderText: (index % 2 === 0) ? "Dap (cm)" : (index % 2 === 1) ? "Biomassa (Kg)" : ""
                            horizontalAlignment: Text.AlignHCenter
                            width: 180
                            height: 30
                            font.pointSize: 14
                            validator: RegularExpressionValidator{
                                regularExpression: /^\d*\.?\d+(,\d+)?$/
                            }

                            Connections {
                                onTextChanged: {
                                    if (text.includes(",")) {
                                        text = text.replace(/,/g, ".")
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    id: processFloresta
                    text: qsTr("Ajustar Equação")
                    width: 300
                    font.family: "Arial"
                    font.pointSize: 14
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: 120

                    Connections {
                        target: processFloresta
                        onClicked: {
                            busyIndicatorFloresta.running = true
                            var columnVectors = []

                            // Inicializa vetores para cada coluna
                            for (var i = 0; i < inputDataFloresta.columns; i++) {
                                columnVectors.push([])
                            }

                            // Itera pelos filhos do GridLayout
                            for (var j = 0; j < inputDataFloresta.children.length; j++) {
                                // Adiciona os valores dos TextField aos vetores correspondentes
                                if (inputDataFloresta.children[j] instanceof TextField) {
                                    var columnIndex = j % inputDataFloresta.columns
                                    var textValue = inputDataFloresta.children[j].text.trim(
                                                )
                                    // Remove espaços em branco

                                    // Verifica se o valor é vazio ou nulo
                                    if (textValue === "") {
                                        emptyDialogFloresta.open()
                                        busyIndicatorFloresta.running = false
                                        return
                                        // Aborta o processamento se dados estiverem faltando
                                    }

                                    columnVectors[columnIndex].push(textValue)
                                }
                            }
                            columnVectorsVals = columnVectors
                            saveDialogFloresta.open()
                        }
                    }
                }
            }

           BusyIndicator {
                id: busyIndicatorFloresta
                width: 90
                height: 90
                running: false
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 190
            }

            // Dialogo para seleção do local de salvamento dos arquivos de resultado
            FileDialog {
                id: saveDialogFloresta
                title: "Selecione o local para salvar o arquivo..."
                fileMode: FileDialog.SaveFile

                Connections {
                    target: saveDialogFloresta
                    onAccepted: {

                        var resultado = Julia.ajustarEq(columnVectorsVals, saveDialogTipoFlorestal.selectedFile, comboBox.currentIndex)

                        bfixo = resultado[0]
                        best = resultado[1]

                        conclusionDialogFloresta.open()

                        busyIndicatorFloresta.running = false
                    }
                    onRejected: {
                        busyIndicatorFloresta.running = false
                    }
                }

                Component.onCompleted: visible = false
            }

            // Dialogo de conclusão do processamento
            MessageDialog {
                id: conclusionDialogFloresta
                title: "Calibração Concluída com Sucesso"
                buttons: MessageDialog.Ok
                text: "Coeficientes estimados, parte aleatória \nb0 = " + bfixo[0] + "\nb1 = "
                + bfixo[1] + "\n\nCoeficientes calibrados \nβ0 = " + best[0] + "\nβ1 = " + best[1]
            }

            // Dialogo de FALTA DE DADOS
            MessageDialog {
                id: emptyDialogFloresta
                title: "Dados insuficientes para Calibração"
                text: "Os dados informados são insuficientes para a calibração.\nPreencha todos os campos e tente novamente."
                buttons: MessageDialog.Ok
            }

            Connections {
                target: floresta
                onClosing: {
                    for (var i = 0; i < inputDataFloresta.columns; i++) {
                        for (var j = 0; j < inputDataFloresta.children.length; j++) {
                            if (inputDataFloresta.children[j] instanceof TextField) {
                                inputDataFloresta.children[j].text = ""
                            }
                        }
                    }
                    comboBoxFloresta.currentIndex = 0
                }
            }
        }
    }
}
