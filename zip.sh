indir=$1
version=$2
[ -f ${version}.zip ] && rm -r ${version}.zip
cp -r ${indir} bin
cd bin/wdl/ && zip -r tasks.zip tasks
cd ../../
zip -r ${version}.zip bin
rm -r bin
