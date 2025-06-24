FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# 安装基础工具
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg2 \
    software-properties-common \
    build-essential \
    git \
    vim \
    tmux \
    htop \
    python3 \
    python3-pip \
    python3-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    build-essential
    gosu \
    sudo \
    pcl-tools \
    net-tools \
    iputils-ping \
    nmap \
    wget \
    curl \
    dnsutils \
    traceroute \
    telnet \
    netcat \
    tcpdump \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

RUN mkdir -p /etc/skel/.config/pip && \
    echo "[global]" > /etc/skel/.config/pip/pip.conf && \
    echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> /etc/skel/.config/pip/pip.conf && \
    mkdir -p /root/.config && \
    cp -r /etc/skel/.config /root/

RUN python3 -m pip install --upgrade pip && \
    pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu117

# 再安装其他常用包（使用默认PyPI源）
RUN pip3 install \
    numpy \
    pandas \
    matplotlib \
    jupyter \
    scikit-learn \
    opencv-python \
    Pillow

# 设置环境变量
ENV PATH=/usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# 创建工作目录
WORKDIR /workspace

# 暴露Jupyter端口
EXPOSE 8888

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/bin/bash"]
