module Save
        
    # Ativa os pacotes usados para a função saveFile funcionar
    import QML: QString
    import DataFrames: DataFrame, eachcol, names
    import CSV: CSV.read
    import XLSX: XLSX.writetable 

    # Exporta as funções definidas nesse módulo
    export saveFile

    # Define a função  saveFile usada para salvar o arquivo de resultado
    function saveFile(Dados, uri)
        
        if uri !== nothing
            uri_s = QString(uri)
        else
            return 0
        end

        # Converte a entrada em QString do QML em String do Julia
        uri_s = QString(uri)

        # Remover o prefixo "file:///"
        cleaned_path = replace(uri_s, "file:///" => "")

        # Salva a tabela de resultado no PATH selecionado pelo usuário
        writetable("$(cleaned_path).xlsx",Resultados=(collect(eachcol(Dados)), names(Dados)), overwrite = true) #Exportar para o Excel
    
    end

end