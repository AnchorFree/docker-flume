FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y tzdata wget software-properties-common
ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# --- add Hadoop users before installing CDH packages to have predefined user/group IDs
RUN groupadd -g 980 impala
RUN groupadd -g 986 hadoop
RUN groupadd -g 987 hdfs
RUN groupadd -g 988 yarn
RUN groupadd -g 989 mapred
RUN useradd -u 985 -g 980 -d /var/lib/impala -c "Impala" impala
RUN useradd -u 990 -g 987 -d /var/lib/hadoop-hdfs -c "Hadoop HDFS" hdfs
RUN useradd -u 991 -g 988 -d /var/lib/hadoop-yarn -c "Hadoop Yarn" yarn
RUN useradd -u 992 -g 989 -d /var/lib/hadoop-mapreduce -c "Hadoop MapReduce" mapred
# --- CDH packages
RUN add-apt-repository -y ppa:webupd8team/java
RUN wget 'https://archive.cloudera.com/cdh5/ubuntu/xenial/amd64/cdh/cloudera.list' -O /etc/apt/sources.list.d/cloudera.list
RUN wget 'https://archive.cloudera.com/cdh5/ubuntu/xenial/amd64/cdh/archive.key' -O archive.key && apt-key add archive.key
RUN apt-get update
# --- Add Oracle Java
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
RUN apt-get install -y oracle-java8-installer
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle
# --- Install Hadoop Client libs
RUN apt-get install -y hadoop-client
RUN wget -q https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.9/jmx_prometheus_javaagent-0.9.jar -P /usr/lib/hadoop/lib/
# --- Install flume
RUN mkdir /opt/flume && wget -qO- http://archive.apache.org/dist/flume/1.8.0/apache-flume-1.8.0-bin.tar.gz | tar zxvf - -C /opt/flume --strip 1
ENV PATH /opt/flume/bin:$PATH

RUN /bin/bash
