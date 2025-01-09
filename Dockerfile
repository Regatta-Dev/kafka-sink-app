FROM cnfldemos/cp-server-connect-datagen:0.6.2-7.5.0

# Update and install necessary libraries and tools
USER root

# Update and install necessary libraries and tools
RUN dnf update -y && \
    dnf install -y java-17-openjdk openssl libaio vim && \
    dnf clean all

# Set Java 8 as the default
RUN alternatives --set java java-17-openjdk.x86_64

# Create symbolic links
RUN ln -s /usr/lib64/libssl.so.1.1 /usr/lib64/libssl.so

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib64:/usr/lib/jvm/java-17-openjdk-17.0.9.0.9-2.el8.x86_64/lib/server:/usr/lib/jvm/java-17-openjdk-17.0.9.0.9-2.el8.x86_64/lib

