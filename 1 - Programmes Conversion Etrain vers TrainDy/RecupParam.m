function param = RecupParam(nomParamEtrain, nomParamTrainDy,type,nomFichierLecture)
            cline = trova_info(nomParamEtrain,nomFichierLecture);
            %Si l'info est trouv�
            if not(isempty(cline))
                %Si le parametre est un float
                if (strcmp(type,'float'))
                    param = str2double(cline(numel(nomParamEtrain)+1:end));
                %Si le parametre est une string
                elseif (strcmp(type,'string'))
                    param = strtrim(cline(numel(nomParamEtrain)+1:end));
                end
                    
            else
                param = [];
                disp(sprintf(['Erreur : ' nomParamTrainDy ' non d�fini']))
            end