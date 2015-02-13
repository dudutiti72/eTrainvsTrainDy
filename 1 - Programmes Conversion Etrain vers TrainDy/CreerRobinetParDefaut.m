function CreerRobinetParDefaut(fsl,fTD,sep)

%Chemin du dossier robinet
fRobinet = [fTD,fsl,'BrakeValve'];

%Creation du dossier BrakeValve
if(exist(fRobinet)==0)
    mkdir(fRobinet);
end

%Nom du robinet
nom = 'RobinetDefaut';

%Chemin du fichier robinet 
nRobinet = [fRobinet fsl nom '.txt'];



if(exist(nRobinet)==0)
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PARAMETRE PAR DEFAUT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %FREINAGE D'URGENCE
    %Diametre de l'orifice équivalent
    diamOrificeUrgence = 16;
    
    %Coefficient de débit Cq
    coefDebitCQUrgence = 0;
    
    %Utilisation loi de Perry
    utilisationPerryUrgence = 'true';
    
    
    
    %FREINAGE DE SERVICE
    %Diametre de l'orifice equivalent
    diamOrificeService = 14.5;
    
    %Coefficient de debit CQ
    coefDebitCQService = 0;
    
    %Utilisation loi de Perry
    utilisationPerryService = 'true';
    
    %Temps pour atteindre de 1.5 bar dans le reservoir equivalent
    temps1_5 = 6;
    
    %Temps de premiere depression dans le reservoir équivalent
    tempsPD = 0.8;
    
    
    
    %DESSERRAGE
    %Diametre de l'orifice equivalent
    diamOrificeDesserrage = 10.9;
    
    %Coefficient de debit CQ
    coefDebitCQDesserrage = 0;
    
    %Utilisation loi de Perry
    utilisationPerryDesserrage = 'true';
    
    %Temps pour augmenter de 1.5 bar dans le reservoir équivalent
    tempsAugm1_5 = 2;
    
    
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ECRITURE DANS LE FICHIER DISTRIBUTEUR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Ouverture fichier robinet
    nfRobinet = fopen(nRobinet,'w');
    
    %Nom
    fprintf(nfRobinet,'name=%s\r\n',nom);
    
    
    %Diametre de l'orifice équivalent
    fprintf(nfRobinet,'ebdiameo=%g\r\n',diamOrificeUrgence);
    
    %Diametre de l'orifice equivalent
    fprintf(nfRobinet,'sbdiameo=%g\r\n',diamOrificeService);
    
    %Diametre de l'orifice equivalent
    fprintf(nfRobinet,'rediameo=%g\r\n',diamOrificeDesserrage);
    
    
    %Coefficient de débit Cq
    fprintf(nfRobinet,'ebflcoef=%g\r\n',coefDebitCQUrgence);
    %Utilisation loi de Perry
    fprintf(nfRobinet,'chkebpl=%s\r\n',utilisationPerryUrgence);
    
    
  
    
    %Coefficient de debit CQ
    fprintf(nfRobinet,'sbflcoef=%g\r\n',coefDebitCQService);
    %Utilisation loi de Perry
    fprintf(nfRobinet,'chksbpl=%s\r\n',utilisationPerryService);
    %Temps pour atteindre de 1.5 bar dans le reservoir equivalent
    fprintf(nfRobinet,'sbtad15=%g\r\n',temps1_5);
    %Temps de premiere depression dans le reservoir équivalent
    fprintf(nfRobinet,'sbtd=%g\r\n',tempsPD);
    
  
    %Coefficient de debit CQ
    fprintf(nfRobinet,'reflcoef=%g\r\n',coefDebitCQDesserrage);
    %Utilisation loi de Perry
    fprintf(nfRobinet,'chkrepl=%s\r\n',utilisationPerryDesserrage);
    %Temps pour augmenter de 1.5 bar dans le reservoir équivalent
    fprintf(nfRobinet,'retai15=%g',tempsAugm1_5);

    
    fclose(nfRobinet);
end