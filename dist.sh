#!/bin/bash

# Ugly script that prepares a Z3 playground
# Jose F. Morales

# Physical directory where the script is located
_base=$(e=$0;while test -L "$e";do d=$(dirname "$e");e=$(readlink "$e");\
     cd "$d";done;cd "$(dirname "$e")";pwd -P)

# Website checkout and branch
webdist=$_base/dist
webbranch=web

# Location of z3 wasm build
z3wasm=$_base/../z3-rise4fun/out

# Move to the website checkout and make sure that everything is fine
function goto_webdist() {
    if ! [ -x "$webdist" ]; then
        echo "error: $webdist does not exist (please clone this repo at $webdist and switch to '$webbranch' branch)"
        exit 1
    fi
    if ! cd "$webdist"; then
        echo "error: could not move to $webdist"
        exit 1
    fi
    branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    if [ "$branch" != "$webbranch" ]; then
        echo "error: wrong branch, please checkout $webbranch"
        exit 1
    fi
}

# ---------------------------------------------------------------------------

function html_header() {
    cat <<EOF
    <div class="header">
      <div style="text-align: right; float: right; font-size: 80%; padding: 0.5em; margin-right: 2em; ">
        <a href="https://github.com/jfmc/z3-play">[Source &#8599;]</a><br/>
        A simple <a href="https://github.com/Z3Prover/z3">Z3</a>
        playground based on the
        <a href="https://microsoft.github.io/monaco-editor/">Monaco Editor</a>.
        <br/>
        <b>Acknowledgments</b>:
        original <a href="https://www.philipzucker.com/z3-rise4fun/">rise4fun Z3 reconstruction</a>,
        <a href="https://github.com/bramvdbogaerde/z3-wasm">z3-wasm</a>.
        <br/>
      </div>
      <h2><a href="https://github.com/jfmc">jfmc</a>'s Z3 Playground</h2>
    </div>
EOF
}

# ---------------------------------------------------------------------------

function html_before() {
    cat <<EOF
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <link
      rel="stylesheet"
      data-name="vs/editor/editor.main"
      href="/z3-play/node_modules/monaco-editor/min/vs/editor/editor.main.css"
      />
    <link rel="stylesheet" href="z3-play.css"/>
    <title>Z3 Playground</title>
  </head>
  <body style="overflow: hidden">
EOF
    html_header
    cat <<EOF
    <div class="split left">
      <div class="doc">
EOF
}
function html_after() {
    cat <<EOF
      </div>
      <div class="split right">
        <div class="monacoContainer" id="container"></div>
        <div class="infoContainer">
          <div class="control">
            <button id="run-button">&#9654; Run</button>
          </div>
          <pre class="infoContents" id="info">
        </div>
      </div>
    </div>

    <script>
      var require = { paths: { vs: 'node_modules/monaco-editor/min/vs' } };
    </script>
    <script src="node_modules/monaco-editor/min/vs/loader.js"></script>
    <script src="node_modules/monaco-editor/min/vs/editor/editor.main.nls.js"></script>
    <script src="node_modules/monaco-editor/min/vs/editor/editor.main.js"></script>

    <script src="coi-serviceworker.js"></script>
    <script src="z3-play.js"></script>
    <script src="z3.js"> </script>
  </body>
</html>
EOF
}

function gen_html() { # file
    html_before
    cat "$1"
    html_after
}

# ---------------------------------------------------------------------------

echo "Copying files to $webdist"
from=$_base
# Populate webdist
goto_webdist

# Generate html files
# Guide
gen_html "$from"/docs/guide.html > index.html
# (example, just a fragment)
gen_html "$from"/docs/propositional.html > propositional.html

# Copy main playground files
for i in z3-play.js z3-play.css coi-serviceworker.js; do
    cp "$from"/src/"$i" "$i"
done
# Copy z3 wasm build
for i in z3.js z3.wasm z3.worker.js; do
    cp "$z3wasm"/"$i" "$i"
done
# Copy monaco-editor
mkdir -p node_modules/monaco-editor
if ! [ -x node_modules/monaco-editor/min ]; then
    cp -R "$from"/node_modules/monaco-editor/min node_modules/monaco-editor/
else
    echo "Skip node_modules/monaco-editor/min copy (remove to force update)"
fi


