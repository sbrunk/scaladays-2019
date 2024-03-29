#!/bin/bash
set -e

# We have to build Vegas locally until we have a 2.12 release (https://github.com/vegas-viz/Vegas/issues/106)
export COURSIER_EXPERIMENTAL=1
./coursier install sbt-launcher
git clone https://github.com/sbrunk/Vegas.git
cd Vegas
git checkout spark-212
$(../coursier install-path)/sbt '++2.12.8 publishLocal'
cd ..
rm -rf Vegas
./coursier fetch -e 2.12.8 --sources --default org.vegas-viz::vegas-spark:0.3.12-SNAPSHOT

# Install almond for Scala 2.12
SCALA_VERSION=2.12.8 ALMOND_VERSION=0.5.0
./coursier bootstrap \
  -r jitpack \
  -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
  sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
  --sources --default=true \
  -o almond
./almond --install \
  --command "java -XX:MaxRAMPercentage=80.0 -jar almond" \
  --copy-launcher \
  --metabrowse
rm -f almond


# Install almond for Scala 2.11
SCALA_VERSION=2.11.12 ALMOND_VERSION=0.5.0
./coursier bootstrap \
  -r jitpack \
  -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
  sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
  --sources --default=true \
  -o almond-scala-2.11
./almond-scala-2.11 --install --id scala211 --display-name "Scala (2.11)" \
  --command "java -XX:MaxRAMPercentage=80.0 -jar almond-scala-2.11 --id scala211 --display-name 'Scala (2.11)'" \
  --copy-launcher \
  --metabrowse
rm -f almond-scala-2.11

# Set indentation to two spaces
JUPYTER_CONFIG_DIR=$(jupyter --config-dir)
# Classic notebook
mkdir -p $JUPYTER_CONFIG_DIR/nbconfig/
cat > $JUPYTER_CONFIG_DIR/nbconfig/notebook.json <<- EOF
{
  "CodeCell": {
    "cm_config": {
      "indentUnit": 2
    }
  }
}
EOF
# JupyterLab notebook
mkdir -p $JUPYTER_CONFIG_DIR/lab/user-settings/@jupyterlab/notebook-extension/
cat > $JUPYTER_CONFIG_DIR/lab/user-settings/@jupyterlab/notebook-extension/tracker.jupyterlab-settings <<- EOF
{
    "codeCellConfig": {
      "tabSize": 2
    }
}
EOF
# JupyterLab editor
mkdir -p $JUPYTER_CONFIG_DIR/lab/user-settings/@jupyterlab/fileeditor-extension/
cat > $JUPYTER_CONFIG_DIR/lab/user-settings/@jupyterlab/fileeditor-extension/plugin.jupyterlab-settings <<- EOF
{
    "editorConfig": {
      "tabSize": 2,
    }
}
EOF

# Install required Jupyter/JupyterLab extensions
pip install RISE jupyter_contrib_nbextensions
jupyter labextension install @jupyterlab/plotly-extension
jupyter contrib nbextension install --user
jupyter nbextension enable splitcell/splitcell

# Workaround for https://github.com/damianavila/RISE/issues/479
mkdir $JUPYTER_CONFIG_DIR/custom
cp rise.css $JUPYTER_CONFIG_DIR/custom/custom.css

# Run notebook to prefetch remaining deps and initialize the compiler cache
jupyter nbconvert --to notebook --execute --allow-errors slides.ipynb
