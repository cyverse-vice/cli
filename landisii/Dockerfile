FROM harbor.cyverse.org/vice/cli/xenial:latest

USER root 

WORKDIR /opt

# set non-interactive status for builds
ENV DEBIAN_FRONTEND noninteractive

# install basic dependencies
RUN apt-get update && \
    apt install -y apt-transport-https \
    git \
    libjpeg62 \
    libpng16-16 \
    wget \
    software-properties-common \
    unzip && \
    add-apt-repository universe

# Install Microsoft dot net
RUN cd /opt && \
    wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    apt-get update && apt-get install -y dotnet-sdk-2.0.0 && \
    apt clean && \ 
    rm packages-microsoft-prod.deb

# Install LANDIS
RUN wget https://github.com/LANDIS-II-Foundation/Core-Model-v7-LINUX/archive/v7.zip && \
    unzip v7.zip && \
    cd /opt/Core-Model-v7-LINUX-7/Tool-Console/src && dotnet build -c Release  

# Install Extensions
RUN wget https://github.com/LANDIS-II-Foundation/Support-Library-Dlls-v7/archive/master.zip && \
    unzip master.zip -d /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    rm master.zip

#SCRPPLE test DGS compliant (this is the version within ML's personal repo- WORKS)
RUN wget https://github.com/mslucash/Extension-SCRPPLE/archive/master.zip && \
    unzip master.zip -d /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    rm master.zip && \
    cp /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-SCRPPLE-master/src/lib/Ether.WeightedSelector.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-SCRPPLE-master/src; sed -i -e 's/lib\\Landis.Library/..\\..\\Support-Library-Dlls-v7-master\\Landis.Library/g' scrapple.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-SCRPPLE-master/src; sed -i -e 's/lib\\Ether./..\\..\\Support-Library-Dlls-v7-master\\Ether./g' scrapple.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-SCRPPLE-master/src; dotnet build -c Release scrapple.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-SCRPPLE-master/deploy/installer; dotnet /opt/Core-Model-v7-LINUX-7/build/Release/Landis.Extensions.dll add "Scrapple 3.2.2.1.txt" && \
    cp /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-SCRPPLE-master/src/obj/Release/netstandard2.0/Landis.Extension.Scrapple-v3.dll /opt/Core-Model-v7-LINUX-7/build/extensions/.

# Output Biomass (WORKS)
RUN wget https://github.com/LANDIS-II-Foundation/Extension-Output-Biomass/archive/v3.0.zip && \
    unzip v3.0.zip -d /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    rm v3.0.zip && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-3.0/src; sed -i -e 's/lib\\Landis.Library/..\\..\\Support-Library-Dlls-v7-master\\Landis.Library/g' output-biomass.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-3.0/src; dotnet build -c Release output-biomass.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-3.0/deploy/installer; dotnet /opt/Core-Model-v7-LINUX-7/build/Release/Landis.Extensions.dll add "Output Biomass 3.0.txt" && \
    cp /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-3.0/src/obj/Release/netstandard2.0/Landis.Extension.Output.Biomass-v3.dll /opt/Core-Model-v7-LINUX-7/build/extensions/.

# Output Biomass Community (WORKS)
RUN wget https://github.com/LANDIS-II-Foundation/Extension-Output-Biomass-Community/archive/v2.0.zip && \
    unzip v2.0.zip -d /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    rm v2.0.zip && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-Community-2.0/src; sed -i -e 's/lib\\Landis.Library/..\\..\\Support-Library-Dlls-v7-master\\Landis.Library/g' output-biomass-community.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-Community-2.0/src; dotnet build -c Release output-biomass-community.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-Community-2.0/deploy/installer; dotnet /opt/Core-Model-v7-LINUX-7/build/Release/Landis.Extensions.dll add "Output Biomass Community 2.0.txt" && \
    cp /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-Community-2.0/src/obj/Release/netstandard2.0/Landis.Extension.Output.BiomassCommunity-v2.dll /opt/Core-Model-v7-LINUX-7/build/extensions/.

# Output Biomass Reclass (WORKS)
RUN wget https://github.com/LANDIS-II-Foundation/Extension-Output-Biomass-Reclass/archive/v3.0.zip && \
    unzip v3.0.zip -d /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    rm v3.0.zip && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-Reclass-3.0/src; sed -i -e 's/lib\\Landis.Library/..\\..\\Support-Library-Dlls-v7-master\\Landis.Library/g' output-biomass.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-Reclass-3.0/src; dotnet build -c Release output-biomass.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-Reclass-3.0/deploy/installer; dotnet /opt/Core-Model-v7-LINUX-7/build/Release/Landis.Extensions.dll add "Output Biomass Reclass 3.0.txt" && \
    cp /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-Output-Biomass-Reclass-3.0/src/obj/Release/netstandard2.0/Landis.Extension.Output.BiomassReclass-v3.dll /opt/Core-Model-v7-LINUX-7/build/extensions/.

