function LoiCoefFrottementConv(fsl,ftoc,fTD,sep)
%Convertie les loi de coef de frottement pr�sente dans le fichier
%reibwerte.dat en loi de coef de frottement trainDy dans le dossier
%BlockFrictionLaws

%Chemin du dossier BlockFrictionLaws
fBlockFrictionLaws = [fTD,fsl,'BlockFrictionLaws'];
%Creation du dossier block friction Laws
if(exist(fBlockFrictionLaws)==0)
    mkdir(fBlockFrictionLaws);
end


%Chemin du dossier DiskFrictionLaws (qui sera inutilis� mais qui doit �tre
%cr��)
fDiskFrictionLaws = [fTD,fsl,'DiskFrictionLaws'];
%Cr�ation du dossier diskFrictionLaws (inutilis� mais devant �tre cr��)
if(exist(fDiskFrictionLaws)==0)
    mkdir(fDiskFrictionLaws);
end

%nom fichier reibwerte.dat � lire
nReibwerte = [ftoc,fsl,'dat',fsl,'reibwerte.dat'];
nfReibwerte= fopen(nReibwerte,'r');
%Recup�ration de la liste des loi de coef de frottement
nReibwerte;
nomsLoi = RecupNomsLois(nfReibwerte);

%D�finition de la colonne de pression sp�cifique standard
colonnePressionSpecifique= [0 0 1 10 100 1000 10000];

h0=waitbar(0,'Conversion des lois de coefficient de frottement');

for(i=1:length(nomsLoi))
    disp(['Conversion Lois de coefficient de frottement : ',num2str(i),' sur ',num2str(length(nomsLoi))]);
    waitbar(i/length(nomsLoi),h0);
    %Chemin d'acc�s au fichier coef de frottement � �crire
    nBlockFrictionLaws = [fBlockFrictionLaws fsl  char(nomsLoi(i)) '.txt'];
    %Cr�ation du fichier coef de frottement � ecrire
    nfBlockFrictionLaws = fopen(nBlockFrictionLaws,'w');
    
    
    [vitesse,valeurCoeff]=RecupTableauVitesseCoef(['Typ     ' char(nomsLoi(i))],'Kennlinie:','endekennlinie',nfReibwerte);
    
    if(length(vitesse)>20)
        disp('Erreur : la loi de coefficient contient trop de valeur pour trainDy (plus de 20)');
    end
    
    %ecriture de la colonne pression specifique
    fprintf(nfBlockFrictionLaws,creerLigneTableau(colonnePressionSpecifique,'float1decimaleMini','col00',sep,true));
    
    %Ecriture des autres colonnes du tableau
    for (j=1:20)
        %vecteur colonne a ecrire dans la fichier blockFrictionLaws
        if(j<=length(vitesse))
            col = [vitesse(j) valeurCoeff(j) valeurCoeff(j) valeurCoeff(j) valeurCoeff(j) valeurCoeff(j) valeurCoeff(j)];
        else
            col = [0 0 0 0 0 0 0];
        end
        
        if(j<10)
            fprintf(nfBlockFrictionLaws,creerLigneTableau(col,'float1decimaleMini',['col0' num2str(j)],sep,true));
        else
            if(j==20)
               fprintf(nfBlockFrictionLaws,creerLigneTableau(col,'float1decimaleMini',['col' num2str(j)],sep,false));
            else
               fprintf(nfBlockFrictionLaws,creerLigneTableau(col,'float1decimaleMini',['col' num2str(j)],sep,true));
            end
        end
    end
    
    
   %fermeture fichier
   fclose(nfBlockFrictionLaws);
    
    
    

end

%fermeture fichier lecture
fclose(nfReibwerte);
close(h0)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FONCTION pour r�cup�rer les noms des diff�rentes loi de coef de frottement
%et les colonnes vitesse/valeur coef
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nomsLoi = RecupNomsLois(nomFichier)
%Permet d'enrgistrer dans une matrice les nom des loi de coef de frottement
%dans une une autre matrice les colonnesVitess
nombreLoi=0;
line = fgetl(nomFichier);
while ischar(line)
    if(length(line)>1)
        if(strcmp(line(1:3),'Typ'))
            nombreLoi = nombreLoi +1;
            line = sscanf(line,'%*s %s');
            nomsLoi(nombreLoi)=cellstr(line);
        end
    end
    line=fgetl(nomFichier);
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FONCTION pou r�cup�rer le tableau vitesse/valeurcoeff)%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [vitesse,valeurCoef] = RecupTableauVitesseCoef(motDebut1,motDebut2,motFin,nomFichier)
%Permet d'enregistrer dans la matrice tableau les param�tres issus d'un
%fichier Etrain

cline = trova_info(motDebut1,nomFichier);
cline =  trova_info(motDebut2,nomFichier);
cline = fgetl(nomFichier);

numLigne = 1;
%Boucle sur chaque ligne
while(isempty(strfind(cline,motFin)))
    line = str2num(cline);
    
    % Si la ligne n'est pas vide
    if not(isempty(line))
        vitesse(numLigne,1)= line(1);
        valeurCoef(numLigne,1)= line(2);
        numLigne = numLigne+1;
    end
    cline = fgetl(nomFichier);
    
end




