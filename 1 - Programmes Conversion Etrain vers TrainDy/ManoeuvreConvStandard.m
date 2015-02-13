function ManoeuvreConvStandard(fsl,ftoc,fTD,sep)

%Chemin du dossier manoeuvre
fManoeuvre = [fTD,fsl,'Manoeuvre'];
%Création du dossier trainDY

%Creation du dossier manoeuvre
if(exist(fManoeuvre)==0)
    mkdir(fManoeuvre);
end



nbManoeuvre = 2;

h0=waitbar(0,'Création des manoeuvres standards');

indiceManoeuvre = 0;
manoeuvreS = {'emergencyS','service_1S'};
%boucle sur les différentes manoeuvre
for jj = 1:length(manoeuvreS)
    indiceManoeuvre = indiceManoeuvre +1;
    disp(['Conversion Manoeuvre Standard: ',num2str(indiceManoeuvre),' sur ',num2str(nbManoeuvre)]);
    waitbar(indiceManoeuvre/nbManoeuvre,h0);
    %Chemin d'accès au fichier manoeuvre à ecrire
    nManoeuvreActive = [fManoeuvre fsl manoeuvreS{jj} 'Active' '.txt'];
    nManoeuvrePassive = [fManoeuvre fsl manoeuvreS{jj} 'Passive' '.txt'];
    
    %Création du fichier .txt (pour ecriture)
    nfManoeuvreActive = fopen(nManoeuvreActive,'w');
    nfManoeuvrePassive = fopen(nManoeuvrePassive,'w');
    
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%
    %PARAMETRE STANDARD
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    if (strcmp(manoeuvreS{jj},'emergencyS'))
        typeDonneesControleActive = cellstr('$MAN_TYPE[3]');
        donneesControleActive = 1;
        freinagePneumatiqueActive = true;
        checkRheostatiqueActive = false;
        freinageElectroPneumatiqueActive = false;
        checkTractionActive = false;
        pressionCibleActive = 0;
        retardActive = 0;
        pourcentageApplicationActive = 100;
        
        typeDonneesControlePassive = cellstr('$MAN_TYPE[3]');
        donneesControlePassive = 1;
        freinagePneumatiquePassive = false;
        checkRheostatiquePassive = false;
        freinageElectroPneumatiquePassive = false;
        checkTractionPassive = false;
        pressionCiblePassive = 0;
        retardPassive = 0;
        pourcentageApplicationPassive = 100;
    end
    if (strcmp(manoeuvreS{jj},'service_1S'))
        typeDonneesControleActive = cellstr('$MAN_TYPE[3]');
        donneesControleActive = 1;
        freinagePneumatiqueActive = true;
        checkRheostatiqueActive = false;
        freinageElectroPneumatiqueActive = false;
        checkTractionActive = false;
        pressionCibleActive = 4;
        retardActive = 0;
        pourcentageApplicationActive = 100;
        
        typeDonneesControlePassive = cellstr('$MAN_TYPE[3]');
        donneesControlePassive = 1;
        freinagePneumatiquePassive = false;
        checkRheostatiquePassive = false;
        freinageElectroPneumatiquePassive = false;
        checkTractionPassive = false;
        pressionCiblePassive = 4;
        retardPassive = 0;
        pourcentageApplicationPassive = 100;
    end
    
    

    %% %%%%%%%%%%%%
    %ECRITURE DANS LE FICHIER TRAINDY
    %%%%%%%%%%%%%%%
    %Ecriture type de données
    fprintf(nfManoeuvreActive,creerLigneTableau(typeDonneesControleActive,'string','mtype',sep,true));
    fprintf(nfManoeuvrePassive,creerLigneTableau(typeDonneesControlePassive,'string','mtype',sep,true));
    
    %Ecriture donnees de controle
    fprintf(nfManoeuvreActive,creerLigneTableau(donneesControleActive,'float1decimaleMini','ctrl',sep,true));
    fprintf(nfManoeuvrePassive,creerLigneTableau(donneesControlePassive,'float1decimaleMini','ctrl',sep,true));
    
    %Ecriture pneumatique brake
    fprintf(nfManoeuvreActive,creerLigneTableau(freinagePneumatiqueActive,'bool','pnBr',sep,true));
    fprintf(nfManoeuvrePassive,creerLigneTableau(freinagePneumatiquePassive,'bool','pnBr',sep,true));
    
    %Ecriture freinage electrodynamique
    fprintf(nfManoeuvreActive,creerLigneTableau(checkRheostatiqueActive,'bool','edBr',sep,true));
    fprintf(nfManoeuvrePassive,creerLigneTableau(checkRheostatiquePassive,'bool','edBr',sep,true));
    
    %Ecriture freinage electro-pneumatique
    fprintf(nfManoeuvreActive,creerLigneTableau(freinageElectroPneumatiqueActive,'bool','epBr',sep,true));
    fprintf(nfManoeuvrePassive,creerLigneTableau(freinageElectroPneumatiquePassive,'bool','epBr',sep,true));
    
    %Ecriture traction
    fprintf(nfManoeuvreActive,creerLigneTableau(checkTractionActive,'bool','tract',sep,true));
    fprintf(nfManoeuvrePassive,creerLigneTableau(checkTractionPassive,'bool','tract',sep,true));
    
    %Ecriture pression cible
    fprintf(nfManoeuvreActive,creerLigneTableau(pressionCibleActive,'float1decimaleMini','pres',sep,true));
    fprintf(nfManoeuvrePassive,creerLigneTableau(pressionCiblePassive,'float1decimaleMini','pres',sep,true));
    
    %Ecriture delay
    fprintf(nfManoeuvreActive,creerLigneTableau(retardActive,'float1decimaleMini','delay',sep,true));
    fprintf(nfManoeuvrePassive,creerLigneTableau(retardPassive,'float1decimaleMini','delay',sep,true));
    
    %Ecriture % application
    fprintf(nfManoeuvreActive,creerLigneTableau(pourcentageApplicationActive,'float1decimaleMini','applic',sep,false));
    fprintf(nfManoeuvrePassive,creerLigneTableau(pourcentageApplicationPassive,'float1decimaleMini','applic',sep,false));
    
    %On efface les valeurs pour réinitialiser la taille des matrices
    clear temps pressionCible traction pneumaticBrake vitesseCible freinagePneumatiqueActive freinagePneumatiquePassive freinageElectroPneumatique checkRheostatique typeDonneesControle donneesControle checkTraction pourcentageApplication retard
    
    %Fermeture fichier ecriture
    fclose(nfManoeuvreActive);
    fclose(nfManoeuvrePassive);
end
close(h0)