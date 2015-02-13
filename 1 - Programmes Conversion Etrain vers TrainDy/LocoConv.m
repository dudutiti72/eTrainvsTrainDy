function LocoConv(fsl,ftoc,fTD,sep)

%Chemin du dossier Loco
fLocomotive = [fTD,fsl,'Locomotive'];
%Création du dossier trainDY

%Creation du dossier locomotive
if(exist(fLocomotive)==0)
    mkdir(fLocomotive);
end

%Chemin du dossier lok a lire
fLok = [ftoc,fsl,'lok'];
%Liste des fichiers wagon dans le dossier wagen
lLok = dir(fLok);
nbLoco = length(lLok)-2;

h0=waitbar(0,'Conversion des locomotives');

%Boucle sur les locomotives
for jj = 3:length(lLok)
        disp(['Conversion Locomotives : ',num2str(jj-2),' sur ',num2str(nbLoco)]);
    waitbar((jj-2)/nbLoco,h0);
    %Chemin d'accès au fichier lok à lire
    nLok = [fLok fsl lLok(jj).name];
    %Chemin d'accès au fichier locomotive à écrire
    nLocomotive = [fLocomotive fsl lLok(jj).name(1:end-3) 'txt'];
    
    %Vérification qu'il s'agit d'un fichier .lok
    if strcmp(nLok(end-2:end),'lok')
        %Ouverture du fichier .lok à lire
        nfLok = fopen(nLok,'r');
        %Création du fichier .txt (pour ecriture)
        nfLocomotive = fopen(nLocomotive,'w');
        
        %% %%%%%%%%%%%%
        %LECTURE
        %%%%%%%%%%%%%%%
        
        %Lecture nom de la locomotive
        nom = [lLok(jj).name(1:end-4)];
        
        %Lecture de la masse Totale
        masse = RecupParam('Lokmasse (t)','tare','float',nfLok);
        
        %Lecture de la longueur de la locomotive
        longueur = RecupParam('Loklaenge (m)','longueur','float',nfLok);
        
        %Lecture % des masses tournantes
        masseTournante = RecupParam('Rholok (-)','% masses tournantes','float',nfLok);
        
        
        %Lecture nom du tampons avant et arriere
        nomTamponAvant = RecupParam('Puffer','tampons avant','string',nfLok);
        nomTamponArriere = RecupParam('Puffer','tampons arriere','string',nfLok);
        
        %Lecture nom du traction avant et arriere
        nomTractionAvant = RecupParam('Zughaken','traction avant','string',nfLok);
        nomTractionArriere = RecupParam('Zughaken','traction arriere','string',nfLok);
        
        %Lecture Longueur CG
        longueurCG = RecupParam('Laenge-HL','longueur CG','float',nfLok);
        rapportLongueurCGLongueurWagon = longueurCG/longueur ;
        
        %Lecture Diamètre CG
        diametreCG = RecupParam('Durchmesser HL(Zoll)','diametre CG','float',nfLok);
        
        %Conversion en mm
        if diametreCG == 1.25
            diametreCG = 35.6;
        elseif diametreCG ==1
            diametreCG =28;
        else
            %conversation mathématique en pouce
            diametreCG = diametreCG*25.4;
        end
        
        %Lecture Masse freinée
        masseFreinee = RecupParam('Bremsgewicht','Masse freinée','float',nfLok);
        
        %Lecture Nombre de semelle
        nombreSemelle = RecupParam('Anz. der Bremskl.','Nombre de semelle','float',nfLok);
        
        %Lecture type de coefficient de frottement
        loiCoefficientFrottement = RecupParam('Reibwert','Coefficient de frottement','string',nfLok);
        
        %Lecture tableau vitesse/Freinage Rhéostatique
        [vitesseR,forceRheostatique]= RecupTableauVitesseRheostat('Ebremse-Kennlinie','endekennlinie',nfLok);
        
        %Lecture tableau vitesse/traction
        [vitesseT,traction]=RecupTableauVitesseTraction(nfLok);
        
        %Fermeture fichier Lecture
        fclose(nfLok);
        
        
        
        
        %% %%%%%%%%%%%%
        %DEFINITION DES PARAMETRES STANDARDS (certains sont utilisés
        %d'autres non)
        %%%%%%%%%%%%%%%
        %Nombre d'essieux
        nbEssieux = 4;
        
        %Facteur perte de charge
        facteurPerteCharge = 3;
        
        %Distributeur
        distributeur = 'DistributeurDefaut';
        
        %Robinet de mécanicien
        robinetMecanicien = 'RobinetDefaut';
        
        %Check Utilisation du frein semelle-roue
        utilisationSemelleRoue = true;
        
        %contribution semelle-roue
        contributionSemelleRoue = 100;
        
        %Type de semelle (Bgu par défaut)
        typeSemelle = '$SHOES_TYPE[2]';
      
        %Check "a partir des cylindre de frein"
        modelisationCylindreFreinS = false;
        
        %Rigging Ratio Semelle
        riggingRatioS = 0;
        
        %Rendement dyn de timonerie Semelle
        rendementDynTimonerieS = 0.83;
        
        %Section du cylindre Semelle
        sectionCylindreS = 0;
        
        %Check "a partir des masses freinées" Semelle
        modelisationMasseFreineeS = true;
        
        %Check "a partir des disques de frein"
        utilisationFreinADisque = false;
        
        %contribution disque
        contributionDisque = 100;
        
        %check "a partir des cylindres de frein" Disque
        modelisationCylindreFreinD = false;
        
        %Section du cylindre Disque
        sectionCylindreD = 0;
        
        %premier rigging ratio Disque
        PRiggingRatioD = 0;
        
        %second rigging ratio Disque
        SRiggingRatioD = 0;
        
        %premier rendement Disque
        PRendementD = 0;
        
        %second rendement Disque
        SRendementD = 0;
        
        %Force de contre-réaction Disque
        forceContreReactionD = 0;
        
        %rayon du disque
        rayonD = 0;
        
        %rayon de roue Disque
        rayonRoueD = 0;
        
        %Check "a partir des masses freinées" Disque
        modelisationMasseFreineeD = true;
        
        %masse freinée Disque
        masseFreineeD = 1;
        
        %Tableau temps - Rheostatique
        tempsR = '0.0_;_10000.0';
        rheostatiqueT = [num2str(max(forceRheostatique),'%10.1f') '_;_' num2str(max(forceRheostatique),'%10.1f')];
        
        %tableau temps - traction
        tempsT = '0.0_;_10000.0';
        tractionT = [num2str(max(traction),'%10.1f') '_;_' num2str(max(traction),'%10.1f')];
        
        %Ff
        Ff = 1.5;
        
        %Fr
        Fr = 2;
        
        %Coefficient de frottement disque constant
        coefficientFrottementConstantD = true;
        
        %valeur du coeff
        valeurCoefficientFrottementConstantD = 0;
        
        %Loi de coefficient de frottement disque
        loiCoefficientFrottementD = false;
        
        
        
        %% %%%%%%%%%%%%%%
        %VALEUR A RELIE AVEC LE TE DANS MANOEUVRE
        %Toujours true %Si TE = 0, la case freinage dynamique est désactivé
        %dans la manoeuvre
        %%%%%%%%%%%%%%%%%%%%%%%%%%
        %Check freinage rhéostatique
        utilisationRheostatique = true;
        
        
        
        
        %% %%%%%%%%%%%%
        %ECRITURE DANS LE FICHIER TRAINDY
        %%%%%%%%%%%%%%%
        %Ecriture du nom
        fprintf(nfLocomotive,'name=%s\r\n',nom);
        
        %Ecriture de la masse
        fprintf(nfLocomotive,'mass=%g\r\n',masse);
                
        %Ecriture de la longueur
        fprintf(nfLocomotive,'length=%g\r\n',longueur);
        
        %Ecriture du % de masse tournante
        fprintf(nfLocomotive,'rotaryMasses=%g\r\n',masseTournante);
        
        %Ecriture du nombre d'essieux
        fprintf(nfLocomotive,'numAxes=%g\r\n',nbEssieux);
        
        %Ecriture facteur de perte de charge
        fprintf(nfLocomotive,'cplfhc=%g\r\n',facteurPerteCharge);
        
        %Ecriture du type de tampons avant
        fprintf(nfLocomotive,'buffingGearsF=%s\r\n',nomTamponAvant);
        
        %Ecriture du type de traction avant
        fprintf(nfLocomotive,'drawGearsF=%s\r\n',nomTractionAvant);
        
        %Ecriture du type de tampons arriere
        fprintf(nfLocomotive,'buffingGearsR=%s\r\n',nomTamponArriere);
        
        %Ecriture du type de traction arriere
        fprintf(nfLocomotive,'drawGearsR=%s\r\n',nomTractionArriere);
        
        %Ecriture du rapport longueur CG/ longueur wagon
        fprintf(nfLocomotive,'brakePipeWagonLen=%g\r\n',rapportLongueurCGLongueurWagon);
        
        %Ecriture du diamètre CG
        fprintf(nfLocomotive,'brakePipeDiam=%g\r\n',diametreCG);
        
        %Ecriture du type de distributeur
        fprintf(nfLocomotive,'controlValve=%s\r\n',distributeur);
        
        %Ecriture du type de robinet de mécanicien
        fprintf(nfLocomotive,'driverBrakeValve=%s\r\n',robinetMecanicien);
        
        %Ecriture du check utilisation du frein semelle-roue
        fprintf(nfLocomotive,'chkBlockBrake=%s\r\n',btos(utilisationSemelleRoue));
        
        %Ecriture de la contribution semelle-roue
        fprintf(nfLocomotive,'bbContribution=%g\r\n',contributionSemelleRoue);
        
        %Ecriture nombre de semelle
        fprintf(nfLocomotive,'bbBringShoesNum=%g\r\n',nombreSemelle);
        
        %Ecriture type de semelle
        fprintf(nfLocomotive,'bbShoesType=%s\r\n',typeSemelle);
        
        %Ecriture Check "a partir des cylindre de frein"
        fprintf(nfLocomotive,'bbRadioSystem1=%s\r\n',btos(modelisationCylindreFreinS));
        
        %Ecriture Rigging Ratio Semelle
        fprintf(nfLocomotive,'bbRigRatio=%g\r\n',riggingRatioS);
        
        %Ecriture Rendement dyn de timonerie Semelle
        fprintf(nfLocomotive,'bbRigEff=%g\r\n',rendementDynTimonerieS);
        
        %Ecriture Section du cylindre Semelle
        fprintf(nfLocomotive,'bbCylSection=%g\r\n',sectionCylindreS);
   
        %Ecriture Check "a partir des masses freinées" Semelle
        fprintf(nfLocomotive,'bbRadioSystem2=%s\r\n',btos(modelisationMasseFreineeS));
        
        %Ecriture Massse freinée 
        fprintf(nfLocomotive,'bbBrWeight=%g\r\n',masseFreinee);
       
        %Ecriture Check "a partir des disques de frein"
        fprintf(nfLocomotive,'chkDiskBrake=%s\r\n',btos(utilisationFreinADisque));
        
        %Ecriture contribution disque
        fprintf(nfLocomotive,'dbContribution=%g\r\n',contributionDisque);
        
        %Ecriture check "a partir des cylindres de frein" Disque
        fprintf(nfLocomotive,'dbRadioSystem1=%s\r\n',btos(modelisationCylindreFreinD));
        
        %Ecriture Section du cylindre Disque
        fprintf(nfLocomotive,'dbCylSection=%g\r\n',sectionCylindreD);
        
        %Ecriture premier rigging ratio Disque
        fprintf(nfLocomotive,'dbFRigRatio=%g\r\n',PRiggingRatioD);
        
        %Ecriture second rigging ratio Disque
        fprintf(nfLocomotive,'dbSRigRatio=%g\r\n',SRiggingRatioD);
        
        %Ecriture premier rendement Disque
        fprintf(nfLocomotive,'dbFEffic=%g\r\n', PRendementD);
        
        %Ecriture second rendement Disque
        fprintf(nfLocomotive,'dbSEffic=%g\r\n',SRendementD);
        
        %Ecriture force de contre-réaction Disque
        fprintf(nfLocomotive,'dbCountForce=%g\r\n',forceContreReactionD);
        
        %Ecriture rayon du disque
        fprintf(nfLocomotive,'dbDBRadius=%g\r\n',rayonD);
        
        %Ecriture rayon de roue Disque
        fprintf(nfLocomotive,'dbWRadius=%g\r\n',rayonRoueD);
        
        %Ecriture Check "a partir des masses freinées" Disque
        fprintf(nfLocomotive,'dbRadioSystem2=%s\r\n',btos(modelisationMasseFreineeD));
        
        %Ecriture masse freinée en charge Disque
        fprintf(nfLocomotive,'dbBrWeight=%g\r\n',masseFreineeD);
        
        %Ecriture utilisation frein dynamique
        fprintf(nfLocomotive,'chkElettrodBrake=%s\r\n',btos(utilisationRheostatique));
       
        
        %Ecriture Tableau vitesse/effort rheostatique
        fprintf(nfLocomotive,creerLigneTableau(vitesseR,'float1decimaleMini','ebSpeed',sep,true));
        fprintf(nfLocomotive,creerLigneTableau(forceRheostatique,'float1decimaleMini','ebBrForce',sep,true));
        
        %Ecriture Tableau temps/effort rheostatique
        fprintf(nfLocomotive,'ebTime=%s\r\n',tempsR);
        fprintf(nfLocomotive,'ebPercMaxF=%s\r\n',rheostatiqueT);
        
        %Ecriture Tableau vitesse/traction
        fprintf(nfLocomotive,creerLigneTableau(vitesseT,'float1decimaleMini','etSpeed',sep,true));
        fprintf(nfLocomotive,creerLigneTableau(traction,'float1decimaleMini','etBrForce',sep,true));
       
        %Ecriture Tableau vitesse/traction
        fprintf(nfLocomotive,'etTime=%s\r\n',tempsT);
        fprintf(nfLocomotive,'etPercMaxF=%s\r\n',tractionT);
        
        %Ecriture Loi coefficient de frottement
        fprintf(nfLocomotive,'bbFrictLaw=%s\r\n',loiCoefficientFrottement);
                
        %Ecriture Ff
        fprintf(nfLocomotive,'bbFF=%g\r\n',Ff);
        
        %Ecriture Fr
        fprintf(nfLocomotive,'bbFR=%g\r\n',Fr);
        
        %Ecriture check coef frottement constant disque 
        fprintf(nfLocomotive,'dbRadioFC=%s\r\n',btos(coefficientFrottementConstantD));
            
        %Ecriture loi de coef de frottement disque
        fprintf(nfLocomotive,'dbRadioFL=%s',btos(loiCoefficientFrottementD));
            
        %Fermeture du fichier d'ecriture
        fclose(nfLocomotive);
    end
end
close(h0)





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FONCTION pour récupérer le tableau vitesse/effort freinage rhéostatique
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vitesseR,forceRheostatique] = RecupTableauVitesseRheostat(motDebut,motFin,nomFichier)
%Permet d'enregistrer dans la matrice tableau les paramètres issus d'un
%fichier Etrain

