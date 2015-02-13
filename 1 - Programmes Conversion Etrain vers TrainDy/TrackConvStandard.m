function TrackConv(fsl,ftoc,fTD,sep)

%Chemin du dossier track
fTrack = [fTD,fsl,'Track'];

%Creation du dossier track
if(exist(fTrack)==0)
    mkdir(fTrack);
end


h0=waitbar(0,'Conversion des voies standards');



    disp(['Conversion Voie Standard: ',num2str(1),' sur ',num2str(1)]);
    
    
    %Chemin d'accès au fichier track à ecrire
    nTrack = [fTrack fsl 'VoieStandard' '.txt'];
    
    %Création du fichier .txt (pour ecriture)
    nfTrack = fopen(nTrack,'w');
   
        
         %% %%%%%%%%%%%%
         %DEFINITION DES PARAMETRES STANDARDS (certains sont utilisés
         %d'autres non)
         %%%%%%%%%%%%%%%
         DroiteouCourbe = '$SEC_TYPE[1]';
         profil = '0';
         rayonCourbe = '0';
         longueur = '10000';
         
         %Elevation
         elevation = '0';
         
         %Longueur parabolique
         longueurParabolique = '0';
         
         
         
         
         %% %%%%%%%%%%%%
         %ECRITURE DANS LE FICHIER TRAINDY
         %%%%%%%%%%%%%%%
         %Ecriture du type
         fprintf(nfTrack,'secType=%s\r\n',DroiteouCourbe);
         
         %Ecriture de la longueur
   
         fprintf(nfTrack,'length=%s\r\n',longueur);
         
         
         %Ecriture rayon de courbure
       
         fprintf(nfTrack,'curvRad=%s\r\n',rayonCourbe);
         
         %Ecriture profil voie
      
         fprintf(nfTrack,'slope=%s\r\n',profil);
        
         %Ecriture elevation
        
         fprintf(nfTrack,'elev=%s\r\n',elevation);
         
         %Ecriture longueur parabolique
     
         fprintf(nfTrack,'parabLen=%s',longueurParabolique);
         
         %Fermeture du fichier ecriture
         fclose(nfTrack);
  
close(h0)