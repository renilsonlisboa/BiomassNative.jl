module BiomassNative

# Importa os pacotes utilizados para desenvolvimento e funcionamento do programa
import QML: QString, @qmlfunction, loadqml, exec
using LinearAlgebra
using Statistics
import Plots: scatter, plot!, savefig

# Exporta a função Inventory possibilitando ser chamada via terminal pelo usuário
export CalcBiomass

    # Define a função de ajuste de equação
    function ajustarEq(Dados, save, nivel)
        # Converte o vetor de dados de QVariat para um Vetor de Strings do Julia
        Dados = convert.(Vector{String}, Dados)

        # Converte o vetor de dados em duas variáveis
        DAP = Meta.parse.(Dados[1])
        B = Meta.parse.(Dados[2])

        # Confere se o URL para salvar o resultado é diferente de nulo
        if save !== nothing
            save_s = QString(save)
        else
            return 0
        end

        # Remover o prefixo "file:///"
        cleaned_path = replace(save_s, "file:///" => "")

        # Remove o sufixo da URL (extensão caso selecionada)
        cleaned_path = split(cleaned_path, ".")[1]

        # Inícia as variáveis em um escopo superior
        b = nothing
        Bhat = nothing

        # Ajuste das equações a nível de Tipologia Florestal
        if nivel == 0
            Bfixo=[-2.1346; 2.3477]
            D=[0.1737 -0.0799; -0.0799 0.0406]
            R = [0.1612]
            #Bfixo[1] = Bfixo[1] + R[1]/2
            n=size(DAP,1)
            R=diagm(repeat(R, inner = n))
            Z= log.(DAP)
            Z=[ones(n) Z]
            yhat = Z*Bfixo
            RES=log.(B).-yhat
            b=D*Z'*inv(Z*D*Z'+R)*RES
            Bhat=Bfixo+b
            Bhat[1] = Bhat[1] + (R[1,1])
            x0= 5:0.001:45
            xGrid = [ones(size(x0,1)) x0]
            xGridt = [ones(size(x0,1)) log.(x0)]
            yestimado = xGridt*Bhat
            yestimado = exp.(yestimado)

        # Ajuste das equações a nível de Floresta
        elseif nivel == 1
            Bfixo=[-1.7698; 2.2003]
            D=[0.3263 -0.1483; -0.1483 0.0668]
            R =[0.1575]
            n=size(DAP,1)
            R=diagm(repeat(R, inner = n))
            Z= log.(DAP)
            Z=[ones(n) Z]
            yhat = Z*Bfixo
            RES=log.(B)-yhat
            b=D*Z'*inv(Z*D*Z'+R)*RES
            Bhat=Bfixo+b
            Bhat[1] = Bhat[1] + (R[1,1])
            x0= 5:0.001:45
            xGrid = [ones(size(x0,1)) x0]
            xGridt = [ones(size(x0,1)) log.(x0)]
            yestimado = xGridt*Bhat
            yestimado = exp.(yestimado)
        else
            return 0
        end

        # Gerá os gráficos com os paramêtros selecionados
        plt = scatter(DAP, B, xlabel = "Diâmetro à altura do peito (cm)", ylabel = "Biomassa (Kg)", grid_linewidth = 0, color = "green", label = false)
        plt = plot!(xGrid[:, 2], yestimado, label = false) 

        # Apresenta o gráfico de resutados
        display(plt)

        # Salva o gráfico atribuido ao plt
        savefig("$(cleaned_path).png")

        # Retorna os valores de b e Bhat
        return [round.(b, digits = 4), round.(Bhat, digits = 4)]
    end

    # Ativa o programa em QML
    function CalcBiomass()
        # Exporta as funções definidas em Julia para o arquivo .QML
        @qmlfunction ajustarEq

        # Atribui o diretório atual dos arquivos a uma variável
        current_directory = dirname(@__FILE__)

        # Carrega o arquivo .qml localizado no diretório atual
        loadqml(joinpath(current_directory, "src/qml", "main.qml"))

        # Executa o arquivo .QML localizado e carregado anteriormente
        exec()
    end
end
