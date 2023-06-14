FROM ubuntu

RUN apt update && apt install -y git \
                                 cppcheck \
                                 clang-tidy \
                                 shellcheck \
                                 python3 \
                                 python3-pip \
                                 build-essential

RUN pip install \
    gitlint \
    cpplint \
    cppclean \
    pylint \
    systemdlint \
    isort \
    pytype

RUN git clone https://github.com/JossWhittle/FlintPlusPlus.git && \
    cd flintplusplus/flint && \
    make && \
    cp flint++ /usr/bin/ && \
    cd ../.. && \
    rm -rf flintplusplus
