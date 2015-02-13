function ManoeuvreConv(fsl,ftoc,fTD,sep)

%Chemin du dossier manoeuvre
fManoeuvre = [fTD,fsl,'Manoeuvre'];
%Création du dossier trainDY

%Creation du dossier manoeuvre
if(exist(fManoeuvre)==0)
    mkdir(fManoeuvre);
end

%Chemin du dossier .lst a lire
fDat = [ftoc,fsl,'dat'];
%Liste des fichiers  dans le dossier dat
lDat = dir(fDat);
nbManoeuvre = 0; 

%Comptage du nombre de manoeuvre
for jj = 3:length(lDat)
    if (strcmp(lDat(jj).name(end-2:end),'lst'))
        nbManoeuvre = nbManoeuvre + 1;
    end
end
h0=waitbar(0,'Conversion des manoeuvres');

indiceManoeuvre = 0;
%boucle sur les différentes manoeuvre
for jj = 3:length(lDat)
    

    %Chemin d'accès au fichier lst a lire
    nLst = [fDat fsl lDat(jj).name];
    
    
    %Vérification qu'il s'agit d'un fichier .lst
    if strcmp(nLst(end-2:end),'lst')
        indiceManoeuvre = indiceManoeuvre +1;
        disp(['Conversion Manoeuvre : ',num2str(indiceManoeuvre),' sur ',num2str(nbManoeuvre)]);
        waitbar(indiceManoeuvre/nbManoeuvre,h0);
        %Ouverture du fichier .lst à lire
        nfLst = fopen(nLst,'r');
        
        %Chemin d'accès au fichier manoeuvre à ecrire
        nManoeuvreActive = [fManoeuvre fsl lDat(jj).name(1:end-4) 'Active' '.txt'];
        nManoeuvrePassive = [fManoeuvre fsl lDat(jj).name(1:end-4) 'Passive' '.txt'];
        
        %Création du fichier .txt (pour ecriture)
        nfManoeuvreActive = fopen(nManoeuvreActive,'w');
        nfManoeuvrePassive = fopen(nManoeuvrePassive,'w');
        
        
        
        
        %% %%%%%%%%%%%%
        %LECTURE
        %%%%%%%%%%%%%%%
        %initialisation vecteur des temps
        temps=zeros(1);
        
        %initialisation vecteur pression cible
        pressionCible=zeros(1);
        
        %initialisation vecteur % traction
        traction=zeros(1);
        
        %initialisation vecteur pneumatic brake loco
        pneumaticBrake=zeros(1);
        
        %initialisation retard
        retard = zeros(1);
        
        %Nombre d'action différente
        i=0;
        %Lecture des parametre de la ligne Aktion
        line = fgetl(nfLst);
        while(not(strcmp(line,'}')))
            if (length(line)>6)
                
                if(strcmp(line(1:6),'Aktion'))
                    i=i+1;
                    chiffre = sscanf(line,'%*s %*s %*s %g %*s %g %*s %g %*s %g %*s',[1, inf]);
                    %temps ou commence l'action
                    temps(i)=chiffre(1);
                    %Pression cible
                    pressionCible(i)=chiffre(2);
                    % % traction
                    traction(i)=chiffre(3);
                    % Freinage pneumatique sur la locomotive
                    pneumaticBrake(i)=chiffre(4);
                end
            end
            line = fgetl(nfLst);
        end
            
        %Lecture vitesse cible
        vitesseCible=RecupParam('v-Ziel','vitesse cible','float',nfLst);
        
        %Correction de la vitesse cible pour TrainDy
        %Il arrive qu'avec une vitesse cible valant 0 km/h la simulation
        %dure très longtemps avec un train roulant a quelques dizieme de
        %km/h
        %On définit la vitesse cible comme étant 1km/h, cela permet
        %d'arreter la simulation plus rapidement et cela ne modifie pas les
        %valeurs d'ELC max durant la simulation car le pic d'ELC ne se
        %situe pas à la fin de la simulation
        if(vitesseCible == 0)
            vitesseCible = 1;
        end
        
        %fermeture fichier lecture
        fclose(nfLst);
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%
        %PARAMETRE STANDARD
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        for(j=1:i)
            %Freinage pneu ou non, la valeur est toujours  a true mais si la
            %presion cible est 5, il n'y a pas de freinage
            freinagePneumatiqueActive(j) = true;
            freinagePneumatiquePassive(j)=false;
            %Freinage electropneumatique
            freinageElectroPneumatique(j) = false;
            %Retard            
            retard(j) = 0;
        end
        
        
        
        
        %% %%%%%%%%%%%%%
        %TRANSFORMATION DES PARAMETRES
        %%%%%%%%%%%%%%%%%%%
        %Initialisation de typeDonneesControle
        typeDonneesControle = cellstr('');
        %Initialisation de donnees Controle
        donneesControle = zeros(1);
        
        %Si il n'y a qu'une action, on freine jusqu'à la vitesse cible
        if (i==1)
            typeDonneesControle(1) = cellstr('$MAN_TYPE[3]');%controle sur la vitesse cible
            donneesControle(1) = vitesseCible;
            %Si il y  a plus d'une action, on réalise les premières actions
            %avec le controle temporelle et on s'arrete à la vitesse cible
        else
            for(j=1:i-1)
                typeDonneesControle(j) = cellstr('$MAN_TYPE[1]');
                donneesControle(j) = temps(j+1)-temps(j);
            end
            typeDonneesControle(i)=cellstr('$MAN_TYPE[3]');
            donneesControle(i)=vitesseCible;
        end
        
        for(j=1:i)
            if(traction(j)>0)
                checkTraction(j)=true;
				checkRheostatique(j)=false;
				pourcentageApplication(j)=traction(j);
			elseif(traction(j)<0)
				checkRheostatique(j)=true;
				checkTraction(j)=false;
				pourcentageApplication(j)=-traction(j);
			else
                checkTraction(j)=false;
				checkRheostatique(j)=false;
				pourcentageApplication(j) = 100;
            end
        end
		
		
		
        
        %for (j=1:i)
        %    if(checkTraction(j))
        %        pourcentageApplication(j)=traction(j);
        %    else
        %        pourcentageApplication(j) = 100;
        %    end
        %end
        
        
        
        
        
        %% %%%%%%%%%%%%
        %ECRITURE DANS LE FICHIER TRAINDY
        %%%%%%%%%%%%%%%
        %Ecriture type de données
        fprintf(nfManoeuvreActive,creerLigneTableau(typeDonneesControle,'string','mtype',sep,true));
        fprintf(nfManoeuvrePassive,creerLigneTableau(typeDonneesControle,'string','mtype',sep,true));

        %Ecriture donnees de controle
        fprintf(nfManoeuvreActive,creerLigneTableau(donneesControle,'float1decimaleMini','ctrl',sep,true));
        fprintf(nfManoeuvrePassive,creerLigneTableau(donneesControle,'float1decimaleMini','ctrl',sep,true));

        %Ecriture pneumatique brake
        fprintf(nfManoeuvreActive,creerLigneTableau(freinagePneumatiqueActive,'bool','pnBr',sep,true));
        fprintf(nfManoeuvrePassive,creerLigneTableau(freinagePneumatiquePassive,'bool','pnBr',sep,true));

        %Ecriture freinage electrodynamique
        fprintf(nfManoeuvreActive,creerLigneTableau(checkRheostatique,'bool','edBr',sep,true));
        fprintf(nfManoeuvrePassive,creerLigneTableau(checkRheostatique,'bool','edBr',sep,true));
        
        %Ecriture freinage electro-pneumatique
        fprintf(nfManoeuvreActive,creerLigneTableau(freinageElectroPneumatique,'bool','epBr',sep,true));
        fprintf(nfManoeuvrePassive,creerLigneTableau(freinageElectroPneumatique,'bool','epBr',sep,true));
        
        %Ecriture traction
        fprintf(nfManoeuvreActive,creerLigneTableau(checkTraction,'bool','tract',sep,true));
        fprintf(nfManoeuvrePassive,creerLigneTableau(checkTraction,'bool','tract',sep,true));
        
        %Ecriture pression cible
        fprintf(nfManoeuvreActive,creerLigneTableau(pressionCible,'float1decimaleMini','pres',sep,true));
        fprintf(nfManoeuvrePassive,creerLigneTableau(pressionCible,'float1decimaleMini','pres',sep,true));
        
        %Ecriture delay
        fprintf(nfManoeuvreActive,creerLigneTableau(retard,'float1decimaleMini','delay',sep,true));
        fprintf(nfManoeuvrePassive,creerLigneTableau(retard,'float1decimaleMini','delay',sep,true));
        
        %Ecriture % application
        fprintf(nfManoeuvreActive,creerLigneTableau(pourcentageApplication,'float1decimaleMini','applic',sep,false));
        fprintf(nfManoeuvrePassive,creerLigneTableau(pourcentageApplication,'float1decimaleMini','applic',sep,false));
        
        %On efface les valeurs pour réinitialiser la taille des matrices
        clear temps pressionCible traction pneumaticBrake vitesseCible freinagePneumatiqueActive freinagePneumatiquePassive freinageElectroPneumatique checkRheostatique typeDonneesControle donneesControle checkTraction pourcentageApplication retard
        
        %Fermeture fichier ecriture
        fclose(nfManoeuvreActive);
        fclose(nfManoeuvrePassive);
    end
end
close(h0)