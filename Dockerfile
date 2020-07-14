FROM python:3.8.3-slim-buster AS stage1

MAINTAINER John L. Whiteman <johnlwhiteman@usrs.noreply.github.com>

# Update these to the latest if you want
ENV PANDOC https://github.com/jgm/pandoc/releases/download/2.10/pandoc-2.10-1-amd64.deb
ENV PANDOCC https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.7.0/pandoc-crossref-Linux-2.10.tar.xz
ENV DEBIAN https://dl.yarnpkg.com/debian/
ENV KINDLEGEN http://www.amazon.com/gp/redirect.html/ref=amb_link_6?location=http://kindlegen.s3.amazonaws.com/kindlegen_linux_2.6_i386_v2_9.tar.gz&token=536D040605DC9B19419F3E7C28396577B326A45A&source=standards&pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-7&pf_rd_r=2GK0TQH3KFWWE4ESFDC5&pf_rd_r=2GK0TQH3KFWWE4ESFDC5&pf_rd_t=1401&pf_rd_p=51e198fa-b346-4ea1-ab56-68aefc1abc58&pf_rd_p=51e198fa-b346-4ea1-ab56-68aefc1abc58&pf_rd_i=1000765211
ENV PANDOC_RUN_FILTER https://github.com/johnlwhiteman/pandoc-run-filter.git

# Don't change these
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
ENV HOME_DIR = /hello

# Feel free to add or remove
WORKDIR /tmp
RUN mkdir -p /usr/share/man/man1 ${HOME_DIR} && \
    apt-get update && apt-get -y install --no-install-recommends \
    asymptote \
    curl \
    ditaa \
    figlet \
    git \
    gnupg2 \
    graphviz \
    make \
    mscgen \
    nodejs \
    pandoc-citeproc \
    plantuml \
    texlive-latex-base \
    texlive-fonts-extra \
    texlive-latex-extra \
    texlive-fonts-recommended \
    xz-utils && \
    python -m pip install --no-cache-dir \
    blockdiag \
    matplotlib \
    matplotlib-venn \
    nwdiag \
    numpy \
    pandoc-imagine \
    pillow \
    pygal \
    seqdiag \
    xdot && \
    curl -sL -o pandoc.deb ${PANDOC} && \
    dpkg -i pandoc.deb && rm -f pandoc.deb && \
    curl -sL -o pandoc-crossref.tgz ${PANDOCC} && \
    tar -xvf pandoc-crossref.tgz && \
    mv ./pandoc-crossref /usr/bin/pandoc-crossref && rm -fr pandoc-crossref* && \
    pandoc --version && pandoc-crossref --version && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb ${DEBIAN} stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install --no-install-recommends yarn && \
    yarn global add mermaid.cli mermaid-filter && yarn cache clean && \
    mkdir -p /tmp/tmp && cd /tmp/tmp && \
    curl -sL -o kindlegen.tgz ${KINDLEGEN} && tar -xvf kindlegen.tgz && \
    mv ./kindlegen /usr/bin/kindlegen && cd /tmp && rm -fr /tmp/tmp && \
    mv /usr/bin/ditaa /usr/bin/ditaa.jar && \
    echo '#!/usr/bin/env bash' > /usr/bin/ditaa && \
    echo 'java -jar /usr/bin/ditaa.jar' >> /usr/bin/ditaa && \
    chmod +x /usr/bin/ditaa && \
    cd /tmp && git clone ${PANDOC_RUN_FILTER} && \
    cd ./pandoc-run-filter && pip install . && cd /tmp && \
    apt-get autoremove && apt-get autoremove --purge && apt-get autoclean && \
    apt-get remove --purge -y curl gnupg2 git xz-utils && \
    rm -fr /var/lib/apt/lists/* /tmp/ /var/cache/apt/archives/*.deb

WORKDIR ${HOME_DIR}
ENTRYPOINT ["/bin/bash"]
