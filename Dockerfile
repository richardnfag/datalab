FROM fedora:41

WORKDIR /datalab

# Install prerequisites
RUN sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    curl https://packages.microsoft.com/config/rhel/8/prod.repo | tee /etc/yum.repos.d/microsoft.repo && \
    dnf update -y && \
    dnf install -y dotnet-sdk-9.0 python3 python3-pip powershell git gcc gcc-c++ make unzip && \
    dnf clean all

COPY requirements.txt /datalab

# Install Python Dependencies
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt && \
    rm requirements.txt

# Install .Net environment
RUN dotnet tool install -g Microsoft.dotnet-interactive && \
    echo 'export PATH="$PATH:/root/.dotnet/tools"' >> ~/.bash_profile && \
    source ~/.bash_profile && \
    dotnet interactive jupyter install

# Install Rust environment
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    source ~/.bash_profile && \
    cargo install --locked evcxr_jupyter && \
    evcxr_jupyter --install

# Install Deno environment
RUN curl -fsSL https://deno.land/install.sh | sh -s -- -y && \
    source ~/.bash_profile && \
    deno jupyter --install


EXPOSE 8000

ENTRYPOINT ["jupyter-lab", "--ip=0.0.0.0", "--port=8000", "--allow-root", "--no-browser", "--NotebookApp.token=''", "--NotebookApp.password=''"]
