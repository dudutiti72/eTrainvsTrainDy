function CreerDistributeurParDefaut(fsl,fTD,sep)

%Chemin du dossier distributeur
fDistributeur = [fTD,fsl,'ControlValve'];

%Creation du dossier Distributeur
if(exist(fDistributeur)==0)
    mkdir(fDistributeur);
end

%Nom du ditributeur
nom = 'DistributeurDefaut';

%Chemin du fichier distributeur
nDistributeur = [fDistributeur fsl nom '.txt'];



if(exist(nDistributeur)==0)
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %PARAMETRE PAR DEFAUT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %APPLICATION STROKE DATA
    %Pression cylindre de frein [bar]
    pressionCFASD = 0.25;
    
    %Temps [s]
    tempsASD = 0.6;
    
    %Delta P atteint à la CG après ce temps
    deltaPASD = 0.25;
    
    
    
    %DONNEES CARACTERISTIQUES DU PREMIER TEMPS
    %Pression cylindre de frein
    pressionCFPT = 0.65;
    
    %Temps
    tempsPT = 0.5;
    
    
    
    %TEMPS DE FREINAGE CARACTERISTIQUE
    %temps montée 95 P
    temps95P = 4;
    
    %temps montée 100 P
    temps100P = 4.5;
    
    %temps montée 95 G
    temps95G = 24;
    
    %temps montée 100 G
    temps100G = 28;
    
    
    
    %TEMPS DESSERRAGE CARACTERISTIQUE
    %Temps a 110 Pmin P
    temps110PminP = 18;
    
    %Temps à Pmin P
    tempsPminP = 19;
    
    %Temps a 110 Pmin G
    temps110PminG = 64;
    
    %Temps a Pmin G
    tempsPminG = 66;
    
    
    %FONCTION DE TRANSFERT
    %freinage
    PCGfreinage = '3.56_;_4.78';
    PCFfreinage = '3.8_;_0.0';
    
    %desserrage
    PCGdesserrage = '3.7_;_4.71_;_4.85';
    PCFdesserrage = '3.8_;_0.23_;_0.23';
    
    
    
    %OPTIONS AVANCEES
    %delta P pour application effective
    deltaPAE = 0.18;
    
    %course au CF
    courseCF = 174;
    
    %volume de la chambre accelératrice
    volumeCA = 0.9;
    
    %diametre CA
    diametreCA = 3;
    
    %delta P activation CA
    deltaPCA = 0.08;
    
    %Pression minimale fermeture CA
    PminfermetureCA = 0;
    
    %Volume reservoir auxiliaire
    volumeRA = 107;
    
    %diametreRA
    diametreRA = 10;
    
    %delta P imposé par la vanne RA CG
    deltaPVanneRACG = 0.1;
    
    %Pression marche du RA
    PmarcheRA = 4.92;
    
    
    
    
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ECRITURE DANS LE FICHIER DISTRIBUTEUR
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Ouverture fichier distributeur
    nfDistributeur = fopen(nDistributeur,'w');
    
    %nom
    fprintf(nfDistributeur,'name=%s\r\n',nom);
    
    %APPLICATION STROKE DATA
    %Pression cylindre de frein [bar]
    fprintf(nfDistributeur,'asPresBrCyl=%g\r\n',pressionCFASD);
    
    %Temps [s]
    fprintf(nfDistributeur,'asTime=%g\r\n',tempsASD);
    %Delta P atteint à la CG après ce temps
    fprintf(nfDistributeur,'genPipe=%g\r\n',deltaPASD);
    
    
    %DONNEES CARACTERISTIQUES DU PREMIER TEMPS
    %Pression cylindre de frein
    fprintf(nfDistributeur,'ifPresBrCyl=%g\r\n',pressionCFPT);
    %Temps
    fprintf(nfDistributeur,'ifTime=%g\r\n',tempsPT);
    
    
    %TEMPS DE FREINAGE CARACTERISTIQUE
    %temps montée 95 P
    fprintf(nfDistributeur,'btp95Pm=%g\r\n',temps95P);
    %temps montée 100 P
    fprintf(nfDistributeur,'btpPm=%g\r\n',temps100P);
    %temps montée 95 G
    fprintf(nfDistributeur,'btg95Pm=%g\r\n',temps95G);
    %temps montée 100 G
    fprintf(nfDistributeur,'btgPm=%g\r\n',temps100G);
    
    
    %TEMPS DESSERRAGE CARACTERISTIQUE
    %Temps a 110 Pmin P
    fprintf(nfDistributeur,'rtp110Pm=%g\r\n',temps110PminP);
    %Temps à Pmin P
    fprintf(nfDistributeur,'rtpPm=%g\r\n',tempsPminP);
    %Temps a 110 Pmin G
    fprintf(nfDistributeur,'rtg110Pm=%g\r\n',temps110PminG);
    %Temps a Pmin G
    fprintf(nfDistributeur,'rtgPm=%g\r\n',tempsPminG);
    
    %FONCTION DE TRANSFERT
    %freinage
    fprintf(nfDistributeur,'brPresGP=%s\r\n',PCGfreinage);
    fprintf(nfDistributeur,'brPresBC=%s\r\n',PCFfreinage);
    
    %desserrage
    fprintf(nfDistributeur,'rePresGP=%s\r\n',PCGdesserrage);
    fprintf(nfDistributeur,'rePresBC=%s\r\n',PCFdesserrage);
    
    
    
    %OPTIONS AVANCEES
    %delta P pour application effective
    fprintf(nfDistributeur,'dpBPPABrCyl=%g\r\n',deltaPAE);
    %course au CF
    fprintf(nfDistributeur,'strBrCyl=%g\r\n',courseCF);
    %volume de la chambre accelératrice
    fprintf(nfDistributeur,'volAcCha=%g\r\n',volumeCA);
    %diametre CA
    fprintf(nfDistributeur,'diaAcCha=%g\r\n',diametreCA);
    %delta P activation CA
    fprintf(nfDistributeur,'dpBPPAAcCha=%g\r\n',deltaPCA);
    %Pression minimale fermeture CA
    fprintf(nfDistributeur,'minPrClAcCha=%g\r\n',PminfermetureCA);
    %Volume reservoir auxiliaire
    fprintf(nfDistributeur,'volAuxRes=%g\r\n',volumeRA);
    %diametreRA
    fprintf(nfDistributeur,'diaAuxRes=%g\r\n',diametreRA);
    %delta P imposé par la vanne RA CG
    fprintf(nfDistributeur,'dpChVal=%g\r\n',deltaPVanneRACG);
    %Pression marche du RA
    fprintf(nfDistributeur,'prRunAuxRes=%g',PmarcheRA);
    
    fclose(nfDistributeur);
end