cline = trova_info(motDebut,nomFichier);
cline = fgetl(nomFichier);


numLigne = 1;
%Boucle sur chaque ligne
while(isempty(strfind(cline,motFin)))
    line = str2num(cline);
    % Si la ligne n'est pas vide
    if not(isempty(line))
        vitesseR(numLigne,1)= line(1);
        forceRheostatique(numLigne,1)= line(2);
        numLigne = numLigne+1;
    end
    cline = fgetl(nomFichier);
end




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FONCTION pour récupérer le tableau vitesse/traction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vitesseT,traction] = RecupTableauVitesseTraction(nomFichier)
%Permet d'enregistrer dans la matrice tableau les paramètres issus d'un
%fichier Etrain

nombreLigneTableau=0;
line = fgetl(nomFichier);
while ischar(line)
    if(length(line)>1)
        if(strcmp(line(1:2),'ST'))
            nombreLigneTableau = nombreLigneTableau +1;
        end
    end
    line=fgetl(nomFichier);
end
frewind(nomFichier);
for(i=1:nombreLigneTableau)
    line  = trova_info('ST',nomFichier);
    
    chiffre = sscanf(line,'%*s %*s %g %g %g %g',[1, inf]);
    if(i==1)
        vitesseT(1)=chiffre(1);
        traction(1)=chiffre(2);
        vitesseT(2)=chiffre(3);
        traction(2)=chiffre(4);
    else 
        if((vitesseT(i)==chiffre(1))&&(traction(i)==chiffre(2)))
            vitesseT(i+1)=chiffre(3);
            traction(i+1)=chiffre(4);
        else
            disp('probleme lecture tableau traction Etrain');
        end
    end
end