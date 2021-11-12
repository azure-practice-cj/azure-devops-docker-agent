FROM ubuntu:18.04 AS base

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

# Install depencies
RUN apt-get update
RUN apt-get install -y --no-install-recommends ca-certificates curl jq git
RUN apt-get install -y --no-install-recommends iputils-ping libcurl4 libicu60
RUN apt-get install -y --no-install-recommends libunwind8 netcat libssl1.0

# Install maven
RUN apt-get install maven

# Install JDK
RUN apt-get install openjdk-11-jdk
ARG BUILD_JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
ARG BUILD_JAVA_HOME_11_X64="/usr/lib/jvm/java-11-openjdk-amd64"
ENV JAVA_HOME=$BUILD_JAVA_HOME
ENV JAVA_HOME_11_X64=$BUILD_JAVA_HOME_11_X64

# Install Azure CLI
RUN curl -LsS https://aka.ms/InstallAzureCLIDeb | bash
ARG TARGETARCH=amd64
ARG AGENT_VERSION=2.185.1

# Install Azure DevOps Agent Tool
WORKDIR /azp
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz; \
    else \
      AZP_AGENTPACKAGE_URL=https://vstsagentpackage.azureedge.net/agent/${AGENT_VERSION}/vsts-agent-linux-${TARGETARCH}-${AGENT_VERSION}.tar.gz; \
    fi; \
    curl -LsS "$AZP_AGENTPACKAGE_URL" | tar -xz
COPY ./start.sh .

# Clean up
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /var/cache/apt/archives
RUN apt-get clean autoclean
RUN apt-get autoremove --yes

RUN chmod +x start.sh

FROM base

ENTRYPOINT [ "./start.sh" ]