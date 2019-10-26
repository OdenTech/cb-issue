#!/bin/sh -e

if [ -z "${BALENA_TOKEN}" ]; then
  echo "BALENA_TOKEN unset"
  exit 1
fi

set -x

# we are inside the dind container, starting up a local dockerd
nohup dockerd 2>&1 &
sleep 5  # wait for dockerd to spin up fully

export DOCKER_HOST=unix:///var/run/docker.sock

cd /workspace

apk --no-cache add ca-certificates wget libstdc++6 gcompat libc6-compat unzip curl gcompat npm

curl -sLO http://artifacts.oden.io/resin/balena-cli.tar.gz
tar zxf balena-cli.tar.gz

export ROOT=$(pwd)
export PATH=${ROOT}/balena-cli/bin/:${PATH}

# patch balena-cli's balena-preload module to print stacktrace in losetup @contextmanager function
cat << EOF > ${ROOT}/balena-cli/patches/balena-preload+8.2.1.patch
diff --git a/node_modules/balena-preload/src/preload.py b/node_modules/balena-preload/src/preload.py
index 685f8e0..3ce4675 100755
--- a/node_modules/balena-preload/src/preload.py
+++ b/node_modules/balena-preload/src/preload.py
@@ -29,6 +29,9 @@ from sh import (
 )
 from shutil import copyfile, rmtree
 from tempfile import mkdtemp, NamedTemporaryFile
+import traceback
+
+log.info("XXXXXXXXXXXXXXXXXXXXXXXX parsing preload.py XXXXXXXXXXXXXXXXXXXXXXXXX")
 
 os.environ["LANG"] = "C"
 
@@ -80,6 +83,9 @@ def prepare_global_partitions():
 
 @contextmanager
 def losetup_context_manager(image, offset=None, size=None):
+    log.info('--------------------- losetup_context_manager call() -----------------------')
+    for line in traceback.format_stack():
+        log.info(line.strip())
     args = ["-f", "--show"]
     if offset is not None:
         args.extend(["--offset", offset])
@@ -825,6 +831,7 @@ methods = {
 
 
 if __name__ == "__main__":
+    log.info("XXXXXXXXXXXXXXXXXXXXXXXX invoking preload.py XXXXXXXXXXXXXXXXXXXXXXXXX")
     update_ca_certificates()
     for line in sys.stdin:
         data = json.loads(line)
EOF
cd ${ROOT}/balena-cli/
npx patch-package
cd -

balena login --token "${BALENA_TOKEN}"
balena os download raspberry-pi -o ${ROOT}/balena.img --version 2.32.0+rev1
balena os configure ${ROOT}/balena.img --app rpizero-test --device-type raspberry-pi --config config.json

which balena
ls $(which balena)

docker run hello-world
export DEBUG=1
./repro.py
# balena preload --docker /var/run/docker.sock ${ROOT}/balena.img --app rpizero-test
# || docker run --privileged -v /dev:/dev -v ${ROOT}/balena.img:/img/balena.img --entrypoint /bin/sh balena/balena-preload -xc "cd /img && ls -l && losetup --f --show --offset 4194304 --sizelimit 41943040 /img/balena.img"
