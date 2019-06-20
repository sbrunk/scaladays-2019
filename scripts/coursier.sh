#!/bin/bash
set -e

# Install coursier
curl -L -o coursier https://git.io/coursier-cli
chmod +x coursier

# Prefetch packages used in slides
./coursier fetch -e 2.12.8 --sources --default \
  org.apache.spark::spark-sql:2.4.3 \
  sh.almond::almond-spark:0.5.0 \
  org.plotly-scala::plotly-almond:0.7.0 \
  io.github.stanch::reftree:1.4.0 \
  org.typelevel::squants:1.4.0