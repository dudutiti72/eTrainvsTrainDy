%Permet de convertir les fichiers utilisés par Etrain en fichiers
%utilisable par TrainDy

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PARAMETRES D'ENTREE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Choix du dossier Etrain à convertir
%Chemin vers le dossier racine Etrain contenant les sous-dossier
%'airbrake','zug','dat', etc...
dossierEtrain =  uigetdir('C:\','Sélectionner le dossier Etrain à convertir : ') 
%dossierEtrain='Z:\STAGE - Autres - MODALOHR\ETRAIN\MODALHOR_COMBINE';

%Seperateur TrainDy : '_;_' par défaut
sep = '_;_';

% '\' pour WINDOWS et '/' pour LINUX
fsl = '\';

tic


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CREATION DU DOSSIER TRAINDY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Chemin du dossier TrainDy
%Supression des espaces (non supporté par TrainDy)*
f = findstr(dossierEtrain,'\');
espace = isspace(dossierEtrain(max(f)+1:end));
dossierACree = dossierEtrain;
for(i=max(f)+1:length(dossierEtrain))
    if(espace(i-max(f)))
        dossierACree(i)='_';
    end
end

fTD = [dossierACree '_TD']

%Création du dossier trainDY
if(exist(fTD)==0)
     mkdir(fTD)
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CREATION DES FICHIERS PAR DEFAUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Creation du distributeur par défaut
CreerDistributeurParDefaut(fsl,fTD,sep);

%Creation du robinet de mécanicient par défaut
CreerRobinetParDefaut(fsl,fTD,sep);




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CONVERSION DES FICHIERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Conversion des wagons

WagonConv(fsl,dossierEtrain,fTD,sep);
disp(sprintf('\n'))


%Conversion des locomotives

LocoConv(fsl,dossierEtrain,fTD,sep);
disp(sprintf('\n'))

%Conversion des tampons et des attelages

TamponTractionConv(fsl,dossierEtrain,fTD,sep);
disp(sprintf('\n'))

%Conversion des voies 
TrackConvStandard(fsl,dossierEtrain,fTD,sep);
TrackConv(fsl,dossierEtrain,fTD,sep);
disp(sprintf('\n'))

%Conversion des manoeuvres

ManoeuvreConvStandard(fsl,dossierEtrain,fTD,sep);
ManoeuvreConv(fsl,dossierEtrain,fTD,sep);
disp(sprintf('\n'))

%Conversion des loi de coefficient de frottement

LoiCoefFrottementConv(fsl,dossierEtrain,fTD,sep);
disp(sprintf('\n'))

%Conversion configuration et test
ConfigurationTestConvStandard(fsl,dossierEtrain,fTD,sep);
ConfigurationTestConv(fsl,dossierEtrain,fTD,sep);

disp(sprintf('\n'))

disp('Temps de conversion :')
toc
disp(sprintf('\n'))
disp('Conversion Réussie, le dossier TrainDy est situé sous le chemin suivant : ')
disp(fTD)