# GIPL (WORKS)
RUN wget https://github.com/LANDIS-II-Foundation/Library-GIPL/archive/master.zip && \
    unzip master.zip -d /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    rm master.zip && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Library-GIPL-master/ /opt/Core-Model-v7-LINUX-7/build/extensions/Library-GIPL/ && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Library-GIPL/src; sed -i -e 's/lib\\Landis.Library/..\\..\\Support-Library-Dlls-v7-master\\Landis.Library/g' GiplDamm.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Library-GIPL/src; dotnet build -c Release GiplDamm.csproj && \
    cp /opt/Core-Model-v7-LINUX-7/build/extensions/Library-GIPL/src/bin/Debug/netstandard2.0/Landis.Extension.GiplDamm.dll /opt/Core-Model-v7-LINUX-7/build/extensions/.  
 
# SHAW (WORKS)
RUN wget https://github.com/LANDIS-II-Foundation/Library-Shaw/archive/master.zip && \
    unzip master.zip -d /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    rm master.zip && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Library-Shaw-master/ /opt/Core-Model-v7-LINUX-7/build/extensions/Library-Shaw/ && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Library-Shaw/src; sed -i -e 's/lib\\Landis.Library/..\\..\\Support-Library-Dlls-v7-master\\Landis.Library/g' ShawDammNewInputs.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Library-Shaw/src; dotnet build -c Release ShawDammNewInputs.csproj && \
    cp /opt/Core-Model-v7-LINUX-7/build/extensions/Library-Shaw/src/bin/Debug/netstandard2.0/Landis.Extension.ShawDamm.dll /opt/Core-Model-v7-LINUX-7/build/extensions/. 

# DGS (WORKS)
RUN wget https://github.com/LANDIS-II-Foundation/Extension-DGS-Succession/archive/master.zip && \
    unzip master.zip -d /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    rm master.zip && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-DGS-Succession-master/ /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-DGS-Succession/ && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-DGS-Succession/src; sed -i -e 's/lib\\Landis.Library/..\\..\\Support-Library-Dlls-v7-master\\Landis.Library/g' DGS-succession.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-DGS-Succession/src; dotnet build -c Release DGS-succession.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-DGS-Succession/deploy/installer; dotnet /opt/Core-Model-v7-LINUX-7/build/Release/Landis.Extensions.dll add "DGS_Succession 1.101.txt" && \
    cp /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-DGS-Succession/src/obj/Release/netstandard2.0/Landis.Extension.Succession.DGS.dll /opt/Core-Model-v7-LINUX-7/build/extensions/. 

# NECN (WORKS)
RUN wget https://github.com/TEEL-Lab/Extension-NECN-Succession/archive/master.zip && \
    unzip master.zip -d /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    rm master.zip && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-NECN-Succession-master/src; sed -i -e 's/lib\\Landis.Library/..\\..\\Support-Library-Dlls-v7-master\\Landis.Library/g' NECN-succession.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-NECN-Succession-master/src; dotnet build -c Release NECN-succession.csproj && \
    cd /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-NECN-Succession-master/deploy/installer; dotnet /opt/Core-Model-v7-LINUX-7/build/Release/Landis.Extensions.dll add "NECN_Succession 6.7.txt" && \
    cp /opt/Core-Model-v7-LINUX-7/build/extensions/Extension-NECN-Succession-master/src/obj/Release/netstandard2.0/Landis.Extension.Succession.NECN-v6.dll /opt/Core-Model-v7-LINUX-7/build/extensions/.

# Move Support Libraries to the correct place
RUN mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Succession-v8.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Succession-InputAGB.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.SiteHarvest-v2.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Parameters-v2.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Metadata-v2.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.LeafBiomassCohorts-v2.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.InitialCommunity.Biomass.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.InitialCommunity-vInputBiomass.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.InitialCommunity-v1.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.HarvestManagement-v4.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Cohorts-v2.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Climate-v4.3.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.BiomassHarvest-v3.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.BiomassCohorts-v3.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Biomass-v2.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.AgeOnlyCohorts-v3.dll /opt/Core-Model-v7-LINUX-7/build/extensions/.
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Climate-v3.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Climate-v3.pdb /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Climate-v4.1.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Climate-v4.2.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Climate-v4.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Succession-v6.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.Succession-v7.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Ether.WeightedSelector.dll /opt/Core-Model-v7-LINUX-7/build/extensions/ && \
#    mv /opt/Core-Model-v7-LINUX-7/build/extensions/Support-Library-Dlls-v7-master/Landis.Library.HarvestManagement-v3.dll /opt/Core-Model-v7-LINUX-7/build/extensions/.

RUN chown -R 1000:1000 /opt/Core-Model-v7-LINUX-7

WORKDIR /home/user