FROM debian:12-slim
ARG FPC_STABLE_VER
ARG FPC_OLDSTABLE_VER
ARG FPC_FIXES_VER
ARG FPC_MAIN_VER

RUN dpkg --add-architecture i386 && apt-get update && apt-get -y install \
    build-essential \
    git \
    libc6-dev-i386 \
    libgtk2.0-dev \
    libgtk-3-dev \
    libqt5x11extras5-dev \
    qtbase5-dev \
    qt6-base-dev \
    unzip \
    wget

SHELL ["/bin/bash", "-c"]

# install compilers, but first save (to root directory for simplicity) docs archive for stable FPC (needed to build Lazarus docs)
RUN docarchive=doc-chm.zip; \
    wget --no-verbose --output-document=/$docarchive https://downloads.freepascal.org/fpc/dist/$FPC_STABLE_VER/docs/$docarchive; \
    if [ ! -f /$docarchive ]; then \
      exit 1; \
    fi; \
    tarballs=( \
              "$FPC_OLDSTABLE_VER https://sourceforge.net/projects/freepascal/files/Linux/$FPC_OLDSTABLE_VER/fpc-$FPC_OLDSTABLE_VER-x86_64-linux.tar fpc-$FPC_OLDSTABLE_VER-x86_64-linux" \
              "$FPC_STABLE_VER https://sourceforge.net/projects/freepascal/files/Linux/$FPC_STABLE_VER/fpc-$FPC_STABLE_VER.x86_64-linux.tar fpc-$FPC_STABLE_VER.x86_64-linux" \
              "$FPC_FIXES_VER https://gitlab.com/freepascal.org/fpc/build/-/jobs/artifacts/fixes_3_2/raw/fpc-$FPC_FIXES_VER.x86_64-linux.tar?job=build-job fpc-$FPC_FIXES_VER.x86_64-linux" \
              "$FPC_MAIN_VER https://gitlab.com/freepascal.org/fpc/build/-/jobs/artifacts/main/raw/fpc-$FPC_MAIN_VER.x86_64-linux.tar?job=build-job fpc-$FPC_MAIN_VER.x86_64-linux" \
             ); \
    for tbl in "${tarballs[@]}"; do \
      tarball=($tbl); \
      wget --no-verbose --output-document=${tarball[2]}.tar ${tarball[1]}; \
      tar xf ${tarball[2]}.tar; \
      cd ${tarball[2]}; \
      # install only compiler and RTL, do not install documentation and demos
      echo -e "\nn\nn\n" | ./install.sh || exit 1; \ 
      cd ..; \
      # store fpdoc binaries separately for each FPC version (needed to build Lazarus docs)
      cp -v /usr/bin/fpdoc /usr/bin/fpdoc-${tarball[0]}; \
      rm -vf ${tarball[2]}.tar; \
      rm -vrf ${tarball[2]}; \
    done; \
    echo; \
    echo "Contents of /etc/fpc.cfg:"; \
    cat /etc/fpc.cfg;

# build and install cross-compilers
RUN tarballs=( \
              "$FPC_OLDSTABLE_VER https://sourceforge.net/projects/freepascal/files/Source/$FPC_OLDSTABLE_VER fpc-$FPC_OLDSTABLE_VER source.tar.gz win32 i386" \
              "$FPC_OLDSTABLE_VER https://sourceforge.net/projects/freepascal/files/Source/$FPC_OLDSTABLE_VER fpc-$FPC_OLDSTABLE_VER source.tar.gz win64 x86_64" \
              "$FPC_STABLE_VER https://sourceforge.net/projects/freepascal/files/Source/$FPC_STABLE_VER fpc-$FPC_STABLE_VER source.tar.gz win32 i386" \
              "$FPC_STABLE_VER https://sourceforge.net/projects/freepascal/files/Source/$FPC_STABLE_VER fpc-$FPC_STABLE_VER source.tar.gz win64 x86_64" \
              "$FPC_FIXES_VER https://gitlab.com/freepascal.org/fpc/source/-/archive/fixes_3_2 source-fixes_3_2 tar.gz win32 i386" \
              "$FPC_FIXES_VER https://gitlab.com/freepascal.org/fpc/source/-/archive/fixes_3_2 source-fixes_3_2 tar.gz win64 x86_64" \
              "$FPC_MAIN_VER https://gitlab.com/freepascal.org/fpc/source/-/archive/main source-main tar.gz win32 i386" \
              "$FPC_MAIN_VER https://gitlab.com/freepascal.org/fpc/source/-/archive/main source-main tar.gz win64 x86_64" \
             ); \
    # downloading, building and tarball removal are done in separate steps,
    # because several targets can be built from one source
    #  
    # download sources
    for tbl in "${tarballs[@]}"; do \
      tarball=($tbl); \
      if [ ! -f ${tarball[2]}.${tarball[3]} ]; then \
        wget --no-verbose ${tarball[1]}/${tarball[2]}.${tarball[3]}; \
      fi; \   
      if [ ! -d ${tarball[2]} ]; then \
        tar zxf ${tarball[2]}.${tarball[3]}; \
      fi; \  
      if [ $? -ne 0 ]; then \
        exit 1; \
      fi; \
    done; \
    # build and install cross-compilers
    for tbl in "${tarballs[@]}"; do \
      tarball=($tbl); \
      cd ${tarball[2]}; \
      make all FPC=/usr/lib/fpc/${tarball[0]}/ppcx64 OS_TARGET=${tarball[4]} CPU_TARGET=${tarball[5]} || exit 1; \
      make crossinstall FPC=/usr/lib/fpc/${tarball[0]}/ppcx64 OS_TARGET=${tarball[4]} CPU_TARGET=${tarball[5]} INSTALL_PREFIX=/usr || exit 1; \
      cd ..; \
    done; \
    # save sources for FPC from main branch separately (they are needed e.g. for running Codetools tests)
    fpcsrcdir=/fpcsrc; \
    fpcsrcdirmain=$fpcsrcdir/$FPC_MAIN_VER; \
    mkdir -p $fpcsrcdirmain; \
    tar zxf source-main.tar.gz --strip-components=1 --directory $fpcsrcdirmain || exit 1; \
    # compile and install pas2js (needed for running some Codetools tests)
    git clone --depth 1 https://gitlab.com/freepascal.org/fpc/pas2js.git || exit 1; \
    cd pas2js; \
    rm -rf compiler; \
    ln -s ../source-main compiler; \
    make all FPC=/usr/lib/fpc/$FPC_MAIN_VER/ppcx64 || exit 1; \
    make install FPC=/usr/lib/fpc/$FPC_MAIN_VER/ppcx64 || exit 1; \
    cd ..; \
    rm -rf pas2js; \
    echo "Contents of /usr/local/bin/pas2js.cfg:"; \
    cat /usr/local/bin/pas2js.cfg; \
    # remove sources
    for tbl in "${tarballs[@]}"; do \
      tarball=($tbl); \
      rm -vf ${tarball[2]}.${tarball[3]}; \
      rm -rf ${tarball[2]}; \
    done;
