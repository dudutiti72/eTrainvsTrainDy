function TrackConv(fsl,ftoc,fTD,sep)

%Chemin du dossier track
fTrack = [fTD,fsl,'Track'];

%Creation du dossier track
if(exist(fTrack)==0)
    mkdir(fTrack);
end

%Chemin du dossier strecken a lire
fStrecken = [ftoc,fsl,'strecken'];
%Liste des fichiers wagon dans le dossier strecken
lStrecken = dir(fStrecken);
nbTrack = length(lStrecken)-2; 

h0=waitbar(0,'Conversion des voies');

%boucle sur les diff�rentes voies
for jj = 3:length(lStrecken)
    disp(['Conversion Voies : ',num2str(jj-2),' sur ',num2str(nbTrack)]);
    waitbar((jj-2)/nbTrack,h0);
    %Chemin d'acc�s au fichier strecken a lire
    nStrecken = [fStrecken fsl lStrecken(jj).name];
    %Chemin d'acc�s au fichier track � ecrire
    nTrack = [fTrack fsl lStrecken(jj).name(1:end-3) 'txt'];
    
    %V�rification qu'il s'agit d'un fichier .str
    if strcmp(nStrecken(end-2:end),'str')
        %Ouverture du fichier .str � lire
        nfStrecken = fopen(nStrecken,'r');
        %Cr�ation du fichier .txt (pour ecriture)
        nfTrack = fopen(nTrack,'w');
        
        %% %%%%%%%%%%%%
        %LECTURE
        %%%%%%%%%%%%%%%
        %R�cuperation de la ligne contenant les param�tres
        ligne = fgetl(nfStrecken);
        while(strcmp(ligne(1),'#'))
            ligne = fgetl(nfStrecken);
        end
        ligne = ligne(1:end-1);
        ligne = str2num(ligne);
        
        %Lecture profil voie (pente ou rampe)
        profil = ligne(1);
        
        %Lecture longueur
        longueur = ligne(2);
        
        %Lecture rayon courbe
        rayonCourbe = ligne(3);
        %D�finition ligne droite ou courbe selon rayon 
        if (rayonCourbe == 0)
            DroiteouCourbe = '$SEC_TYPE[1]';
        else 
            DroiteouCourbe = 'SEC_TYPE[2]';
        end
        
        %Fermeture fichier lecture
        fclose(nfStrecken);
        
         %% %%%%%%%%%%%%
         %DEFINITION DES PARAMETRES STANDARDS (certains sont utilis�s
         %d'autres non)
         %%%%%%%%%%%%%%%
         %Elevation
         elevation = 0;
         
         %Longueur parabolique
         longueurParabolique = 0;
         
         
         
         
         %% %%%%%%%%%%%%
         %ECRITURE DANS LE FICHIER TRAINDY
         %%%%%%%%%%%%%%%
         %Ecriture du type
         fprintf(nfTrack,'secType=%s\r\n',DroiteouCourbe);
         
         %Ecriture de la longueur 
         A = sscanf(num2str(longueur),['%d' '.' '%d']);
         if((length(A)==1))
             longueur = num2str(longueur,'%10.1f');
         else
             longueur = num2str(longueur);
         end
   
         fprintf(nfTrack,'length=%s\r\n',longueur);
         
         
         %Ecriture rayon de courbure
         A = sscanf(num2str(rayonCourbe),['%d' '.' '%d']);
         if((length(A)==1))
             rayonCourbe = num2str(rayonCourbe,'%10.1f');
         else
             rayonCourbe = num2str(rayonCourbe);
         end
         fprintf(nfTrack,'curvRad=%s\r\n',rayonCourbe);
         
         %Ecriture profil voie
         A = sscanf(num2str(profil),['%d' '.' '%d']);
         if((length(A)==1))
             profil = num2str(profil,'%10.1f');
         else
             profil = num2str(profil);
         end
         fprintf(nfTrack,'slope=%s\r\n',profil);
        
         %Ecriture elevation
         A = sscanf(num2str(elevation),['%d' '.' '%d']);
         if((length(A)==1))
             elevation = num2str(elevation,'%10.1f');
         else
             elevation = num2str(elevation);
         end
         fprintf(nfTrack,'elev=%s\r\n',elevation);
         
         %Ecriture longueur parabolique
         A = sscanf(num2str(longueurParabolique),['%d' '.' '%d']);
         if((length(A)==1))
             longueurParabolique = num2str(longueurParabolique,'%10.1f');
         else
             longueurParabolique = num2str(longueurParabolique);
         end
         fprintf(nfTrack,'parabLen=%s',longueurParabolique);
         
         %Fermeture du fichier ecriture
         fclose(nfTrack);
    end
end
close(h0)