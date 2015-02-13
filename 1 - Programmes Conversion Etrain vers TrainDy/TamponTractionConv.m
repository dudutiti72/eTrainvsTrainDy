function TamponTractionConv(fsl,ftoc,fTD,sep)

%Convertie les fichiers .fdr du dossier federn en fichier .txt sous le dossier BuffersDrawGears

%Chemin du dossier BuffersDrawGears
fBufferDrawGears = [fTD,fsl,'BuffersDrawGears'];

%Creation du dossier bufferDrawGears
if(exist(fBufferDrawGears)==0)
      mkdir(fBufferDrawGears);
end

%Chemin du dossier federn à lire
fFedern = [ftoc,fsl,'federn'];
%liste des fichiers tampons et traction dans le dossier federn
lFedern = dir(fFedern);
nbTampTract = length(lFedern)-2; 

h0=waitbar(0,'Conversion des tampons et des organes de traction');

%Boucle sur les tampons et les tractions
for jj = 3:length(lFedern)
     disp(['Conversion Tampons et Traction : ',num2str(jj-2),' sur ',num2str(nbTampTract)]);
     waitbar((jj-2)/nbTampTract,h0);
     %Chemin d'accès au fichier Wagen à lire 
     nFedern = [fFedern fsl lFedern(jj).name];
     %Chemin d'accès au fichier Wagon à écrire
     nBufferDrawGears = [fBufferDrawGears fsl lFedern(jj).name(1:end-3) 'txt'];
     
     %Vérification qu'il s'agit d'un fichier .fdr
     if strcmp(nFedern(end-2:end),'fdr')
        %Ouverture du fichier .fdr à lire
        nfFedern = fopen(nFedern,'r');
        %Création du fichier .txt (pour ecriture)
        nfBufferDrawGears = fopen(nBufferDrawGears,'w');
        
         %% %%%%%%%%%%%%
         %LECTURE 
         %%%%%%%%%%%%%%%
         %Lecture du nom du tampon
         nom = lFedern(jj).name(1:end-4);
         
         %Lecture vitesse de charge limite
         vitesseChargeLimite = RecupParam('xp0_load','vitesseChargeLimite','float',nfFedern);
         
         %Lecture vitesse de decharge limite
         vitesseDechargeLimite = RecupParam('xp0_unload','vitesseDechargeLimite','float',nfFedern);
         
         %Lecture coefficient d'amortissement
         coefficientAmortissement = RecupParam('Daempfung','coefficientAmortissement','float',nfFedern);
         
         %Lecture tableau course / force charge
         [course,charge] = RecupTableauTamponTraction('Kennlinie','endekennlinie',nfFedern);   
         
         %fermeture fichier Lecture 
         fclose(nfFedern);
         
         %Création de la colonne force décharge à partir de la valeur du
         %coefficient d'amortissement
         decharge = charge.*((100-coefficientAmortissement)/100);
         
         
         
         
         %% %%%%%%%%%%%%
         %DEFINITION DES PARAMETRES STANDARDS (certains sont utilisés
         %d'autres non)
         %%%%%%%%%%%%%%%
         utilisationCoefAmortissement = true;
         
         
         %% %%%%%%%%%%%%%%%%%
         %ECRITURE DANS LE FICHIER TRAINDY
         %%%%%%%%%%%%%%%%%%%%
         %Ecriture du nom
         fprintf(nfBufferDrawGears,'name=%s\r\n',nom);
         
         %Ecriture vitesse charge limite
         fprintf(nfBufferDrawGears,'loadLimVel=%g\r\n',vitesseChargeLimite);
         
         %Ecriture vitesse decharge limite
         fprintf(nfBufferDrawGears,'unloadLimVel=%g\r\n',vitesseDechargeLimite);

         %Ecriture check utilisation coefficient d'amortissement
         fprintf(nfBufferDrawGears,'chkDampCoeff=%s\r\n',btos(utilisationCoefAmortissement));
         
         %Ecriture coefficient d'amortissement
         fprintf(nfBufferDrawGears,'dampCoeff=%g\r\n',coefficientAmortissement);
      
         %Ecriture course
         fprintf(nfBufferDrawGears,creerLigneTableau(course,'float1decimaleMini','stroke',sep,true));
        
         %Ecriture charge
         fprintf(nfBufferDrawGears,creerLigneTableau(charge,'float1decimaleMini','load',sep,true));

         %Ecriture decharge
         fprintf(nfBufferDrawGears,creerLigneTableau(decharge,'float1decimaleMini','unload',sep,false));
         
         %Fermeture fichier ecriture
         fclose(nfBufferDrawGears);
     end
end
close(h0)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FONCTION pou récupérer le tableau course/force charge)%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [course,charge] = RecupTableauTamponTraction(motDebut,motFin,nomFichier)
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
        course(numLigne,1)= line(1);
        charge(numLigne,1)= line(2);
        numLigne = numLigne+1;
    end
    cline = fgetl(nomFichier);
    
end
         