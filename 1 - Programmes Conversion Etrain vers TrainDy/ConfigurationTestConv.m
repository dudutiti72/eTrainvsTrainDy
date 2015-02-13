function ConfigurationTestConv(fsl,ftoc,fTD,sep)
%Permet de cr�er les fichiers configurations. Pour trainDy, un fichier
%configuration est cr�� pour chaque composition et chaque manoeuvre
%envisag� (dans le dossier pro)
%les fichiers configurations sont cr��s � partir des fichiers .zug, des
%bases de donn�es loco et wagons, de bremsen.dat (sous dossier dat), et des
%fichiers trains sous (sous dossier dat)



%Chemin du dossier Configuration
fConfiguration = [fTD,fsl,'Configuration'];
%Chemin du dossier test
fTest = [fTD,fsl,'Test'];

%Creation du dossier Configuration
if(exist(fConfiguration)==0)
    mkdir(fConfiguration);
end

%Creation du dossier Test
if(exist(fTest)==0)
    mkdir(fTest);
end

%Chemin du dossier pro
fPro = [ftoc,fsl,'pro'];
%Liste des fichiers pro
lPro = dir(fPro);

%Chemin du dossier zug
fZug = [ftoc,fsl,'zug'];
%Liste des fichiers zug
lZug = dir(fZug);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%V�rification que les fichiers pro correspondent bien � un fichier compo
%existant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nbConfigEtTest = 0;
fichierPRO_OK = zeros(length(fPro),1);
disp('V�rification des fichiers configurations � cr�er')
disp(sprintf('\n'))
for jj = 3:length(lPro)
    %disp(['Verification : ' num2str(jj-2) ' sur ' num2str(length(lPro)-2)])
    [train, reste] = strtok(lPro(jj).name,'.');
    [nomCompo,reste] = strtok(reste,'.');
    nomManTrain=strtok(reste,'.');
    if(strcmp(train,'train'))
        if(exist([fZug '\' nomCompo '.zug'])~=0)
              nbConfigEtTest=nbConfigEtTest+1;
              fichierPRO_OK(jj,1)=1;  
        else
            disp(['Le fichier ' lPro(jj).name ' ne correspond pas � un fichier compo existant'])
        end
    else
        disp(['Le fichier ' lPro(jj).name ' n''est pas reconnu'])

    end
end
disp(sprintf('\n'))


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LECTURE DU FICHIER BREMSEN.DAT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[longueurAccouplement,rugositeCG] = lectureFichierBremsen(fsl,ftoc);



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CREATION DES CONFIGURATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indConfig = 0;

h0=waitbar(0,'Conversion des configurations');

%Boucle sur les fichier pro
for jj = 3:length(lPro)
    if(fichierPRO_OK(jj,1))
        indConfig=indConfig+1;
        disp(['Conversion configuration : ',num2str(indConfig),' sur ',num2str(nbConfigEtTest)]);
        waitbar(indConfig/nbConfigEtTest,h0);
        nomPro = lPro(jj).name;
        
        %Permet d'extraire le nom de la config et le nom du fichier train �
        %partir du titre du fichier pro
        [train, reste] = strtok(nomPro,'.');
        [nomCompo,reste] = strtok(reste,'.');
        nomManTrain=strtok(reste,'.');
        
        %nom du fichier Config � ecrire
        nomConfig = [nomCompo '-' nomManTrain '.txt'];
        %Chemin du fichier config � ecrire
        nConfig = [fConfiguration fsl nomConfig];
        
        %Nom du fichier Test � ecrire
        nomTest = ['Test' '-' nomCompo '-' nomManTrain '.txt'];
        %Chemin du fichier Test � ecrire
        nTest = [fTest fsl nomTest];
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %LECTURE FICHIER ZUG
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Chemin du fichier zug correspondant
        nZug = [ftoc,fsl,'zug',fsl,nomCompo,'.zug'];
        %Ouverture fichier � lire
        nfZug = fopen(nZug);
        
        %Lecture nombre v�hicule
        nombreLoco = RecupParam('Lokanzahl','nombre locomotive','float',nfZug);
        nombreWagon = RecupParam('Wagenanzahl','nombre wagon','float',nfZug);
        nombreVehicule = nombreLoco + nombreWagon;
        
        estLoco=zeros(nombreVehicule,1);
        
        
        
        %Recup�ration des ligne locomotive du fichier zug
        trova_info('Loks:',nfZug);
        line = fgetl(nfZug);
        indice = 1;
        while(indice<=nombreLoco)
            if(not(isempty(line)))
                %R�cup�ration et traitement des lignes de param�tre loco
                indiceCaractereEgal = strfind(line,'=');
                ligneLoco = line;
                decalage = 0;
                for i = 1 : length(indiceCaractereEgal)
                    ligneLoco = [ligneLoco(1:indiceCaractereEgal(i)+decalage) ' ' ligneLoco(decalage+indiceCaractereEgal(i)+1:end)];
                    decalage = decalage +1;
                end
                       
                active(indice) = false;
                couplee(indice) = false;
                ligneLoco = textscan(ligneLoco,'%s');
                for i = 1 : length(ligneLoco{1}(:))
                    %Position de la loco
                    if(not(isempty(strfind(char(ligneLoco{1}(i)),'Position'))))||(not(isempty(strfind(char(ligneLoco{1}(i)),'position'))))
                        position = str2double(char(ligneLoco{1}(i+1)));
                    end
                    %Nom de la loco
                    if(not(isempty(strfind(char(ligneLoco{1}(i)),'Name'))))||(not(isempty(strfind(char(ligneLoco{1}(i)),'name'))))
                        nom = ligneLoco{1}(i+1);
                    end
                    %Aktiv ou passiv
                    if(not(isempty(strfind(char(ligneLoco{1}(i)),'aktiv'))))||(not(isempty(strfind(char(ligneLoco{1}(i)),'Aktiv'))))
                        active(indice) = active(indice)||true;
                    elseif (not(isempty(strfind(char(ligneLoco{1}(i)),'passiv'))))||(not(isempty(strfind(char(ligneLoco{1}(i)),'Passiv'))))
                        active(indice) = active(indice)||false;
                    end
                    %Coupl�e ou non 
                    if(not(isempty(strfind(char(ligneLoco{1}(i)),'hlungekuppelt'))))||(not(isempty(strfind(char(ligneLoco{1}(i)),'Hlungekuppelt'))))
                        couplee(indice) = active(indice)||false;
                    elseif (not(isempty(strfind(char(ligneLoco{1}(i)),'Hlgekuppelt'))))||(not(isempty(strfind(char(ligneLoco{1}(i)),'hlgekuppelt'))))
                        couplee(indice) = active(indice)||true;
                    end
                    %Jeu entre tampon
                    if(not(isempty(strfind(char(ligneLoco{1}(i)),'kupplungsspiel'))))||(not(isempty(strfind(char(ligneLoco{1}(i)),'Kupplungsspiel'))))
                        valeurJeu = str2double(ligneLoco{1}(i+1));
                    end
                    %Fk Loco 
                    if(not(isempty(strfind(char(ligneLoco{1}(i)),'fk'))))||(not(isempty(strfind(char(ligneLoco{1}(i)),'Fk'))))
                        valeurFk = str2double(ligneLoco{1}(i+1));
                    end
                    
                    if(not(isempty(strfind(char(ligneLoco{1}(i)),'taust'))))||(not(isempty(strfind(char(ligneLoco{1}(i)),'Taust'))))
                        tempsMontee = str2double(ligneLoco{1}(i+1));
                    end
                end
                
              
                
                %remplissage des Matrices
                %Permet de savoir s'il s'agit d'une loco ou non
                
                estLoco(position)=true;
                nomVehicule(position)=nom;
                
                chargement(position)=0;
                FK(position)=valeurFk;
                tempsMontee95(position) = tempsMontee;
                jeu(position) = valeurJeu;
                
                
                indice = indice +1;
            end
            line = fgetl(nfZug);
        end
        
        %R�cup�ration des lignes wagons du fichier zug
        trova_info('Wagen:',nfZug);
        line = fgetl(nfZug);
        indice = 1;
        positionWagon=zeros(1,1);
        indiceW=0;
        
        %Position des wagons
        for (ii=1:nombreVehicule)
            if(estLoco(ii)==0)
                indiceW=indiceW+1;
                positionWagon(indiceW)=ii;
            end
        end
        
        while(indice<=nombreWagon)
            %V�rification que la ligne n'est pas vide ou qu'elle ne
            %commence pas par une tabulation
            if(not(isempty(line)))&&(line(1)~=' ')&&(not(line(1)==char(9)))
                    [nomWagonW,masseChargementW,jeuW,FkW,t95W]=lectureLigneWagon(line);
                    %Nom des wagons
                    nomVehicule{positionWagon(indice)}=nomWagonW;
                    %Chargement des wagons
                    chargement(positionWagon(indice))=masseChargementW;
                    %Jeu entre les wagons
                    jeu(positionWagon(indice))=jeuW;
                    %Fk des wagons
                    FK(positionWagon(indice))=FkW;
                    %Temps de mont�e 95
                    tempsMontee95(positionWagon(indice)) = t95W;
                    
                    indice = indice +1;
            end
            line = fgetl(nfZug);
        end
        
        %Permet de r�cup�rer le nom des manoeuvre des loco
        [manoeuvre,tempsEchantillonage,Vinit,nomVoie] = lectureFichierTrain(nomManTrain,fsl,ftoc,nombreLoco);
        indiceLoco = 0;
        for (ii = 1:nombreVehicule)
            matPosition(ii)=ii;
            [longueur,longueurCG,tare,distributeur,contribSemelle,tampAv,tampAr,tractAv,tractAr,loiCoef]=LectureWagonLocoPourConfig(char(nomVehicule{ii}),fsl,fTD,estLoco(ii));
            matLongueur(ii)=longueur;
            matLongueurCG(ii)=longueurCG;
            matTare(ii)=tare;
            matDistributeur(ii)=cellstr(distributeur);
            matContribSemelle(ii)=contribSemelle;
            matTampAv(ii) = cellstr(tampAv);
            matTampAr(ii) = cellstr(tampAr);
            matTractAv(ii) = cellstr(tractAv);
            matTractAr(ii) = cellstr(tractAr);
            matLoiCoef(ii)=cellstr(loiCoef);
            matLongueurCumulee(ii) = sum(matLongueur(1:ii));
            matMasseTotale(ii)=sum(matTare(1:ii))+sum(chargement(1:ii));
            matPCFmax(ii) = lecturePCFMax(char(matDistributeur{ii}),fsl,fTD,sep);
            if(estLoco(ii))
                indiceLoco=indiceLoco+1;
                if(active(indiceLoco))
                    matManoeuvre(ii)=cellstr([char(manoeuvre(indiceLoco)) 'Active']);
                else
                    matManoeuvre(ii)=cellstr([char(manoeuvre(indiceLoco)) 'Passive']);
                end
            else
                matManoeuvre(ii)=cellstr('');
                
            end
            
        end
        
        
        %fermeture fichier zug
        fclose(nfZug);
        
        
        
        
        %% %%%%%%%%%%%%%%%%%%%%%%
        %PARAMETRE STANDARD
        %%%%%%%%%%%%%%%%%%%%%%%%%
        %r�gime freinage
        regimeFreinage = '$BRAKE_REGIME[1]';
        
        %Diametre CG accouplement
        diamCGAccouplement = 35.6;
        
        %Temp�rature
        temperature = 293.15;
        
        %Facteur de perte de charge
        fPdeC = 3;
        
        %Pression initiale
        pressionInitiale = 5;
        
        for (ii = 1:nombreVehicule)
            estCouple(ii) = false;
            nestPasIsole(ii) = true;
            %Affichage du regime de freinage (G ou P) � titre indicatif juste
            %pour affichage
            if(tempsMontee95(ii)>12)
                matRegimeFreinage(ii) = cellstr('$BRAKE_REGIME[1]');
            else
                matRegimeFreinage(ii) = cellstr('$BRAKE_REGIME[2]');
            end
            %temps de mont�e 100% = temps 95 +14%*temps 95 (arbitraire)
            tempsMontee100(ii) = tempsMontee95(ii)*1.14;
            %ContribDisque
            matContribDisque(ii) = 0;
            
        end
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ECRITURE FICHIER CONFIGURATION
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nfConfig = fopen(nConfig,'w');
        
        %Ecriture du nom de la configuration
        fprintf(nfConfig,'confName=%s\r\n',nomConfig(1:end-4));
        
        %Ecriture regime de freinage
        fprintf(nfConfig,'confBrReg=%s\r\n',regimeFreinage);
        
        %Ecriture position
        fprintf(nfConfig,creerLigneTableau(matPosition,'float','pos',sep,true));
        
        %Ecriture type v�hicule
        fprintf(nfConfig,creerLigneTableau(nomVehicule,'cell string','type',sep,true));
        
        %Ecriture manoeuvre
        fprintf(nfConfig,creerLigneTableau(matManoeuvre,'cell string','manoeuvre',sep,true));
        
        %Ecriture longueur
        fprintf(nfConfig,creerLigneTableau(matLongueur,'float1decimaleMini','wagLength',sep,true));
        
        %Ecriture longueur cumul�e
        fprintf(nfConfig,creerLigneTableau(matLongueurCumulee,'float1decimaleMini','totLength',sep,true));
        
        %Ecriture longueur CG
        fprintf(nfConfig,creerLigneTableau(matLongueurCG,'float1decimaleMini','brPLength',sep,true));
        
        %Ecriture "est coupl�"
        fprintf(nfConfig,creerLigneTableau(estCouple,'bool','gpCStat',sep,true));
        
        %Ecriture chargement
        fprintf(nfConfig,creerLigneTableau(chargement,'float1decimaleMini','load',sep,true));
        
        %Ecriture tare
        fprintf(nfConfig,creerLigneTableau(matTare,'float1decimaleMini','tare',sep,true));
        
        %Ecriture masse totale
        fprintf(nfConfig,creerLigneTableau(matMasseTotale,'float1decimaleMini','mass',sep,true));
        
        %Ecriture FK
        fprintf(nfConfig,creerLigneTableau(FK,'float','fk',sep,true));
        
        %Ecriture PCFmax exp
        fprintf(nfConfig,creerLigneTableau(matPCFmax,'float1decimaleMini','bcExpTp',sep,true));
        
        %Ecriture PCFmax nom
        fprintf(nfConfig,creerLigneTableau(matPCFmax,'float1decimaleMini','bcNomTp',sep,true));
        
        %Ecriture distributeur
        fprintf(nfConfig,creerLigneTableau(matDistributeur,'cell string','cv',sep,true));
        
        %Ecriture "n'est pas isole"
        fprintf(nfConfig,creerLigneTableau(nestPasIsole,'bool','cvStat',sep,true));
        
        %Ecriture r�gime de freinage
        fprintf(nfConfig,creerLigneTableau(matRegimeFreinage,'cell string','brReg',sep,true));
        
        %Ecriture temps montee 95
        fprintf(nfConfig,creerLigneTableau(tempsMontee95,'float1decimaleMini','ft95',sep,true));
        
        %Ecriture temps montee 100
        fprintf(nfConfig,creerLigneTableau(tempsMontee100,'float1decimaleMini','ft100',sep,true));
        
        %Ecriture Contribution semelle
        fprintf(nfConfig,creerLigneTableau(matContribSemelle,'float1decimaleMini','contBl',sep,true));
        
        %Ecriture Contribution disque
        fprintf(nfConfig,creerLigneTableau(matContribDisque,'float1decimaleMini','contDi',sep,true));
        
        %Ecriture jeu
        fprintf(nfConfig,creerLigneTableau(jeu,'float1decimaleMini','gap',sep,true));
        
        %Ecriture tampons avant
        fprintf(nfConfig,creerLigneTableau(matTampAv,'cell string','bufGearsF',sep,true));
        
        %Ecriture traction avant
        fprintf(nfConfig,creerLigneTableau(matTractAv,'cell string','drGearsF',sep,true));
        
        %Ecriture tampons arriere
        fprintf(nfConfig,creerLigneTableau(matTampAr,'cell string','bufGearsR',sep,true));
        
        %Ecriture tampons arriere
        fprintf(nfConfig,creerLigneTableau(matTractAr,'cell string','drGearsR',sep,true));
        
        %Ecriture loi de coef de frottement
        fprintf(nfConfig,creerLigneTableau(matLoiCoef,'cell string','frictLaw',sep,true));
        
        %Ecriture diametre CG accouplement
        fprintf(nfConfig,'inthcd=%g\r\n',diamCGAccouplement);
        
        %Ecriture longueur accouplement
        fprintf(nfConfig,'lenhc=%g\r\n',longueurAccouplement);
        
        %Ecriture facteur de perte de charge
        fprintf(nfConfig,'cplfhc=%g\r\n',fPdeC);
        
        %Ecriture temps echantillonage
        fprintf(nfConfig,'srdw=%g\r\n',tempsEchantillonage);
        
        %Ecriture temps echantillonage
        fprintf(nfConfig,'envTemp=%g\r\n',temperature);
        
        
        %Ecriture temps echantillonage
        fprintf(nfConfig,'rouBP=%g',rugositeCG);
        
        
        fclose(nfConfig);
        
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ECRITURE FICHIER TEST
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nfTest = fopen(nTest,'w');
        
        %Ecriture du nom du test
        fprintf(nfTest,'name=%s\r\n',nomTest(1:end-4));
        
        %Ecriture de la configuration a utiliser
        fprintf(nfTest,'configuration=%s\r\n',nomConfig(1:end-4));
        
        %Ecriture de la voie
        fprintf(nfTest,'track=%s\r\n',nomVoie);
        
        %Ecriture vitesse initiale
        fprintf(nfTest,'stspd=%g\r\n',Vinit);
        
        %Ecriture pression initiale
        fprintf(nfTest,'initpres=%g',pressionInitiale);
        
        fclose(nfTest);
        
    end
end
close(h0)


function [longueur,longueurCG,tare,distributeur,contribSemelle,tampAv,tampAr,tractAv,tractAr,loiCoef]=LectureWagonLocoPourConfig(nomVehi,fsl,fTD,estLoco)
%Permet de lire la base de donn�es wagon et loco pour cr�er le fichier config
if (estLoco)
    %Chemin du fichier  loco
    nVehi = [fTD fsl 'Locomotive'  fsl nomVehi '.txt'];
else
    %Chemin du fichier wagon
    nVehi = [fTD fsl 'Wagon'  fsl nomVehi '.txt'];
end

%Ouverture fichier
nfVehi = fopen(nVehi,'r');

%Lecture longueur
line = trova_info('length=',nfVehi);
longueur = str2double(cellstr(strtok(line,'length=')));
%Lecture longueur CG
line = trova_info('brakePipeWagonLen=',nfVehi);
rapportLCG_Lwagon = str2double(cellstr(strtok(line,'brakePipeWagonLen=')));
longueurCG = rapportLCG_Lwagon*longueur;
%Lecture tare
if (estLoco)
    line = trova_info('mass=',nfVehi);
    tare = str2double(cellstr(strtok(line,'mass=')));
else
    line = trova_info('tare=',nfVehi);
    tare = str2double(cellstr(strtok(line,'tare=')));
end
%Lecture Distributeur
line = trova_info('controlValve=',nfVehi);
distrib = regexp(line,'controlValve=','split');
distributeur = char(distrib{2});
%Lecture contribSemelle
line = trova_info('bbContribution=',nfVehi);
contribSemelle = str2double(cellstr(strtok(line,'bbContribution=')));
%Lecture tamponsAv
line = trova_info('buffingGearsF=',nfVehi);
taAv = regexp(line,'buffingGearsF=','split');
tampAv = char(taAv{2});
%Lecture tractionAv
line = trova_info('drawGearsF=',nfVehi);
trAv = regexp(line,'drawGearsF=','split');
tractAv = char(trAv{2});
%Lecture tamponsAr
line = trova_info('buffingGearsR=',nfVehi);
taAr = regexp(line,'buffingGearsR=','split');
tampAr = char(taAr{2});
%Lecture tractionAr
line = trova_info('drawGearsR=',nfVehi);
trAr = regexp(line,'drawGearsR=','split');
tractAr = char(trAr{2});
%Lecture Loi Coef
line = trova_info('bbFrictLaw=',nfVehi);
lC = regexp(line,'bbFrictLaw=','split');
loiCoef = char(lC{2});

%Fermeture fichier
fclose(nfVehi);

function PCFmax = lecturePCFMax(nomDistributeur,fsl,fTD,sep)
%Permet de recuperer le parametre PCF max a partir de la lecture du fichier
%distributeur

%Chemin du fichier  distributeur
nDistributeur = [fTD fsl 'ControlValve'  fsl nomDistributeur '.txt'];

%Ouverture fichier
nfDistributeur = fopen(nDistributeur,'r');

%Lecture PCFMAx
line = trova_info('brPresBC=',nfDistributeur);
tab = regexp(line,'brPresBC=','split');
tableau = char(tab{2});
tableau2 = sscanf(tableau, ['%g' sep]);

PCFmax = max(tableau2);
fclose(nfDistributeur);


function [manoeuvre,tempsEchantillonage,Vinit,nomVoie] =  lectureFichierTrain(nomFichierTrain,fsl,ftoc,nombreLoco)
%Permet de r�cuperer le noms des manoeuvres des locos qui sont dans le fichier train
%Chemin du fichier  train ainsi que la vitesse initiale et le nom de la
%voie
nFichierTrain = [ftoc fsl 'dat'  fsl 'train' '.' nomFichierTrain];

%Ouverture fichier train
nfFichierTrain = fopen(nFichierTrain,'r');

for (ii = 1 : nombreLoco)
    manoeuvre(ii) = cellstr(RecupParam('Lok','nom de la manoeuvre','string',nfFichierTrain));
    
end

tempsEchantillonage = RecupParam('Schreibschrittweite','temps echantillonage','float',nfFichierTrain);
Vinit = RecupParam('VEinbruch','vitesse initiale','float',nfFichierTrain);
nomVoie = RecupParam('Streckendatei','nom de la voie','string',nfFichierTrain);

%Fermeture fichier
fclose(nfFichierTrain);



function [longueurAccouplement,rugositeCG] = lectureFichierBremsen(fsl,ftoc)
%Permet de r�cup�rer les parametres pr�sent dans le fichier bremsen.dat
%sous le dossier dat

nBremsen = [ftoc fsl 'dat' fsl 'bremsen.dat'];

%ouverture fichier bremsen
nfBremsen = fopen(nBremsen,'r');

%Lecture longueur accouplement
longueurAccouplement = RecupParam('laenge-hl-kupplung','longueur accouplement','float',nfBremsen);

%Lecture rugosite CG
rugositeCG = RecupParam('hl-reibung-kupplung','rugosite cg','float',nfBremsen);
fclose(nfBremsen);


function [nomWagon,masseChargement,jeu,Fk,t95]= lectureLigneWagon(lineWagon);
ligneWagon = textscan(lineWagon,'%s');

%Nom du wagon
nomWagon = ligneWagon{1}(1);

%Chargement des wagons
if(strcmp(ligneWagon{1}(2),'Mlad='))
    masseChargement = str2double(cellstr(ligneWagon{1}(3)));
    positionLigneWagon = 4;
else
    chargementAvecTitre = cellstr(ligneWagon{1}(2));
    chargementSansTitre = strtok(chargementAvecTitre,'Mlad=');
    masseChargement=str2double(cellstr(chargementSansTitre));
    positionLigneWagon = 3;
end

%Jeu
if(strcmp(ligneWagon{1}(positionLigneWagon),'kupplungsspiel='))
    jeu = str2double(cellstr(ligneWagon{1}(positionLigneWagon+1)));
    positionLigneWagon = positionLigneWagon + 2;
else
    jeuAvecTitre = cellstr(ligneWagon{1}(positionLigneWagon));
    jeuSansTitre = strtok(jeuAvecTitre,'kupplungsspiel=');
    jeu = str2double(cellstr(jeuSansTitre));
    positionLigneWagon = positionLigneWagon+1;
end

%Fk
if(strcmp(ligneWagon{1}(positionLigneWagon),'Fk='))
    Fk = str2double(cellstr(ligneWagon{1}(positionLigneWagon+1)));
    positionLigneWagon = positionLigneWagon + 2;
else
    FkAvecTitre = cellstr(ligneWagon{1}(positionLigneWagon));
    FkSansTitre = strtok(FkAvecTitre,'Fk=');
    Fk = str2double(cellstr(FkSansTitre));
    positionLigneWagon = positionLigneWagon+1;
end

%t95
if(strcmp(ligneWagon{1}(positionLigneWagon),'taust='))
    t95 = str2double(cellstr(ligneWagon{1}(positionLigneWagon+1)));
else
    t95AvecTitre = cellstr(ligneWagon{1}(positionLigneWagon));
    t95SansTitre = strtok(t95AvecTitre,'Fk=');
    t95 = str2double(cellstr(t95SansTitre));
end
