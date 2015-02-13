function WagonConv(fsl,ftoc,fTD,sep)
    
    %Chemin du dossier wagon
    fWagon = [fTD,fsl,'Wagon'];
  
    %Creation du dossier wagon
    if(exist(fWagon)==0)
        mkdir(fWagon);
    end
    
    %Chemin du dossier wagen a lire 
    fWagen = [ftoc,fsl,'wagen'];
    %Liste des fichiers wagon dans le dossier wagen
    lWagen = dir(fWagen);
    nbWagon = length(lWagen)-2;
    
    h0=waitbar(0,'Conversion des wagons');
    
    %Boucle sur les wagons
    for jj = 3:length(lWagen)
        disp(['Conversion Wagons : ',num2str(jj-2),' sur ',num2str(nbWagon)]);
        waitbar((jj-2)/nbWagon,h0);
        %Chemin d'accès au fichier Wagen à lire 
        nWagen = [fWagen fsl lWagen(jj).name];
        %Chemin d'accès au fichier Wagon à écrire
        nWagon = [fWagon fsl lWagen(jj).name(1:end-3) 'txt'];
        
        %Vérification qu'il s'agit d'un fichier .fzg
        if strcmp(nWagen(end-2:end),'fzg')
            %Ouverture du fichier .fzg à lire
            nfWagen = fopen(nWagen,'r');
            %Création du fichier .txt (pour ecriture)
            nfWagon = fopen(nWagon,'w');
            
            %% %%%%%%%%%%%%
            %LECTURE 
            %%%%%%%%%%%%%%%
                    
            %Lecture nom du wagon
            nom = [lWagen(jj).name(1:end-4)];
        
            %Lecture de la tare du wagon 
            tare = RecupParam('Masse','tare','float',nfWagen);
            
            %Lecture de la longueur du wagon
            longueur = RecupParam('Laenge','longueur','float',nfWagen);
            
            %Lecture % des masses tournantes
            masseTournante = RecupParam('Massenzuschlag','% masses tournantes','float',nfWagen);
                     
            %Lecture du nombre d'essieux
            nbEssieux = RecupParam('Anzahl-Achsen','nombre essieux','float',nfWagen);
            
            %Lecture nom du tampons avant
            nomTamponAvant = RecupParam('Puffer-vorne','tampons avant','string',nfWagen);
          
            %Lecture nom du traction avant
            nomTractionAvant = RecupParam('Zughaken-hinten','traction avant','string',nfWagen);
          
            %Lecture nom du tampons arriere
            nomTamponArriere = RecupParam('Puffer-hinten','tampons arriere','string',nfWagen);
            
            %Lecture nom du traction arriere
            nomTractionArriere = RecupParam('Zughaken-vorne','traction arriere','string',nfWagen);
          
            %Lecture Longueur CG
            longueurCG = RecupParam('Laenge-HL','longueur CG','float',nfWagen);
            rapportLongueurCGLongueurWagon = longueurCG/longueur ;
            
            %Lecture Diamètre CG 
            diametreCG = RecupParam('Durchmesser-HL','diametre CG','float',nfWagen);
        
             %Conversion en mm
            if diametreCG == 1.25
                diametreCG = 35.6;
            elseif diametreCG ==1 
                diametreCG =28;
            else
                %conversation mathématique en pouce
                diametreCG = diametreCG*25.4;
            end
            
            %Lecture %de contribution semelle-roue
            contributionSemelleRoue = RecupParam('Bremse-1-Bremsanteil','Contribution semelle-roue','float',nfWagen);
            
            %Lecture Nombre de semelle 
            nombreSemelle = RecupParam('Bremse-1-Anzahl-Bremskloetze','Nombre de semelle','float',nfWagen);
            
            %Lecture type de coefficient de frottement
            loiCoefficientFrottement = RecupParam('Bremse-1-Reibwert','Coefficient de frottement','string',nfWagen);
            if strcmp(loiCoefficientFrottement,'Karwatzki')
                loiCoefficientFrottement = '$EXT_BLOCK_FRICTION_LAWS[0]';
            end
            
            %Lecture Masse freinée a vide
            masseFreineeVide = RecupParam('Mbrleer','Masse freinée a vide','float',nfWagen);
            
            %Lecture Masse de transition vide-chargé
            masseTransition = RecupParam('Mbrumst','Masse de transition','float',nfWagen);
            
            %Lecture Massse freinée en charge
            masseFreineeCharge = RecupParam('Mbrbel','Masse freinée en charge','float',nfWagen);
            
            %Type de semelle 
            typeSemelle = RecupParam('Bremse-1-Klotztyp','Type de semelle','string',nfWagen);
            if strcmp(typeSemelle,'Bg')
                typeSemelle = '$SHOES_TYPE[1]';
            end
            if strcmp(typeSemelle,'Bgu')
                typeSemelle = '$SHOES_TYPE[2]';
            end
            
            %Fermeture fichier Lecture
            fclose(nfWagen);
                
            
            
            
            %% %%%%%%%%%%%%
            %DEFINITION DES PARAMETRES STANDARDS (certains sont utilisés
            %d'autres non)
            %%%%%%%%%%%%%%%
            %Nom distributeur
            distributeur = 'DistributeurDefaut';
                          
            %Check Utilisation du frein semelle-roue
            utilisationSemelleRoue = true;
            
            %Check "a partir des cylindre de frein"
            modelisationCylindreFreinS = false;
            
            %Rigging Ratio Semelle
            riggingRatioS = 0;
            
            %Rendement dyn de timonerie Semelle
            rendementDynTimonerieS = 0.83;
            
            %Section du cylindre Semelle
            sectionCylindreS = 0;
            
            %Inversion mass Semelle
            inversionMassS = 0;
            
            %Pression à vide Semelle
            pressionAVideS = 0;
            
            %Check "a partir des masses freinées" Semelle
            modelisationMasseFreineeS = true;
            
            %Check système autovariable Semelle
            modelisationSystAutovariableS = false;
            
            %masse totale du wagon
            masseTotalAutovariableS = '0.0_;_0.0';
            
            %de masse freinée
            masseFreineeAutovariableS = '0.0_;_0.0';
            
            %Check "a partir des disques de frein"
            utilisationFreinADisque = false;
            
            %contribution disque
            contributionDisque = 100;
            
            %check "a partir des cylindres de frein" Disque
            modelisationCylindreFreinD = false;
            
            %Section du cylindre Disque
            sectionCylindreD = 0; 
            
            %Inversion mass Disque
            inversionMassD = 0;
            
            %Pression maxi a vide Disque
            pressionAVideD = 0;
            
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
            
            %masse freinée en charge Disque
            masseFreineeChargeD = 3; 
            
            %masse de transition Disque
            masseTransitionD = 2;
            
            %masse freinée a vide Disque
            masseFreineeVideD = 1;
            
            %Check "Système autovariable" Disque
            modelisationSystAutovariableD = false;
            
            %masse totale du wagon Disque
            masseTotalAutovariableD = '0.0_;_0.0';
            
            % de masse freinée Disque
            masseFreineeAutovariableD = '0.0_;_0.0';
            
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
           
            
            
            %% %%%%%%%%%%%%
            %ECRITURE DANS LE FICHIER TRAINDY
            %%%%%%%%%%%%%%%
            %Ecriture du nom
            fprintf(nfWagon,'name=%s\r\n',nom);
            
            %Ecriture de la tare 
            fprintf(nfWagon,'tare=%g\r\n',tare);
            
            
            %Ecriture de la longueur
            fprintf(nfWagon,'length=%g\r\n',longueur);

            %Ecriture du % de masse tournante         
            fprintf(nfWagon,'rotaryMasses=%g\r\n',masseTournante);
             
            %Ecriture du nombre d'essieux
            fprintf(nfWagon,'axesNum=%g\r\n',nbEssieux);
            
             %Ecriture du type de tampons avant
            fprintf(nfWagon,'buffingGearsF=%s\r\n',nomTamponAvant);
            
            %Ecriture du type de traction avant
            fprintf(nfWagon,'drawGearsF=%s\r\n',nomTractionAvant);
            
            %Ecriture du type de tampons arriere
            fprintf(nfWagon,'buffingGearsR=%s\r\n',nomTamponArriere);
                                                          
            %Ecriture du type de traction arriere
            fprintf(nfWagon,'drawGearsR=%s\r\n',nomTractionArriere);
            
            %Ecriture du rapport longueur CG/ longueur wagon
            fprintf(nfWagon,'brakePipeWagonLen=%g\r\n',rapportLongueurCGLongueurWagon);
                        
            %Ecriture du diamètre CG
            fprintf(nfWagon,'brakePipeDiam=%g\r\n',diametreCG);
            
            %Ecriture du type de distributeur
            fprintf(nfWagon,'controlValve=%s\r\n',distributeur);
            
            %Ecriture du check utilisation du frein semelle-roue
            fprintf(nfWagon,'chkBlockBrake=%s\r\n',btos(utilisationSemelleRoue));
            
            %Ecriture de la contribution semelle-roue
            fprintf(nfWagon,'bbContribution=%g\r\n',contributionSemelleRoue);
            
            %Ecriture nombre de semelle
            fprintf(nfWagon,'bbShoesNum=%g\r\n',nombreSemelle);
            
            %Ecriture type de semelle
            fprintf(nfWagon,'bbShoesType=%s\r\n',typeSemelle);
                          
            %Ecriture Check "a partir des cylindre de frein"
            fprintf(nfWagon,'bbRadioSystem1=%s\r\n',btos(modelisationCylindreFreinS));
             
            %Ecriture Rigging Ratio Semelle 
            fprintf(nfWagon,'bbRigRatio=%g\r\n',riggingRatioS);
             
            %Ecriture Rendement dyn de timonerie Semelle
            fprintf(nfWagon,'bbRigEff=%g\r\n',rendementDynTimonerieS);
            
            %Ecriture Section du cylindre Semelle
            fprintf(nfWagon,'bbCylSection=%g\r\n',sectionCylindreS);

            %Ecriture Inversion mass Semelle
            fprintf(nfWagon,'bbInvMass=%g\r\n',inversionMassS);
            
            %Ecriture Pression à vide Semelle
            fprintf(nfWagon,'bbEmptyPress=%g\r\n',pressionAVideS);
            
            %Ecriture Check "a partir des masses freinées" Semelle
            fprintf(nfWagon,'bbRadioSystem2=%s\r\n',btos(modelisationMasseFreineeS));
            
            %Ecriture Massse freinée en charge
            fprintf(nfWagon,'bbBrWeightLoad=%g\r\n',masseFreineeCharge);
            
            %Ecriture Masse de transition vide-chargé
            fprintf(nfWagon,'bbChgWeight=%g\r\n',masseTransition);
            
            %Ecriture Masse freinée a vide
            fprintf(nfWagon,'bbBrWeightEmpty=%g\r\n',masseFreineeVide);
            
            %Ecriture Check système autovariable Semelle
            fprintf(nfWagon,'bbRadioSystem3=%s\r\n',btos(modelisationSystAutovariableS));
            
            %Ecriture masse totale du wagon
            fprintf(nfWagon,'bbTotMass=%s\r\n',masseTotalAutovariableS);
            
            %Ecriture % de masse freinée
            fprintf(nfWagon,'bbMassBraked=%s\r\n',masseFreineeAutovariableS);
            
            %Ecriture Check "a partir des disques de frein"
            fprintf(nfWagon,'chkDiskBrake=%s\r\n',btos(utilisationFreinADisque));
            
            %Ecriture contribution disque
            fprintf(nfWagon,'dbContribution=%g\r\n',contributionDisque);
            
            %Ecriture check "a partir des cylindres de frein" Disque
            fprintf(nfWagon,'dbRadioSystem1=%s\r\n',btos(modelisationCylindreFreinD));
            
            %Ecriture Section du cylindre Disque
            fprintf(nfWagon,'dbCylSection=%g\r\n',sectionCylindreD);
            
            %Ecriture Inversion mass Disque
            fprintf(nfWagon,'dbInvMass=%g\r\n',inversionMassD);
            
            %Ecriture Pression maxi a vide Disque
            fprintf(nfWagon,'dbEmptyPress=%g\r\n',pressionAVideD);
            
            %Ecriture premier rigging ratio Disque
            fprintf(nfWagon,'dbFRigRatio=%g\r\n',PRiggingRatioD);
                        
            %Ecriture second rigging ratio Disque
            fprintf(nfWagon,'dbSRigRatio=%g\r\n',SRiggingRatioD);
            
            %Ecriture premier rendement Disque
            fprintf(nfWagon,'dbFEffic=%g\r\n', PRendementD);
            
            %Ecriture second rendement Disque
            fprintf(nfWagon,'dbSEffic=%g\r\n',SRendementD);
            
            %Ecriture force de contre-réaction Disque
            fprintf(nfWagon,'dbCountForce=%g\r\n',forceContreReactionD);
            
            %Ecriture rayon du disque
            fprintf(nfWagon,'dbDBRadius=%g\r\n',rayonD);
            
            %Ecriture rayon de roue Disque
            fprintf(nfWagon,'dbWRadius=%g\r\n',rayonRoueD);
            
            %Ecriture Check "a partir des masses freinées" Disque
            fprintf(nfWagon,'dbRadioSystem2=%s\r\n',btos(modelisationMasseFreineeD));
            
            %Ecriture masse freinée en charge Disque
            fprintf(nfWagon,'dbBrWeightLoad=%g\r\n',masseFreineeChargeD);
            
            %Ecriture masse de transition Disque
            fprintf(nfWagon,'dbChgWeight=%g\r\n',masseTransitionD);
            
            %Ecriture masse freinée a vide Disque
            fprintf(nfWagon,'dbBrWeightEmpty=%g\r\n',masseFreineeVideD);
            
            %Ecriture Check "Système autovariable" Disque
            fprintf(nfWagon,'dbRadioSystem3=%s\r\n',btos(modelisationSystAutovariableD));
            
            %Ecriture masse totale du wagon Disque
            fprintf(nfWagon,'dbTotMass=%s\r\n',masseTotalAutovariableD);
            
            %Ecriture  de masse freinée Disque
            fprintf(nfWagon,'dbMassBraked=%s\r\n',masseFreineeAutovariableD);
            
            %Ecriture Loi coefficient de frottement
            fprintf(nfWagon,'bbFrictLaw=%s\r\n',loiCoefficientFrottement);
            
            %Ecriture Ff
            fprintf(nfWagon,'bbFF=%g\r\n',Ff);
            
            %Ecriture Fr
            fprintf(nfWagon,'bbFR=%g\r\n',Fr);
            
            %Ecriture check coef frottement constant disque 
            fprintf(nfWagon,'dbRadioFC=%s\r\n',btos(coefficientFrottementConstantD));
            
            %Ecriture loi de coef de frottement disque
            fprintf(nfWagon,'dbRadioFL=%s',btos(loiCoefficientFrottementD));
            
            %Fermeture du fichier d'ecriture
            fclose(nfWagon);
         end
    end
close(h0)     
end
         