module ImportData

import QML: QString
import DataFrames: DataFrame
import CSV: CSV.read

export singlefile
    
    function singlefile(uri)
        
        if uri !== nothing
            uri_s = QString(uri)
        else
            return 0
        end

        # Remover o prefixo "file:///"
        cleaned_path = replace(uri_s, "file:///" => "")
    
        Dados = read("$cleaned_path", DataFrame)

        return Dados

    end

end