function ligne = creerLigneTableau(vecteur,typeDonnees,titre,sep,avecSautDeLigne)

ligne = [titre '='];
switch typeDonnees
    case 'float'
        if(length(vecteur)>1)
            for(i=1:length(vecteur)-1)
                ligne = [ligne num2str(vecteur(i)) sep];
            end
        end
        if(avecSautDeLigne)
            ligne = [ligne num2str(vecteur(end)) '\r\n'];
        else
            ligne = [ligne num2str(vecteur(end))];
        end
    case 'float1decimaleMini'
        if(length(vecteur)>1)
            for(i=1:length(vecteur)-1)
                A = sscanf(num2str(vecteur(i)),['%li' '.' '%li']);
                if((length(A)==1))
                    ligne = [ligne num2str(vecteur(i),'%14.1f') sep];
                else
                    ligne = [ligne num2str(vecteur(i)) sep];
                end
            end
        end
        if(avecSautDeLigne)
            A = sscanf(num2str(vecteur(end)),['%li' '.' '%li']);
            if((length(A)==1))
                ligne = [ligne num2str(vecteur(end),'%14.1f') '\r\n'];
            else
                ligne = [ligne num2str(vecteur(end)) '\r\n'];
            end
        else
            A = sscanf(num2str(vecteur(end)),['%li' '.' '%li']);
            if((length(A)==1))
                ligne = [ligne num2str(vecteur(end),'%14.1f')];
            else
                ligne = [ligne num2str(vecteur(end))];
            end
        end
        
        
    case 'bool'
        if(length(vecteur)>1)
            for(i=1:length(vecteur)-1)
                ligne = [ligne btos(vecteur(i)) sep];
            end
        end
        if(avecSautDeLigne)
            ligne = [ligne btos(vecteur(end)) '\r\n'];
        else
            ligne = [ligne btos(vecteur(end))];
        end
    case 'string'
        if(length(vecteur)>1)
            for(i=1:length(vecteur)-1)
                ligne = [ligne char(vecteur(i)) sep];
            end
        end
        ligne = [ligne char(vecteur(end))];
        if(avecSautDeLigne)
            ligne = [ligne '\r\n'];
        end
        
    case 'cell string'
        if(length(vecteur)>1)
            for(i=1:length(vecteur)-1)
                ligne = [ligne char(vecteur{i}) sep];
            end
        end
        ligne = [ligne char(vecteur{end})];
        if(avecSautDeLigne)
            ligne = [ligne '\r\n'];
        end
end